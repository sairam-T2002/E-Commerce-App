import 'package:flutter/material.dart';
import 'package:my_app/Dto/_apiobjects.dart';
import '../Shared/_card.dart';
import '../Shared/_slideshow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  int i = 0;
  ProductDto temp = ProductDto(
      prdId: -1,
      name: 'Product 1',
      isVeg: true,
      isBestSeller: true,
      price: 0,
      imageSrl: 1,
      categoryId: 2,
      imgUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
      stockCount: 5,
      rating: 4.2,
      description: 'test description');

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetsList = [
      ProductCard(
        product: temp,
      ),
      ProductCard(
        product: temp,
      ),
      ProductCard(
        product: temp,
      )
    ];
    return AutoSlideshow(
      children: widgetsList,
    );
  }
}
