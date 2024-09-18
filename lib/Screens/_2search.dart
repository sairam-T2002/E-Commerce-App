import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/Shared/_globalstate.dart';
import '../Shared/_animatedsearch.dart';
import '../Shared/_animatedtabs.dart';
import '../Shared/_apimanager.dart';
import '../Shared/_cardnew.dart';
import 'package:my_app/Dto/_apiobjects.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String categoryName;
  final String imageUrl;
  final Function logoutCallback;

  const SearchScreen({
    required this.categoryName,
    required this.imageUrl,
    required this.logoutCallback,
    super.key,
  });

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
  late List<String> categories;
  Map<int, List<ProductDto>> tabContents = {};
  bool isLoading = false;
  int selectedCategory = 0;
  String searchQuery = '';
  Map<String, String> bannerImgs = {};
  late String categoryName;
  final ScrollController _scrollController = ScrollController();
  double scrollProgession = 0;

  @override
  void initState() {
    categoryName = widget.categoryName;
    super.initState();
    categories = ['All', ...ref.read(categoryProvider)];
    _fetchData(categories.indexOf(widget.categoryName));
    _scrollController.addListener(() {
      setState(() {
        scrollProgession = _scrollController.offset / 200;
      });
      if (_scrollController.offset > 200) {
        _scrollController.jumpTo(200);
      }
    });
  }

  Future<void> _fetchData(int index) async {
    if (!mounted) return;

    try {
      var result = await fetchApiGET(
          'api/AppData/GetSearchResults/${categories[index]}', null);

      if (mounted) {
        setState(() {
          String resBanner = result?['categoryImageUrl'].toString() ?? '';
          bannerImgs[result?['categoryName'] ?? ''] =
              resBanner.isNotEmpty ? resBanner : ref.read(defaultImgProvider);
          tabContents[index] = _parseProducts(result?['result'] ?? []);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          tabContents[index] = [];
        });
      }
    }
  }

  List<ProductDto> _parseProducts(List<dynamic> data) {
    return data
        .map((item) => ProductDto(
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
            ))
        .toList();
  }

  List<ProductDto> _getFilteredProducts(int categoryIndex) {
    List<ProductDto> products = tabContents[categoryIndex] ?? [];
    if (searchQuery.isEmpty) {
      return products;
    }
    return products
        .where((product) =>
            product.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
            false)
        .toList();
  }

  Widget _buildContentWidget(List<ProductDto> products, int categoryIndex) {
    List<ProductDto> filteredProducts = _getFilteredProducts(categoryIndex);
    return filteredProducts.isEmpty
        ? const Center(child: Text('No products found'))
        : ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              return ProductCardN(
                product: filteredProducts[index],
                accent:
                    Colors.primaries[categoryIndex % Colors.primaries.length],
              );
            },
          );
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _tabSelected(index) async {
    setState(() {
      selectedCategory = index;
      categoryName = categories[index];
      isLoading = true;
    });
    if (!tabContents.containsKey(index)) {
      await _fetchData(index);
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<Widget Function()> products = List.generate(
      categories.length,
      (index) => () {
        return isLoading && !tabContents.containsKey(index)
            ? const Center(child: CircularProgressIndicator())
            : _buildContentWidget(tabContents[index] ?? [], index);
      },
    );

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.categoryName,
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: (bannerImgs[categoryName] ?? '') != ''
                        ? Opacity(
                            opacity: scrollProgession < 200
                                ? 1 - scrollProgession
                                : 0,
                            child: Image.network(
                              bannerImgs[categoryName] ?? '',
                              width: screenWidth,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            heightFactor: 5.55,
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: AnimatedSearchBar(
                  width: screenWidth - 50,
                  accent: Colors
                      .primaries[selectedCategory % Colors.primaries.length],
                  onSearch: _handleSearch,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        SliverFillRemaining(
          child: AnimatedTabWidget(
            tabs: categories,
            initialIndex: categories.indexOf(widget.categoryName),
            tabContentBuilders: products,
            onTabSelected: _tabSelected,
            hideTabs: scrollProgession == 1,
          ),
        ),
      ],
    );
  }
}
