import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget CustomNavigationBar({
  BuildContext context,
  int selectedScreen,
  ValueChanged<int> onTap,
}) {
  return BottomNavigationBar(
    onTap: onTap,
    elevation: 10,
    showUnselectedLabels: true,
    unselectedFontSize: 10,
    selectedFontSize: 10,
    currentIndex: selectedScreen,
    selectedItemColor: Theme.of(context).primaryColor,
    unselectedItemColor: Colors.black,
    items: [
      new BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
          backgroundColor: Colors.white),
      new BottomNavigationBarItem(
        icon: Icon(Icons.grid_view),
        label: 'Categories',
      ),
      new BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag_outlined),
        label: 'Cart',
      ),
      new BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        label: 'Favorites',
      ),
      new BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        label: 'Setting',
      ),
    ],
  );
}
