import 'package:flutter/material.dart';
import 'Screens/_1home.dart';
import 'Screens/_4profile.dart';
import 'Screens/_2search.dart';
import 'Shared/_globalstate.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  AppScreenState createState() => AppScreenState();
}

class AppScreenState extends State<AppScreen> {
  int _selectedIndex = 0;
  final GlobalState globalState = GlobalState();

  // List of pages
  List<Widget> _widgetOptions = [];

  void screenNavigationCallback(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _widgetOptions = <Widget>[
        HomeScreen(
          callback: screenNavigationCallback,
        ),
        const SearchScreen(),
        const Text('Cart Page'),
        const ProfileScreen(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Navigation Example')),
      body: IndexedStack(
        index:
            _selectedIndex, // Use IndexedStack to maintain the state of each screen
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
              isLabelVisible: globalState.cart.isNotEmpty,
              label: Text(
                '${globalState.cart.length}', // Replace '3' with your cart count variable
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
