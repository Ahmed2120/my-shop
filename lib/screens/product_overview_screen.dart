import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/badge.dart';
import 'package:my_shop/widgets/prodcts_grid.dart';
import 'package:provider/provider.dart';

enum FilterOption { Favorites, All }

class ProductOverview extends StatefulWidget {
  static const routeName = '/Product-overview';

  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  bool _isLoading = false;
  bool _showOnlyFav = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProduct()
        .then((_) => setState(() {
              _isLoading = false;
            })).catchError((e)=> setState(() {
      _isLoading = false;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selectedVal) {
              setState(() {
                if (selectedVal == FilterOption.Favorites)
                  _showOnlyFav = true;
                else
                  _showOnlyFav = false;
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Show All Products'),
                value: FilterOption.All,
              ),
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.Favorites,
              ),
            ],
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
            builder: (_, cart, ch)=> Badge(value: cart.itemCount.toString(), child: ch!),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : ProductGrid(_showOnlyFav),
    );
  }
}
