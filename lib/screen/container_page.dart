import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/screen/cart_screen.dart';
import 'package:prabodham/screen/dashboard_screen.dart';
import 'package:prabodham/screen/favourites_screen.dart';
import 'package:prabodham/screen/setting_screen.dart';
import 'package:prabodham/screen/shop_screen.dart';
import 'package:prabodham/widgets/custom_navigation_bar.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({Key key}) : super(key: key);

  @override
  _ContainerPageState createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  List<Widget> _body = [
    DashboardScreen(),
    ShopScreen(),
    CartScreen(
      showBackButton: false,
    ),
    FavouriteScreen(),
    SettingScreen()
  ];
  int _selectedScreen = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body[_selectedScreen],
      bottomNavigationBar: CustomNavigationBar(
          context: context,
          selectedScreen: _selectedScreen,
          onTap: (value) {
            setState(() {
              _selectedScreen = value;
            });
          }),
    );
  }
}
