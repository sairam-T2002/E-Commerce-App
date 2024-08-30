import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<SearchScreen> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return PageView();
  }
}
