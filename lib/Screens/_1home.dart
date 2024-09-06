import 'package:flutter/material.dart';
import 'package:my_app/Dto/_apiobjects.dart';
import 'package:my_app/Shared/_apimanager.dart';
// import '../Shared/_card.dart';
import '../Shared/_cardn.dart';
import '../Shared/_slideshow.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? callback;
  const HomeScreen({super.key, this.callback});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  int i = 0;
  double screenWidth = 0;
  List<Widget> _widgetsListFP = [];
  List<Widget> _widgetsListCT = [];
  List<Widget> _widgetsListCA = [];
  bool _isLoading = true;

  Future<void> updateStateFromApi() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic>? response =
        await fetchApiGET('api/AppData/GetHomePageData', null);
    List<Widget> tempFpList = [];
    List<Widget> tempCtList = [];
    List<Widget> tempCaList = [];
    List<dynamic>? featuredPd = response?['featuredProducts'];
    List<dynamic>? categories = response?['categories'];
    List<dynamic>? carosel = response?['carouselUrls'];
    if (featuredPd != null) {
      for (var item in featuredPd) {
        tempFpList.add(
          ProductCardN(
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
          ),
        );
      }
    }
    if (categories != null) {
      for (var item in categories) {
        tempCtList.add(CategoryView(
          screenWidth: screenWidth,
          count: categories.length,
          callback: widget.callback,
          category: {
            'categoryId': item?['category_Id']?.toString() ?? '',
            'categoryName': item?['category_Name'] ?? '',
            'imageurl': item?['image_Url'] ?? ''
          },
        ));
      }
    }
    if (carosel != null) {
      for (var item in carosel) {
        tempCaList.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              item.isNotEmpty ? item : 'https://via.placeholder.com/80',
              width: screenWidth,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(error);
                return const Icon(Icons.error, size: 100);
              },
            ),
          ),
        );
      }
    }
    setState(() {
      _widgetsListFP = tempFpList;
      _widgetsListCT = tempCtList;
      _widgetsListCA = tempCaList;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    updateStateFromApi();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            FirstSection(
              screenWidth: screenWidth,
              widgetsList: _widgetsListCA,
            ),
            SecondSection(
              screenWidth: screenWidth,
              widgetList: _widgetsListCT,
            ),
            const SizedBox(
              height: 10,
            ),
            ThirdSection(
              screenWidth: screenWidth,
              widgetList: _widgetsListFP,
            ),
          ],
        ),
      );
    }
  }
}

class FirstSection extends StatefulWidget {
  final double screenWidth;
  final List<Widget> widgetsList;
  const FirstSection(
      {super.key, required this.screenWidth, required this.widgetsList});

  @override
  FirstSectionState createState() => FirstSectionState();
}

class FirstSectionState extends State<FirstSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: widget.screenWidth,
        height: 170,
        child: AutoSlideshow(
          children: widget.widgetsList,
        ),
      ),
    );
  }
}

class SecondSection extends StatefulWidget {
  final double screenWidth;
  final List<Widget> widgetList;
  const SecondSection({
    super.key,
    required this.screenWidth,
    required this.widgetList,
  });

  @override
  SecondSectionState createState() => SecondSectionState();
}

class SecondSectionState extends State<SecondSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: widget.screenWidth,
            height: 25,
            child: const Row(children: [
              Icon(
                Icons.menu_book,
                color: Color.fromARGB(255, 243, 65, 33),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Categories',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NerkoOne',
                    fontSize: 20),
              )
            ]),
          ),
        ),
        const SizedBox(
          height: 45,
        ),
        Padding(
          padding: const EdgeInsets.all(3),
          child: GridView.builder(
            physics:
                const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
            shrinkWrap:
                true, // Allow GridView to adjust its height based on content
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  widget.widgetList.length >= (widget.screenWidth / 140).toInt()
                      ? (widget.screenWidth / 140).toInt()
                      : widget.widgetList.isNotEmpty
                          ? widget.widgetList.length
                          : 1, // Fixed number of columns
              crossAxisSpacing: 0, // Space between columns
              mainAxisSpacing: 60, // Space between rows
              mainAxisExtent: 100, // Fixed height of each item
            ),
            itemCount: widget.widgetList.length,
            itemBuilder: (context, index) {
              return widget.widgetList[index];
            },
          ),
        ),
      ],
    );
  }
}

class ThirdSection extends StatefulWidget {
  final double screenWidth;
  final List<Widget> widgetList;

  const ThirdSection(
      {super.key, required this.screenWidth, required this.widgetList});

  @override
  ThirdSectionState createState() => ThirdSectionState();
}

class ThirdSectionState extends State<ThirdSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: widget.screenWidth,
            height: 25,
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
          width: widget.screenWidth,
          height: 170,
          child: AutoSlideshow(
            children: widget.widgetList,
          ),
        )
      ],
    );
  }
}

class CategoryView extends StatefulWidget {
  final double screenWidth;
  final int count;
  final Map<String, String> category;
  final void Function(int)? callback;

  const CategoryView({
    super.key,
    required this.screenWidth,
    required this.count,
    required this.category,
    this.callback,
  });

  @override
  CategoryViewState createState() => CategoryViewState();
}

class CategoryViewState extends State<CategoryView> {
  @override
  Widget build(BuildContext context) {
    final String categoryName = widget.category['categoryName'] ?? '';
    final String imageUrl = widget.category['imageurl'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double containerWidth = constraints.maxWidth;

          return GestureDetector(
            // Detects the tap gesture and triggers the callback if provided
            onTap: () {
              if (widget.callback != null) {
                widget.callback!(
                    1); // Pass `count` or any other parameter as needed
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: containerWidth,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xfff7f2fa),
                    border: Border.all(
                      width: 1.0,
                      color: const Color.fromARGB(255, 243, 65, 33),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Positioned(
                  top: -50,
                  left: (containerWidth - 100) / 2,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: const Color.fromARGB(255, 243, 65, 33),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl.isNotEmpty
                            ? imageUrl
                            : 'https://via.placeholder.com/80',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print(error);
                          return const Icon(Icons.error, size: 100);
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'NerkoOne',
                              fontSize: 20,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_circle_right,
                            size: 25,
                            color: Color.fromARGB(255, 243, 65, 33),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
