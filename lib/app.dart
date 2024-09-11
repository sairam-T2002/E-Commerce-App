import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Screens/_1home.dart';
import 'Screens/_4profile.dart';
import 'Screens/_2search.dart';
import 'Shared/_globalstate.dart';

class AppScreen extends ConsumerStatefulWidget {
  const AppScreen({super.key});

  @override
  ConsumerState<AppScreen> createState() => AppScreenState();
}

class AppScreenState extends ConsumerState<AppScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  String _category = '';

  void screenNavigationCallback(int index, String category) {
    setState(() {
      _selectedIndex = index;
      _category = category;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showDrawer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: const Color(0xff757175).withOpacity(0.3),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.2,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: controller,
                            children: const [
                              ListTile(title: Text('Drawer Item 1')),
                              ListTile(title: Text('Drawer Item 2')),
                              ListTile(title: Text('Drawer Item 3')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleRightActionButton() {
    // Add your right action button logic here
    print('Right action button pressed');
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(
        callback: screenNavigationCallback,
      ),
      const SearchScreen(),
      const Text('Cart Page'),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leadingWidth:
            200, // Adjust this value to change the width of the left side
        leading: InkWell(
          onTap: _showDrawer,
          splashColor: const Color(0xffcfcfd1),
          highlightColor: const Color(0xfff1f0f1),
          radius: 100,
          child: const Row(
            children: [
              SizedBox(width: 16),
              Icon(
                Icons.place,
                color: Color.fromARGB(255, 87, 87, 87),
                size: 28,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: TextStyle(
                        color: Color.fromARGB(255, 87, 87, 87),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '123 Main St, City',
                      style: TextStyle(
                        color: Color.fromARGB(255, 87, 87, 87),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Color.fromARGB(255, 87, 87, 87),
            ),
            iconSize: 28,
            onPressed: _handleRightActionButton,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              backgroundColor: const Color.fromARGB(255, 243, 65, 33),
              isLabelVisible: cartCount > 0,
              label: Text(
                '$cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 243, 65, 33),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
