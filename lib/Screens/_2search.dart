import 'package:flutter/material.dart';
import '../Shared/_animatedsearch.dart';

class SearchScreen extends StatelessWidget {
  final String categoryName;
  final String imageUrl;

  const SearchScreen({
    required this.categoryName,
    required this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Hero(
          tag: categoryName,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              width: screenWidth,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 100);
              },
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        AnimatedSearchBar(
          width: 300,
          onSearch: (e) {},
        ),
      ],
    );
  }
}
