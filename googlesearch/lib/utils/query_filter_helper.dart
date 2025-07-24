import 'package:flutter/material.dart';
import 'package:googlesearch/services/api_service.dart';
import 'package:googlesearch/utils/safety_filter.dart';

class QueryFilterHelper {
  static Future<Map<String, dynamic>> handleQueryAgeAndContent({
  required BuildContext context,
  required String searchQuery,
  required String start,
  required String? ageCategory,
}) async {
  print("== Query Filter Helper Called ==");
  print("Age category (lowercase): ${ageCategory?.toLowerCase()}");
  bool isHarmful = await SafetyFilter.isQueryHarmful(searchQuery);
  print("Is query harmful? $isHarmful");
  
  if ((ageCategory?.toLowerCase() == 'teens' || ageCategory?.toLowerCase() == 'thirties') && isHarmful) {
    print("Returning safe filtered results.");
    return {
      'items': [
        {
          'title': 'SafeNet: Help is Here',
          'link': 'https://www.childhelplineinternational.org/',
          'formattedUrl': 'childhelplineinternational.org',
          'snippet': 'We support teenagers facing difficult situations. Talk to someone safe.',
          'pagemap': {
            'cse_image': [
              {'src': 'https://upload.wikimedia.org/wikipedia/commons/8/8b/Safe_search_icon.svg'}
            ]
          }
        },
        {
          'title': 'Mental Health Support for Teens',
          'link': 'https://www.who.int/',
          'formattedUrl': 'who.int',
          'snippet': 'Learn how to manage thoughts and emotions. You are not alone.',
          'pagemap': {
            'cse_image': [
              {'src': 'https://www.who.int/images/default-source/mental-health/mental-health.png'}
            ]
          }
        }
      ],
      'searchInformation': {
        'formattedTotalResults': '2',
        'formattedSearchTime': '0.01'
      }
    };
  }

  print("Fetching normal API results...");
  final response = await ApiService().fetchData(
    context: context,
    queryTerm: searchQuery,
    start: start,
  );
  print("API results count: ${response['items']?.length ?? 0}");
  return response;
}


}
