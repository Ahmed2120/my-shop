import 'package:flutter/material.dart';
import 'package:my_shop/widgets/order_item.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import 'package:my_shop/providers/orders.dart' show Orders;

class OrdersScreen extends StatelessWidget {
  static const routeName = '/Orders-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrder(),
        builder: (ctx, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else{
            if(snapshot.error != null){
              print(snapshot.error);
              return Center(child: Text('An error occurred'),);
            }else{
              return Consumer<Orders>(
                builder: (ctx, orderData, child)=> ListView.builder(
                  itemCount: orderData.items.length,
                  itemBuilder: (context, index) => OrderItem(orderData.items[index]),
                ),
              );
            }
          }
        },
      ),

    );
  }
}