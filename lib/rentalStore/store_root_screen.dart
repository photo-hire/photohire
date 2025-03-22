import 'package:flutter/material.dart';
import 'package:photohire/rentalStore/orders_screen.dart';
import 'package:photohire/rentalStore/rental_store_home_screen.dart';
import 'package:photohire/rentalStore/store_add_product_screen.dart';
import 'package:photohire/rentalStore/store_profile_screen.dart';

class StoreRootScreen extends StatefulWidget {
  const StoreRootScreen({super.key});

  @override
  State<StoreRootScreen> createState() => _StoreRootScreenState();
}

class _StoreRootScreenState extends State<StoreRootScreen> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    RentalStoreHomeScreen(),
    StoreAddProductScreen(),
    OrdersScreen(),
    StoreProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() => selectedIndex = index),
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: "Profile"),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(size: 32),
        unselectedIconTheme: IconThemeData(size: 28),
        elevation: 5,
      ),
      body: pages[selectedIndex],
    );
  }
}
