import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import '../../../components/review_card.dart';
import '../../../route/route_constants.dart';
import '../../home/views/components/most_popular.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.collection,
    this.callBack,
  });

  final String productId;
  final String collection;
  final Function? callBack;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoading = true;
  ProductModel? _product;
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _fetchProductDetails();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _fetchProductDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.collection)
          .doc(widget.productId)
          .get();

      if (snapshot.exists) {
        setState(() {
          _product = ProductModel.fromFirestore(
              snapshot.data() as Map<String, dynamic>);
          _isLoading = false;
        });
        
      } else {
        throw Exception("Product not found");
      }
    } catch (e) {
      print("Error fetching product: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
      Navigator.of(context).pop(); // Quay lại màn hình trước
      if(widget.callBack != null){
        widget.callBack!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }


  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _deleteProduct();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _product == null
                ? const Center(
                    child: Text("Product not found."),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        floating: true,
                        actions: email != _product!.ownerId
                            ? []
                            : [
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    // Xử lý khi một menu item được chọn
                                    if (value == 'edit') {
                                      await Navigator.pushNamed(
                                        context,
                                        updateProduct,
                                        arguments: _product!.id,
                                      );
                                      if(widget.callBack != null){
                                        widget.callBack!();
                                      }
                                      _fetchProductDetails();
                                    } else if (value == 'delete') {
                                      _showDeleteDialog();
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit Product'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete Product'),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                      ),
                      ProductImages(
                        images: [
                          _product!.image,
                          _product!.image,
                          _product!.image
                        ],
                      ),
                      ProductInfo(
                        brand: _product?.brandName ?? "Unknown Brand",
                        title: _product?.title ?? "Unnamed Product",
                        description: _product!.describe ??
                            "No description available for this product.",
                        rating: 3.0,
                        numOfReviews: 200,
                        isAvailable: true,
                      ),
                      ProductListTile(
                        svgSrc: "assets/icons/Return.svg",
                        title: "Returns",
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.92,
                            child: const ProductReturnsScreen(),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(defaultPadding),
                          child: ReviewCard(
                            rating: 4.3,
                            numOfReviews: 128,
                            numOfFiveStar: 80,
                            numOfFourStar: 30,
                            numOfThreeStar: 5,
                            numOfTwoStar: 4,
                            numOfOneStar: 1,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(defaultPadding),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "You may also like",
                            style: Theme.of(context).textTheme.titleSmall!,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: MostPopular(isShowTitle: false),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: defaultPadding),
                      )
                    ],
                  ),
      ),
    );
  }
}
