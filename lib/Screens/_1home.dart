import 'package:flutter/material.dart';
import 'package:my_app/Dto/_apiobjects.dart';
import 'package:my_app/Shared/_apimanager.dart';
import '../Shared/_card.dart';
import '../Shared/_slideshow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  int i = 0;
  List<Widget> _widgetsList = [];

  Future<void> updateStateFromApi() async {
    Map<String, dynamic>? response =
        await fetchApiGET('api/AppData/GetHomePageData', null);
    List<Widget> temp = [];
    List<dynamic>? featuredPd = response?['featuredProducts'];
    if (featuredPd != null) {
      for (var item in featuredPd) {
        temp.add(ProductCard(
          product: ProductDto(
            prdId: item['product_Id'] ?? '',
            name: item['product_Name'] ?? '',
            isVeg: item['isVeg'] ?? true,
            isBestSeller: item['isBestSeller'] ?? false,
            price: item['price'] ?? 0,
            imageSrl: 1,
            categoryId: item['category_Id'] ?? 0,
            imgUrl: item['image_Url'] ?? '',
            stockCount: item['stockCount'],
            rating: double.parse(item['rating'].toString()),
            description: '',
          ),
        ));
      }
    }
    setState(() {
      _widgetsList = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    updateStateFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return AutoSlideshow(
      children: _widgetsList,
    );
  }
}
