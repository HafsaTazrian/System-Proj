import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:googlesearch/Color/colors.dart';
import 'package:googlesearch/Screens/search_screen.dart';
class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController(); 
  
  
  // Add controller

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/google-logo.png',
              height: size.height * 0.12,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: size.width > 768 ? size.width * 0.4 : size.width * 0.9,
            child: TextFormField(
              controller: searchController, // Assign the controller
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: searchBorder),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/images/search-icon.svg',
                    color: searchBorder,
                    width: 1,
                    height: 1,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/images/mic-icon.svg',
                  ),
                ),
              ),
              onFieldSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(
                        searchQuery: val.trim(),
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      searchController.text = val.trim(); // Restore search text
                    });
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
