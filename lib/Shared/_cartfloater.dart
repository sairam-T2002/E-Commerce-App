import 'package:flutter/material.dart';
import './_globalstate.dart';

class Floater extends StatelessWidget {
  final List<ProductCart> cart;
  final void Function(int, String, String)? callback;
  const Floater({super.key, required this.cart, required this.callback});

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate total cart amount
    final int totalAmount =
        cart.fold(0, (sum, item) => sum + (item.price * item.count));

    // Get the last two items from the cart
    final List<ProductCart> lastTwoItems =
        cart.length > 2 ? cart.sublist(cart.length - 2) : cart;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.15, // Limit height to 15% of screen height
        ),
        child: Card(
          color: const Color.fromARGB(255, 243, 65, 33),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: lastTwoItems.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final ProductCart item = entry.value;
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            left: index * constraints.maxWidth * 0.2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                item.imageUrl,
                                width: constraints.maxWidth * 0.5,
                                height: constraints.maxWidth * 0.5,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, size: 30),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total: ₹$totalAmount',
                        style: const TextStyle(
                          color: Colors.white, // Set the text color to red
                        ),
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {
                          if (callback != null) {
                            callback!(2, '', '');
                          }
                        },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
