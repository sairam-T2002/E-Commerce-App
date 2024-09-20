import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Dto/_apiobjects.dart';
import '../Shared/_globalstate.dart';

class ProductCardN extends ConsumerWidget {
  final ProductDto product;
  final Color accent;

  const ProductCardN({
    super.key,
    required this.product,
    this.accent = const Color.fromARGB(255, 243, 65, 33),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                                  color: product.isVeg ?? false
                                      ? Colors.green
                                      : Colors.red,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: product.isVeg ?? false
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (product.isBestSeller ?? false)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xffd0dcaa),
                                ),
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                child: const Row(children: [
                                  Icon(
                                    Icons.fire_extinguisher,
                                    color: Colors.amber,
                                  ),
                                  Text(
                                    'Best Seller!',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 56, 56, 56),
                                        fontSize: 10),
                                  ),
                                ]),
                              )
                          ],
                        ),
                        Text(
                          product.name ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                              fontFamily: 'NerkoOne'),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating: product.rating ?? 0.0,
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
                              onRatingUpdate: (rating) {},
                              itemSize: 10.0,
                              unratedColor: Colors.grey[300],
                              glow: false,
                              glowColor: Colors.amber.withOpacity(0.5),
                              ignoreGestures: true,
                            ),
                            Text(
                              '(${product.ratingCount ?? ''})',
                              style: TextStyle(
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '₹${product.price ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imgUrl ?? '',
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
                          child: CardActionsN(
                            product: product,
                            accent: accent,
                          ),
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

class CardActionsN extends ConsumerWidget {
  final ProductDto product;
  final Color accent;
  const CardActionsN({super.key, required this.product, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double width = 120.0;
    const double height = 40.0;
    Color backgroundColor = accent;

    final cartItems = ref.watch(cartProvider);
    final cartItem = cartItems.firstWhere(
      (item) => item.productId == product.prdId,
      orElse: () => ProductCart(
          productName: '', productId: null, price: 0, categoryId: 0, count: 0),
    );

    if (cartItem.count == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: () {
            ref.read(cartProvider.notifier).addToCart(ProductCart(
                productName: product.name ?? '',
                productId: product.prdId,
                price: product.price ?? 0,
                categoryId: 0, // Assuming category ID, adjust as needed
                count: 1));
          },
          style: ElevatedButton.styleFrom(
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
            _buildActionButton('-', () {
              if (cartItem.count > 1) {
                ref
                    .read(cartProvider.notifier)
                    .updateQuantity(product.prdId, cartItem.count - 1);
              } else {
                ref.read(cartProvider.notifier).removeFromCart(product.prdId);
              }
            }),
            Text(
              '${cartItem.count}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            _buildActionButton('+', () {
              ref
                  .read(cartProvider.notifier)
                  .updateQuantity(product.prdId, cartItem.count + 1);
            }),
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
          backgroundColor: accent,
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
