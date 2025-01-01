// For demo only
import 'package:shop/constants.dart';
import 'package:uuid/uuid.dart';
class ProductModel {
  final String id; // ID của sản phẩm
  final String image; // URL của hình ảnh sản phẩm
  final String title; // Tên sản phẩm
  final double price; // Giá sản phẩm
  final double? priceAfetDiscount; // Giá sau khi giảm (nếu có)
  final int? dicountpercent; // Phần trăm giảm giá (nếu có)
  final String? describe; // Mô tả sản phẩm
  final String ownerId; // ID của người sở hữu (người bán)
  final String? category; // Danh mục của sản phẩm
  final String? createdAt; // Ngày tạo sản phẩm dưới dạng chuỗi
  final String brandName; // Tên thương hiệu của sản phẩm

  ProductModel({
    required this.id,
    required this.image,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.describe,
    required this.ownerId,
    this.category,
    this.createdAt,
    required this.brandName,
  });

  // Chuyển từ Firestore Document thành ProductModel
  factory ProductModel.fromFirestore(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] as String,
      image: data['image'] as String,
      title: data['title'] as String,
      price: (data['price'] as num).toDouble(),
      priceAfetDiscount: data['priceAfetDiscount'] != null
          ? (data['priceAfetDiscount'] as num).toDouble()
          : null,
      dicountpercent: data['dicountpercent'] as int?,
      describe: data['describe'] as String?,
      ownerId: data['ownerId'] as String,
      category: data['category'] as String?,
      createdAt: data['createdAt'] as String?,
      brandName: data['brandName'] as String,
    );
  }

  // Chuyển từ ProductModel thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'price': price,
      'priceAfetDiscount': priceAfetDiscount,
      'dicountpercent': dicountpercent,
      'describe': describe,
      'ownerId': ownerId,
      'category': category,
      'createdAt': createdAt,
      'brandName': brandName,
    };
  }
}

List<ProductModel> demoPopularProducts = [
  ProductModel(
    image: "https://cellphones.com.vn/sforum/wp-content/uploads/2024/01/top-5-game-mobile-moi-2.jpg",
    title: "Mountain Warehouse for Women",
    brandName: "Lipsy london",
    price: 540,
    priceAfetDiscount: 420,
    dicountpercent: 20,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: "https://i.imgur.com/h2LqppX.png",
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
];
List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
];
List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: "https://i.imgur.com/h2LqppX.png",
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
    id: const Uuid().v4(),
    ownerId: 'user2@example.com',
  ),
];

