import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imgUrl;

  const UserProductItem(this.id, this.title, this.imgUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imgUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => Navigator.of(context)
                  .pushNamed(EditProduct.routeName, arguments: id),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async{
                try{
                  await Provider.of<Products>(context, listen: false).deleteProduct(id);
                }catch(e){
                  scaffold.showSnackBar(
                    SnackBar(content: Text('Deleting failed', textAlign: TextAlign.center,))
                  );
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
