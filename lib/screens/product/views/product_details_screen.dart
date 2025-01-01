import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import '../../../components/review_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.collection,
  });

  final String productId;
  final String collection;


  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoading = true;
  ProductModel? _product;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
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
                        actions: [],
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
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(
                                  left: defaultPadding,
                                  right: index == 4 ? defaultPadding : 0),
                              child: ProductCard(
                                image: productDemoImg2,
                                title: "Sleeveless Tiered Dobby Swing Dress",
                                brandName: "LIPSY LONDON",
                                price: 24.65,
                                priceAfetDiscount: index.isEven ? 20.99 : null,
                                dicountpercent: index.isEven ? 25 : null,
                                press: () {},
                              ),
                            ),
                          ),
                        ),
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
