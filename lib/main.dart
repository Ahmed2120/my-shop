import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
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
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(),
            update: (ctx, authValue, previousProducts) => previousProducts!
              ..getData(
                  authValue.token, authValue.userId, previousProducts.items)),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(),
            update: (ctx, authValue, previousProducts) => previousProducts!
              ..getData(
                  authValue.token, authValue.userId, previousProducts.items)),
        ChangeNotifierProvider.value(value: Cart()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato'),
          home: auth.isAuth
              ? ProductOverview()
              : FutureBuilder(
                  future: auth.tryAutoLogIn(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductOverview.routeName: (_) => ProductOverview(),
            CartScreen.routeName: (_) => CartScreen(),
            EditProduct.routeName: (_) => EditProduct(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            UserProduct.routeName: (_) => UserProduct(),
            ProductDetail.routeName: (_) => ProductDetail(),
            AuthScreen.routeName: (_) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
