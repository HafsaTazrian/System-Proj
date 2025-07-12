import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:googlesearch/widgets/search.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        // Removed AppBar to make space for the animation
        body: Stack(
          children: [
            // Lottie animation as the background filling the whole screen
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: size.width, // Full width
                  height: size.height, // Full height
                  child: Lottie.asset(
                    'assets/animation.json',
                    fit: BoxFit.cover, // Cover the entire screen
                    repeat: true, // Optional: keeps the animation repeating
                  ),
                ),
              ),
            ),
              SizedBox(height: size.height * 0.25),
            // Main content on top of the animation
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.25), // Adjust the height as needed
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: const [
                          SizedBox(height: 40),
                          Search(),
                          SizedBox(height: 20),
                          // You can add more widgets here if needed
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
