import 'package:flutter/material.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          offset: Offset(2, 1),
          blurRadius: 4,
          //spreadRadius: 0.1,
          color: Colors.black54
        )]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(ProductDetail.routeName, arguments: product.id),
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(
                  product.imgUrl,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            leading: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  product.toggleFavoriteStatus(authData.token, authData.userId);
                },
              ),
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Added to cart'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () => cart.removeSingleItem(product.id),
                  ),
                ));
              },
            ),
          ),
        ),
      ),
    );
  }
}
