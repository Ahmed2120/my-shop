import 'package:flutter/material.dart';
import './providers/auth.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/product.dart';
import './screens/auth_screen.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/user_products_screen.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Orders()),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProvider.value(value: Product()),
      ],
      child: Consumer<Auth>(
        builder:(ctx, auth, _)=> MaterialApp(
          title: 'Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato'
          ),
          home: auth.isAuth ? ProductOverview() : FutureBuilder(
            future: auth.tryAutoLogIn(),
            builder: (ctx, snapshot)=> snapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),
          ),
          routes: {
            ProductOverview.routeName: (_)=> ProductOverview(),
            CartScreen.routeName: (_)=> CartScreen(),
            EditProduct.routeName: (_)=> EditProduct(),
            OrdersScreen.routeName: (_)=> OrdersScreen(),
            UserProduct.routeName: (_)=> UserProduct(),
            ProductDetail.routeName: (_)=> ProductDetail(),
            AuthScreen.routeName: (_)=> AuthScreen(),
          },
        ),
      ),
    );
  }
}
