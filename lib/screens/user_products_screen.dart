import 'package:flutter/material.dart';
import 'package:my_shop/widgets/app_drawer.dart';

class UserProduct extends StatelessWidget {
  static const routeName = '/User-product';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(),
    );
  }
}