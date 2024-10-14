import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Screens/_1home.dart';
import 'Screens/_4orders.dart';
import 'Screens/_2search.dart';
import 'Shared/_globalstate.dart';
import 'login.dart';
import './nointernet.dart';
import 'profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import './Shared/_localstorage.dart';
import './Shared/_apimanager.dart';

class AppScreen extends ConsumerStatefulWidget {
  const AppScreen({super.key});

  @override
  ConsumerState<AppScreen> createState() => AppScreenState();
}

class AppScreenState extends ConsumerState<AppScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() async {
    final config = await fetchApiGET('api/AppData/GetAppConfig', null);
    if (config != null) {
      await UserDataHelper.storeUserData(LocalStorageKeys.appConfig, config);
    }
  }

  Future<String?> _getGoogleMapsApiKey() async {
    final apiKeyData =
        await UserDataHelper.getUserData(LocalStorageKeys.appConfig);
    return apiKeyData?['googleMapsApiKey'];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
        builder: (context) => _buildScreen(index, 'All', ''),
      ));
    }
  }

  Widget _buildScreen(int index, String category, String imageUrl) {
    switch (index) {
      case 0:
        return HomeScreen(
          callback: screenNavigationCallback,
          logoutCallback: _handleLogout,
          noInternet: _handleNoInternet,
        );
      case 1:
        return SearchScreen(
          categoryName: category,
          imageUrl: imageUrl,
          logoutCallback: _handleLogout,
          noInternet: _handleNoInternet,
        );
      case 2:
        return const Center(child: Text('Cart Page'));
      case 3:
        return OrdersScreen(
          logoutCallback: _handleLogout,
          noInternet: _handleNoInternet,
        );
      default:
        return const Center(child: Text('Home'));
    }
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _handleNoInternet() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NoInternetScreen()),
    );
  }

  void screenNavigationCallback(int index, String category, String imageUrl) {
    setState(() {
      _selectedIndex = index;
    });
    _navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => _buildScreen(index, category, imageUrl),
    ));
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied permissions
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
  }

  void _showDrawer() async {
    final apiKey = await _getGoogleMapsApiKey();
    print(apiKey);
    if (apiKey == null && mounted) {
      // Handle missing API key
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Maps API key not found')),
      );
      return;
    }

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
                initialChildSize: 0.9,
                minChildSize: 0.5,
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
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentLocation ?? const LatLng(0, 0),
                              zoom: 15,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                              _getCurrentLocation();
                            },
                            markers: _currentLocation != null
                                ? {
                                    Marker(
                                      markerId:
                                          const MarkerId('current_location'),
                                      position: _currentLocation!,
                                    ),
                                  }
                                : {},
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Address Line 1',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Address Line 2',
                                  border: OutlineInputBorder(),
                                ),
                              ),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const Profile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final int cartCount = cartItems.fold(0, (sum, item) => sum + item.count);
    return Scaffold(
      appBar: _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3
          ? null
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              leadingWidth: 200,
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
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => _buildScreen(_selectedIndex, 'All', ''),
          );
        },
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
            icon: Icon(Icons.online_prediction_rounded),
            label: 'Orders',
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
