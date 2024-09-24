import 'package:flutter/material.dart';
import 'package:my_app/Dto/_apiobjects.dart';
import 'package:my_app/Shared/_apimanager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Shared/_globalstate.dart';
import '../Shared/_cardnew.dart';
import '../Shared/_slideshow.dart';
import '../Shared/_networkutils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final void Function(int, String, String)? callback;
  final Function logoutCallback;
  final Function noInternet;
  const HomeScreen(
      {super.key,
      this.callback,
      required this.logoutCallback,
      required this.noInternet});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<HomeScreen> {
  int i = 0;
  double screenWidth = 0;
  List<String> _labels = [];
  List<Widget> _widgetsListFP = [];
  List<Widget> _widgetsListCT = [];
  List<Widget> _widgetsListCA = [];
  bool _isLoading = true;

  Future<void> updateStateFromApi() async {
    setState(() {
      _isLoading = true;
    });
    bool isConnected = await NetworkUtils.hasInternetConnection();
    if (!isConnected) {
      widget.noInternet();
      return;
    }
    Map<String, dynamic>? response =
        await fetchApiGET('api/AppData/GetHomePageData', null);
    if (response == null) {
      widget.logoutCallback();
      return;
    }
    List<String> tempLbList = [];
    List<Widget> tempFpList = [];
    List<Widget> tempCtList = [];
    List<Widget> tempCaList = [];
    List<dynamic>? labels = response['label'];
    List<dynamic>? featuredPd = response['featuredProducts'];
    List<dynamic>? categories = response['categories'];
    List<dynamic>? carosel = response['carouselUrls'];
    String defaultImg = response['defaultSearchBanner'].toString();
    if (labels != null && labels.length == 3) {
      tempLbList = labels.cast<String>();
    }
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
                ratingCount: int.parse(item['ratingCount'].toString())),
          ),
        );
      }
    }
    List<String> globCat = ref.read(categoryProvider);
    String globImg = ref.read(defaultImgProvider);
    if (globImg.isEmpty) {
      ref.read(defaultImgProvider.notifier).setDefaultImg(defaultImg);
    }
    if (categories != null) {
      for (var item in categories) {
        if (globCat.isEmpty) {
          ref
              .read(categoryProvider.notifier)
              .addToCategory(item?['category_Name'] ?? '');
        }

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
                return const Icon(Icons.error, size: 100);
              },
            ),
          ),
        );
      }
    }
    setState(() {
      _labels = tempLbList;
      _widgetsListFP = tempFpList;
      _widgetsListCT = tempCtList;
      _widgetsListCA = tempCaList;
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    // This method will be called when the user performs a pull-to-refresh action
    await updateStateFromApi();
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
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              FirstSection(
                screenWidth: screenWidth,
                widgetsList: _widgetsListCA,
                label: _labels[0],
              ),
              SecondSection(
                screenWidth: screenWidth,
                widgetList: _widgetsListCT,
                label: _labels[1],
              ),
              const SizedBox(
                height: 10,
              ),
              ThirdSection(
                screenWidth: screenWidth,
                widgetList: _widgetsListFP,
                label: _labels[2],
              ),
            ],
          ),
        ),
      );
    }
  }
}

class FirstSection extends StatefulWidget {
  final double screenWidth;
  final List<Widget> widgetsList;
  final String label;
  const FirstSection(
      {super.key,
      required this.screenWidth,
      required this.widgetsList,
      required this.label});

  @override
  FirstSectionState createState() => FirstSectionState();
}

class FirstSectionState extends State<FirstSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Row(children: [
            const Icon(
              Icons.recommend,
              color: Color.fromARGB(255, 243, 65, 33),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              widget.label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NerkoOne',
                  fontSize: 20),
            )
          ]),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: widget.screenWidth,
            height: 170,
            child: AutoSlideshow(
              children: widget.widgetsList,
            ),
          ),
        ]));
  }
}

class SecondSection extends StatefulWidget {
  final double screenWidth;
  final List<Widget> widgetList;
  final String label;
  const SecondSection(
      {super.key,
      required this.screenWidth,
      required this.widgetList,
      required this.label});

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
            child: Row(children: [
              const Icon(
                Icons.menu_book,
                color: Color.fromARGB(255, 243, 65, 33),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                widget.label,
                style: const TextStyle(
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
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  widget.widgetList.length >= (widget.screenWidth / 140).toInt()
                      ? (widget.screenWidth / 140).toInt()
                      : widget.widgetList.isNotEmpty
                          ? widget.widgetList.length
                          : 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 60,
              mainAxisExtent: 100,
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
  final String label;

  const ThirdSection(
      {super.key,
      required this.screenWidth,
      required this.widgetList,
      required this.label});

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
            child: Row(children: [
              const Icon(
                Icons.star,
                color: Color.fromARGB(255, 243, 65, 33),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                widget.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NerkoOne',
                    fontSize: 20),
              )
            ]),
          ),
        ),
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
  final void Function(int, String, String)? callback;

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
            onTap: () {
              if (widget.callback != null) {
                widget.callback!(1, categoryName, imageUrl);
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
