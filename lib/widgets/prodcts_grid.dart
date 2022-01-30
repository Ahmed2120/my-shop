import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/widgets/product_item.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {
  final bool _showFav;

  const ProductGrid(this._showFav);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = _showFav ? productData.favoriteItems : productData.items;
    return products.isEmpty
        ? Center(
            child: Text('There is no product'),
          )
        : GridView.builder(
      padding: EdgeInsets.all(10),
            itemCount: products.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: ProductItem(),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                childAspectRatio: 3 / 2,
                mainAxisSpacing: 10),
          );
  }
}
