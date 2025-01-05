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
  final TextEditingController _describePercentController =
      TextEditingController();

  bool _isSaving = false; // Trạng thái loading khi nhấn nút Save

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true; // Bắt đầu loading
      });

      final prefs = await SharedPreferences.getInstance();

      final product = ProductModel(
        image: _imageController.text,
        brandName: _brandNameController.text,
        title: _titleController.text,
        price: double.parse(_priceController.text),
        priceAfetDiscount: double.tryParse(_priceAfterDiscountController.text),
        describe: _describePercentController.text,
        id: const Uuid().v4(),
        ownerId: prefs.getString('email') ?? "",
        createdAt: DateTime.now().toString(),
      );

      try {
        await addProduct(product, "products");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully!')),
        );

        Navigator.of(context).pop(true); // Quay lại khi lưu thành công
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Create product failed: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false; // Tắt loading
        });
      }
    }
  }

  Future<void> addProduct(ProductModel product, String collection) async {
    final productCollection = FirebaseFirestore.instance.collection(collection);

    try {
      await productCollection.doc(product.id).set(product.toFirestore());
    } catch (e) {
      throw Exception('Error creating product: $e');
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
    _describePercentController.dispose();
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
                          controller: _describePercentController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Describe',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProduct,
                    child: _isSaving
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Save Product'),
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
