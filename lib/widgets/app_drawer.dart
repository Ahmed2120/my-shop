import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:my_shop/screens/user_products_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Shop'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            title: Text('Shop'),
            leading: Icon(Icons.shop),
            onTap: ()=> Navigator.of(context).pushReplacementNamed('/'),
          ),
          Divider(),
          ListTile(
            title: Text('Orders'),
            leading: Icon(Icons.payment),
            onTap: ()=> Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName),
          ),
          Divider(),
          ListTile(
            title: Text('Manage Product'),
            leading: Icon(Icons.edit),
            onTap: ()=> Navigator.of(context).pushReplacementNamed(UserProduct.routeName),
          ),
          Divider(),
          Spacer(),
          Divider(),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: (){
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
