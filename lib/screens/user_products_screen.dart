import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProduct extends StatelessWidget {
  static const routeName = '/User-product';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Product'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, AsyncSnapshot snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                        builder: (ctx, producs, _) => Padding(
                              padding: EdgeInsets.all(8),
                              child: ListView.builder(
                                itemCount: producs.items.length,
                                itemBuilder: (_, index)=> Column(
                                  children: [
                                    UserProductItem(
                                      producs.items[index].id,
                                      producs.items[index].title,
                                      producs.items[index].imgUrl
                                    ),
                                    Divider(),

                                  ],
                                ),
                              ),
                            )),
                  ),
      ),
    );
  }
}
