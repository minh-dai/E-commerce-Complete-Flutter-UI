import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/param_product.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

import '../../../constants.dart';

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({super.key});

  @override
  State<MyProductScreen> createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {
  bool _isLoading = true;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy email từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      if (email == null) {
        setState(() {
          _isLoading = false;
        });
        throw Exception("Email not found in SharedPreferences");
      }

      // Truy vấn sản phẩm từ Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('ownerId', isEqualTo: email)
          .get();

      // Chuyển đổi dữ liệu sang danh sách sản phẩm
      setState(() {
        _products = snapshot.docs
            .map((doc) =>
                ProductModel.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    await _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshProducts,
              child: _products.isEmpty
                  ? const Center(
                      child: Text("You haven't added any products yet."),
                    )
                  : CustomScrollView(
                      slivers: [
                        const SliverPadding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              "Your Items:",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding,
                              vertical: defaultPadding),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200.0,
                              mainAxisSpacing: defaultPadding,
                              crossAxisSpacing: defaultPadding,
                              childAspectRatio: 0.66,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final product = _products[index];
                                return ProductCard(
                                  image: product.image,
                                  brandName: product.brandName,
                                  title: product.title,
                                  price: product.price,
                                  priceAfetDiscount: product.priceAfetDiscount,
                                  dicountpercent: product.dicountpercent,
                                  press: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      productDetailsScreenRoute,
                                      arguments: ParamProduct(
                                        productId: product.id,
                                        callBack: _fetchProducts,
                                      ),
                                    );
                                    if (result == true) {
                                      _fetchProducts();
                                    }
                                  },
                                );
                              },
                              childCount: _products.length,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, createProduct);
          if (result == true) {
            _fetchProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
