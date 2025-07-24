import 'dart:convert';

import 'package:flutter/services.dart';

class SafetyFilter {
  //loadin the list of harmufl words
  static Future<List<String>> loadHarmfulWords() async {
   //loading the json file as string
   final String jsonString=await rootBundle.loadString('assets/harmful_words.json');

   final jsonData=json.decode(jsonString);
   return List<String>.from(jsonData['harmful_keywords']);

  }

  //checking if any query has any harmful words

  static Future<bool> isQueryHarmful(String query) async {
  final harmfulWords = await loadHarmfulWords();
  final lowerQuery = query.toLowerCase();

  for (var word in harmfulWords) {
    if (lowerQuery.contains(word)) {
      print("Harmful word detected: $word in query: $query");
      return true;
    }
  }
  return false;
}

}