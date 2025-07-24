import 'package:flutter/material.dart';
import 'package:googlesearch/Color/colors.dart';
import 'package:googlesearch/services/api_service.dart';
import 'package:googlesearch/utils/query_filter_helper.dart';
import 'package:googlesearch/web/web_search_header.dart';
import 'package:googlesearch/widgets/search_footer.dart';
//import 'package:googlesearch/widgets/search_header.dart';
import 'package:googlesearch/widgets/search_result_component.dart';
import 'package:googlesearch/widgets/search_tabs.dart';
class SearchScreen extends StatelessWidget {
  final String searchQuery;
  final String start;
  final String? ageCategory;
  
  const SearchScreen({
    Key? key, 
    required this.searchQuery, 
    this.start = '0',
    this.ageCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Title(
        color: Colors.blue,
        title: searchQuery,
        child:
         Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pass searchQuery to WebSearchHeader
                WebSearchHeader(searchQuery: searchQuery),
                
                if (ageCategory != null)
                  Padding(
                    padding: EdgeInsets.only(left: size.width <= 768 ? 10 : 150.0, top: 8.0),
                    child: Text(
                      'Voice Age Category: $ageCategory',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.only(left: size.width <= 768 ? 10 : 150.0),
                  child: const SearchTabs(),
                ),
                
                const Divider(thickness: 0),

              FutureBuilder<Map<String, dynamic>>(
  future: QueryFilterHelper.handleQueryAgeAndContent(
    context: context,
    searchQuery: searchQuery,
    start: start,
    ageCategory: ageCategory,
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      print("Snapshot error: ${snapshot.error}");
      return Center(child: Text("Error: ${snapshot.error}"));
    }
    if (!snapshot.hasData) {
      print("No data in snapshot.");
      return const Center(child: Text("No results found."));
    }
    print("Snapshot data items count: ${snapshot.data?['items']?.length ?? 0}");
    
   
  
  

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width <= 768 ? 10 : 150, top: 12),
                          child: Text(
                            "About ${snapshot.data?['searchInformation']['formattedTotalResults']} results (${snapshot.data?['searchInformation']['formattedSearchTime']} seconds)",
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ),
                        
                        SizedBox(
                          height: size.height * 0.7,
                          child:
                          ListView.builder(
  physics: const BouncingScrollPhysics(),
  padding: EdgeInsets.symmetric(horizontal: size.width <= 768 ? 10 : 100),
  itemCount: snapshot.data?['items'].length,
  itemBuilder: (context, index) {
    var item = snapshot.data?['items'][index];

    // Extract image URL if available
    String? imageUrl;
    if (item['pagemap'] != null && item['pagemap']['cse_image'] != null) {
      imageUrl = item['pagemap']['cse_image'][0]['src']; // Get the first image
    }

    return SearchResultComponent(
      linkToGo: item['link'],
      link: item['formattedUrl'],
      text: item['title'],
      desc: item['snippet'],
      imageUrl: imageUrl, // Pass the image URL
    );
  },
),

                        ),

                        const SizedBox(height: 30),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                child: const Text("< Prev", style: TextStyle(fontSize: 15, color: blueColor)),
                                onPressed: start != "0"
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SearchScreen(
                                              searchQuery: searchQuery,
                                              start: (int.parse(start) - 10).toString(),
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                              const SizedBox(width: 30),
                              TextButton(
                                child: const Text("Next >", style: TextStyle(fontSize: 15, color: blueColor)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchScreen(
                                        searchQuery: searchQuery,
                                        start: (int.parse(start) + 10).toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const SearchFooter(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
