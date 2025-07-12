import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googlesearch/Color/colors.dart';
import 'package:googlesearch/responsive/mobile_screen_lauout.dart';
import 'package:googlesearch/responsive/responsive_layout_screen.dart';
import 'package:googlesearch/responsive/web_screen_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Clone',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.notoSansTextTheme().apply(
          bodyColor: Colors.white, // Apply white color to the text
          displayColor: Colors.white, // Ensure that all text in the app is white
        ),
      ),
      home: const ResponsiveLayout(
        mobileScreenLayout: MobileScreenLayout(),
        webScreenLayout: WebScreenLayout(),
      ),
    );
  }
}
