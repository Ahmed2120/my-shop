import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

class EditProduct extends StatefulWidget {
  static const routeName = '/Edit-product';

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imgUrlFocusNode = FocusNode();
  final _imgUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Product _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imgUrl: '');
  var _initialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imgUrl': ''
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imgUrlFocusNode.addListener(_updateImgUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final ProductId = ModalRoute.of(context)!.settings.arguments.toString();
      _editedProduct =
          Provider.of<Products>(context).findProduct(id: ProductId);
      _initialValues = {
        'title': _editedProduct.title,
        'description': _editedProduct.description,
        'price': _editedProduct.price.toString(),
        'imgUrl': ''
      };
      _imgUrlController.text = _editedProduct.imgUrl;
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imgUrlFocusNode.removeListener(_updateImgUrl);
    _priceFocusNode.dispose();
    _imgUrlFocusNode.dispose();
    _imgUrlController.dispose();
    _descriptionFocusNode.dispose();
  }

  void _updateImgUrl() {
    if (!_imgUrlFocusNode.hasFocus) {
      if (!_imgUrlController.text.startsWith('http') &&
              !_imgUrlController.text.startsWith('https') ||
          !_imgUrlController.text.endsWith('.png') ||
          !_imgUrlController.text.endsWith('jpg') ||
          !_imgUrlController.text.endsWith('jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred'),
                  content: Text('Something went wrong.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Ok'))
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initialValues['title'] as String,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide value';
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: value!,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imgUrl: _editedProduct.imgUrl);
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues['price'] as String,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(value!),
                            imgUrl: _editedProduct.imgUrl);
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValues['description'] as String,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_imgUrlFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid description';
                        }
                        if (value.length <= 10) {
                          return 'Should be at least 10 characters long.';
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: value!,
                            price: _editedProduct.price,
                            imgUrl: _editedProduct.imgUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imgUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imgUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imgUrlController,
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            focusNode: _imgUrlFocusNode,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a image URL';
                              }
                              if (!_imgUrlController.text.startsWith('http') &&
                                  !_imgUrlController.text.startsWith('https')) {
                                return 'Please enter a valid image URL';
                              }
                              if (!_imgUrlController.text.endsWith('png') &&
                                      !_imgUrlController.text.endsWith('jpg') &&
                                  !_imgUrlController.text.endsWith('jpeg')) {
                                return 'Please enter a valid image URL';
                              }
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imgUrl: value!);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
