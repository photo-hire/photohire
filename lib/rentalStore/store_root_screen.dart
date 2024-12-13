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

  List<Widget> pages =[
    RentalStoreHomeScreen(),
    StoreAddProductScreen(),
    OrdersScreen(),
    StoreProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10)
        ),
        child: BottomNavigationBar(
          
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items:[
            BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outlined),label: "idea",),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline),label: "add",),
            BottomNavigationBarItem(icon: Icon(Icons.layers),label: "orders",),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined),label: "profile",),
          ] ,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.white,
          selectedIconTheme: IconThemeData(
            size: 40
          ),
          unselectedItemColor:Colors.white,
          backgroundColor: Colors.blue[900],
          currentIndex: selectedIndex,
          ),
      ),
        body: pages[selectedIndex],
    );
  }
}