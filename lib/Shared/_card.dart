import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../Dto/_apiobjects.dart';
import '../Shared/_globalstate.dart';

class ProductCard extends StatefulWidget {
  final ProductDto product;
  const ProductCard({super.key, required this.product});

  @override
  CardState createState() => CardState();
}

class CardState extends State<ProductCard> {
  late bool _isVegan;
  late bool _isBestSeller;
  late int? _productId;
  late String _productName;
  late String _productDescription;
  late double _review;
  late int _price;
  late String _imgUrl;

  @override
  void initState() {
    super.initState();
    _updateProductData();
  }

  void _updateProductData() {
    setState(() {
      _isVegan = widget.product.isVeg ?? false;
      _isBestSeller = widget.product.isBestSeller ?? false;
      _productName = widget.product.name ?? '';
      _productId = widget.product.prdId;
      _productDescription = widget.product.description ?? '';
      _review = widget.product.rating ?? 0.0;
      _price = widget.product.price ?? 0;
      _imgUrl = widget.product.imgUrl ?? '';
    });
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product != oldWidget.product) {
      _updateProductData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      child: Center(
        child: SizedBox(
          width: screenWidth * 0.95,
          height: 170,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _isVegan ? Colors.green : Colors.red,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: CircleAvatar(
                                  radius: 5,
                                  backgroundColor:
                                      _isVegan ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_isBestSeller)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      const Color.fromARGB(255, 243, 226, 175),
                                ),
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                child: const Text(
                                  'Best Seller!',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 56, 56, 56),
                                      fontSize: 10),
                                ),
                              )
                          ],
                        ),
                        Text(
                          _productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _productDescription,
                          style: const TextStyle(fontSize: 8),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating: _review,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                              itemSize: 10.0,
                              unratedColor: Colors.grey[300],
                              glow: false,
                              glowColor: Colors.amber.withOpacity(0.5),
                              ignoreGestures: true,
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹$_price',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 243, 65, 33),
                          ),
                        )
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _imgUrl,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: -6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CardActions(product: widget.product),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardActions extends StatefulWidget {
  final ProductDto product;
  const CardActions({super.key, required this.product});

  @override
  ActionsState createState() => ActionsState();
}

class ActionsState extends State<CardActions> {
  int _count = 0;
  final GlobalState globalState = GlobalState();

  @override
  void initState() {
    super.initState();
    if (globalState.cart.isNotEmpty) {
      _count = globalState.cart
              .firstWhere((item) => item?.productId == widget.product.prdId,
                  orElse: () => null)
              ?.count ??
          0;
    } else {
      _count = 0;
    }
  }

  void _handleAddToCart() {
    setState(() {
      _count++;
      final existingItem = globalState.cart.firstWhere(
        (item) => item?.productId == widget.product.prdId,
        orElse: () => null,
      );

      if (existingItem != null) {
        existingItem.count++;
      } else {
        globalState.cart.add(
          ProductCart(
            productName: widget.product.name ?? '',
            productId: widget.product.prdId,
            price: widget.product.price ?? 0,
            categoryId: widget.product.categoryId ?? 0,
            count: 1,
          ),
        );
      }
    });
  }

  void _handleRemoveFromCart() {
    setState(() {
      if (_count > 0) {
        _count--;
        final existingItem = globalState.cart.firstWhere(
            (item) => item?.productId == widget.product.prdId,
            orElse: () => null);
        if (existingItem != null) {
          existingItem.count--;
          if (existingItem.count == 0) {
            globalState.cart.remove(existingItem);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double width = 120.0;
    const double height = 40.0;
    const Color backgroundColor = Color.fromARGB(255, 243, 65, 33);

    if (_count == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: _handleAddToCart,
          style: ElevatedButton.styleFrom(
            // elevation: 4,
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add To Cart',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    } else {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton('-', _handleRemoveFromCart),
            Text(
              '$_count',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            _buildActionButton('+', _handleAddToCart),
          ],
        ),
      );
    }
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 30,
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color.fromARGB(255, 243, 65, 33),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
