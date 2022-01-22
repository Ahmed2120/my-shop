import 'package:flutter/material.dart';
import 'package:my_shop/widgets/app_drawer.dart';

class ProductOverview extends StatefulWidget {
  static const routeName = '/Product-overview';

  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
      ),
      drawer: AppDrawer(),
    );
  }
}
