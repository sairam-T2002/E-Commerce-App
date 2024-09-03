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
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: screenWidth,
            height: 20,
            child: const Row(children: [
              Icon(
                Icons.star,
                color: Color.fromARGB(255, 243, 65, 33),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Featured Products',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NerkoOne',
                    fontSize: 20),
              )
            ]),
          ),
        ),

        // const SizedBox(height: 50),
        SizedBox(
          width: screenWidth,
          height: 170,
          child: AutoSlideshow(
            children: _widgetsList,
          ),
        )
      ],
    );
  }
}

class CategoryView extends StatefulWidget {
  final double widgetWidth;
  const CategoryView({super.key, required this.widgetWidth});
  @override
  CategoryViewState createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.widgetWidth,
      height: 80,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 241, 198),
        border: Border.all(
          width: 1.0,
          color: const Color.fromARGB(255, 243, 65, 33),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('Category 1'),
    );
  }
}
