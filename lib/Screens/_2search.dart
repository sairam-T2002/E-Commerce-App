// SearchScreen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final String categoryName;
  final String imageUrl; // Pass the image URL to display the correct image

  const SearchScreen({
    required this.categoryName,
    required this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: categoryName, // The same tag used in HomeScreen
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(20), // Optional: Add rounded corners
          child: Image.network(
            imageUrl,
            width: 200, // Adjust size as needed
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error,
                  size:
                      100); // Display an error icon if the image fails to load
            },
          ),
        ),
      ),
    );
  }
}
