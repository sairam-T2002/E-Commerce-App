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

  const SearchScreen({
    required this.categoryName,
    required this.imageUrl,
    super.key,
  });

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
  late List<String> categories;
  Map<int, List<ProductDto>> tabContents = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    categories = ['All', ...ref.read(categoryProvider)];
    _fetchData(categories.indexOf(widget.categoryName));
  }

  Future<void> _fetchData(int index) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      var result = await fetchApiGET(
          'api/AppData/GetSearchResults/${categories[index]}', null);

      if (mounted) {
        setState(() {
          tabContents[index] = _parseProducts(result?['result'] ?? []);
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          tabContents[index] = [];
          isLoading = false;
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

  Widget _buildContentWidget(List<ProductDto> products, int categoryIndex) {
    return products.isEmpty
        ? const Center(child: Text('No products found'))
        : ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCardN(
                product: products[index],
                accent:
                    Colors.primaries[categoryIndex % Colors.primaries.length],
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
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
              child: Image.network(
                widget.imageUrl,
                width: screenWidth,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: AnimatedSearchBar(
            width: screenWidth - 50,
            onSearch: (e) {
              // Implement search functionality
            },
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: AnimatedTabWidget(
            tabs: categories,
            initialIndex: categories.indexOf(widget.categoryName),
            tabContentBuilders: List.generate(
              categories.length,
              (index) => () {
                return isLoading && !tabContents.containsKey(index)
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContentWidget(tabContents[index] ?? [], index);
              },
            ),
            onTabSelected: (index) async {
              if (!tabContents.containsKey(index)) {
                await _fetchData(index);
              }
            },
          ),
        ),
      ],
    );
  }
}
