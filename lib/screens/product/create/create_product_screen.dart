import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/product_model.dart';
import 'package:uuid/uuid.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({Key? key}) : super(key: key);

  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceAfterDiscountController =
      TextEditingController();
  final TextEditingController _discountPercentController =
      TextEditingController();

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      final product = ProductModel(
        image: _imageController.text,
        brandName: _brandNameController.text,
        title: _titleController.text,
        price: double.parse(_priceController.text),
        priceAfetDiscount: double.parse(_priceAfterDiscountController.text),
        dicountpercent: int.parse(_discountPercentController.text),
        id: const Uuid().v4(),
        ownerId: prefs.getString('email') ?? "",
      );
      addProduct(product, "products");
    }
    // else{
    // print("Create");
    // uploadProductList(demoPopularProducts, "products");
    // uploadProductList(demoFlashSaleProducts, "products");
    // uploadProductList(demoBestSellersProducts, "products");
    // print("finished");
    //}
  }

  Future<void> uploadProductList(
      List<ProductModel> productList, String collection) async {
    final productCollection = FirebaseFirestore.instance.collection(collection);

    WriteBatch batch =
        FirebaseFirestore.instance.batch(); // Sử dụng batch để tối ưu

    try {
      for (var product in productList) {
        final docRef = productCollection
            .doc(product.id); // Tạo document với ID của sản phẩm
        batch.set(docRef, product.toFirestore());
      }

      await batch.commit(); // Thực hiện đẩy dữ liệu lên Firestore
      print("All products uploaded successfully!");
    } catch (e) {
      print("Error uploading products: $e");
    }
  }

  Future<void> addProduct(ProductModel product, String collection) async {
    // Tham chiếu đến collection 'products' trong Firestore
    final productCollection = FirebaseFirestore.instance.collection(collection);

    try {
      // Tạo document mới với ID từ model hoặc tự sinh
      await productCollection.doc(product.id).set(product.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create product failed!')),
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    _brandNameController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _priceAfterDiscountController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Product'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _showExitDialog,
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _imageController,
                          decoration:
                              const InputDecoration(labelText: 'Image URL'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an image URL';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _brandNameController,
                          decoration:
                              const InputDecoration(labelText: 'Brand Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a brand name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceAfterDiscountController,
                          decoration: const InputDecoration(
                              labelText: 'Price After Discount'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the price after discount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _discountPercentController,
                          decoration: const InputDecoration(
                              labelText: 'Discount Percent'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the discount percent';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: const Text('Save Product'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
