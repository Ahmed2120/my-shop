import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? authToken;
  String userId = '';

  getData(String authToken, String userId, List<Product> products) {
    authToken = authToken;
    userId = userId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    return _items;
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findProduct({required String id}) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    final filteredString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://shop-bef9b-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filteredString';

    try {
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body);
      if (extractedData == null) {
        return;
      }
      url =
          'https://shop-bef9b-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favRes = await http.get(Uri.parse(url));
      final favData = json.decode(favRes.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imgUrl: prodData['imgUrl'],
            isFavorite: favData == null ? false : favData[prodId] ?? false));
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-bef9b-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imgUrl': product.imgUrl,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imgUrl: product.imgUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url =  'https://shop-bef9b-default-rtdb.firebaseio.com/products/$userId.json?auth=$authToken';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': updatedProduct.title,
            'description': updatedProduct.description,
            'price': updatedProduct.price,
            'imgUrl': updatedProduct.imgUrl,
          }));
      _items[prodIndex] = updatedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-bef9b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final prodIndex = _items.indexWhere((element) => element.id == id);
    var prod = _items[prodIndex];
    _items.removeAt(prodIndex);
    notifyListeners();
    final res = await http.delete(Uri.parse(url));
    if(res.statusCode >= 400){
      _items.insert(prodIndex, prod);
      notifyListeners();
      throw HttpException("couldn't delete product");
    }
  }
}
