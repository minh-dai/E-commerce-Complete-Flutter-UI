import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/models/param_product.dart';
import 'package:shop/route/route_constants.dart';

import '/components/Banner/M/banner_m_with_counter.dart';
import '../../../../components/product/product_card.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';

class FlashSale extends StatelessWidget {
  const FlashSale({
    super.key,
  });
  final String collectionName= "flash_sale_products";


  Future<List<ProductModel>> fetchPopularProducts() async {
    try {
      // Lấy danh sách sản phẩm từ Firestore
      final snapshot =
      await FirebaseFirestore.instance.collection(collectionName).get();

      // Chuyển đổi dữ liệu Firestore thành danh sách ProductModel
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc.data());
      }).toList();
    } catch (e) {
      print("Error fetching popular products: $e");
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Flash sale",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading show 👇
        // const ProductsSkelton(),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<ProductModel>>(
            future: fetchPopularProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Hiển thị loading khi dữ liệu đang tải
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Hiển thị lỗi nếu có
                return const Center(child: Text("Error loading products"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Hiển thị thông báo nếu không có dữ liệu
                return const Center(child: Text("No popular products found"));
              } else {
                // Hiển thị danh sách sản phẩm
                final products = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                      left: defaultPadding,
                      right: index == products.length - 1 ? defaultPadding : 0,
                    ),
                    child: ProductCard(
                      image: products[index].image,
                      brandName: products[index].brandName,
                      title: products[index].title,
                      price: products[index].price,
                      priceAfetDiscount: products[index].priceAfetDiscount,
                      dicountpercent: products[index].dicountpercent,
                      press: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: ParamProduct(
                            productId: products[index].id,
                            collection: collectionName,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
