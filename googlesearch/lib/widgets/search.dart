import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:googlesearch/Color/colors.dart';
import 'package:googlesearch/Screens/search_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController searchController = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _speechEnabled = false;
  String _status = '';
  String _ageCategory = '';

  html.MediaRecorder? _recorder;
  html.MediaStream? _mediaStream;
  final List<html.Blob> _audioChunks = [];

  Timer? _silenceTimer;
  Timer? _maxRecordingTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeRecorder();
  }

  Future<void> _initializeSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  Future<void> _initializeRecorder() async {
    try {
      _mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({'audio': true});
      if (_mediaStream != null) {
        _recorder = html.MediaRecorder(_mediaStream!);
        _recorder!.addEventListener('dataavailable', (event) {
          if (event is html.BlobEvent && event.data != null) {
            _audioChunks.add(event.data!);
            _resetSilenceTimer();
          }
        });
        _recorder!.addEventListener('stop', (_) {
          _cancelTimers();
          _processAudioChunks();
        });
        setState(() {
          _status = 'Recorder initialized';
        });
      }
    } catch (e) {
      setState(() => _status = 'Error initializing recorder: $e');
    }
  }

  Future<void> _startRecording() async {
    _audioChunks.clear();
    setState(() {
      _isRecording = true;
      _status = 'Recording...';
    });

    _maxRecordingTimer = Timer(const Duration(seconds: 30), () {
      if (_isRecording) _stopRecording();
    });

    try {
      _recorder?.start(100); // 100ms chunks
      _resetSilenceTimer();
    } catch (e) {
      setState(() {
        _status = 'Error starting recorder: $e';
        _isRecording = false;
      });
      _cancelTimers();
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _isProcessing) return;

    setState(() {
      _isRecording = false;
      _isListening = false;
      _status = 'Stopping recording...';
    });

    _cancelTimers();

    try {
      _recorder?.stop();
      _speech.stop();
    } catch (e) {
      setState(() => _status = 'Error stopping: $e');
      _isProcessing = false;
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 1), () {
      if (_isRecording) {
        _stopRecording();
      }
    });
  }

  void _cancelTimers() {
    _silenceTimer?.cancel();
    _maxRecordingTimer?.cancel();
  }

  Future<void> _processAudioChunks() async {
    if (_audioChunks.isEmpty) return;

    final blob = html.Blob(_audioChunks, 'audio/webm');
    await _predictAgeFromVoice(blob);
  }

  Future<void> _predictAgeFromVoice(html.Blob audioBlob) async {
    try {
      setState(() {
        _status = 'Sending audio to server...';
        _isProcessing = true;
      });

      final formData = html.FormData();
      final file = html.File([audioBlob], 'audio.webm', {'type': 'audio/webm'});
      formData.appendBlob('file', file);

      final request = html.HttpRequest();
      request.open('POST', 'http://127.0.0.1:5001/predict_age');

      final completer = Completer<void>();

      request.onLoad.listen((_) {
        if (request.status == 200) {
          try {
            final result = json.decode(request.responseText!);
            setState(() {
              _ageCategory = result['predicted_age_category'];
              _status = 'Age predicted: $_ageCategory';
            });
          } catch (e) {
            setState(() => _status = 'Error parsing response');
          }
        } else {
          setState(() => _status = 'Server error: ${request.status}');
        }
        _isProcessing = false;
        completer.complete();
      });

      request.onError.listen((e) {
        setState(() {
          _status = 'Network error';
          _isProcessing = false;
        });
        completer.complete();
      });

      request.send(formData);
      await completer.future;

      _navigateToSearch();
    } catch (e) {
      setState(() {
        _status = 'Error sending audio: $e';
        _isProcessing = false;
      });
    }
  }

  void _startListening() async {
    if (_isProcessing || !_speechEnabled) return;

    await _startRecording();

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "notListening" && _isRecording) {
          _stopRecording();
        }
      },
      onError: (error) {
        setState(() {
          _status = 'Speech error: $error';
          _isListening = false;
          _isRecording = false;
          _isProcessing = false;
        });
        _cancelTimers();
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _status = 'Listening...';
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            searchController.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
      );
    }
  }

  void _handleMicClick() async {
    if (_isProcessing) return;

    if (_isRecording || _isListening) {
      await _stopRecording();
    } else {
      _startListening();
    }
  }

  void _navigateToSearch() {
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(
            start: '0',
            searchQuery: query,
            ageCategory: _ageCategory,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    _mediaStream?.getTracks().forEach((track) => track.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            height: 50,
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                ScaleAnimatedText(
                  'SafeNet',
                  textStyle: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: const Color.fromARGB(255, 21, 21, 21),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: size.width > 768 ? size.width * 0.4 : size.width * 0.9,
          child: TextFormField(
            controller: searchController,
            onFieldSubmitted: (_) => _navigateToSearch(),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: searchBorder),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/images/search-icon.svg',
                  color: searchBorder,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: _handleMicClick,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    _isRecording || _isListening ? Icons.mic : Icons.mic_none,
                    key: ValueKey(_isRecording || _isListening),
                    color: _isRecording || _isListening ? Colors.red : searchBorder,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _status,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
