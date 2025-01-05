import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';

class UpdateProductScreen extends StatefulWidget {
  final String productId;

  const UpdateProductScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Các controller như trước đây
  TextEditingController _imageController = TextEditingController();
  TextEditingController _brandNameController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _priceAfterDiscountController = TextEditingController();
  TextEditingController _describePercentController = TextEditingController();

  bool _isLoading = true; // Cho việc tải dữ liệu sản phẩm ban đầu
  bool _isUpdating = false; // Loading khi update sản phẩm
  ProductModel? _product;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        final data = productDoc.data()!;
        _product = ProductModel.fromFirestore(data);

        setState(() {
          _imageController.text = _product!.image;
          _brandNameController.text = _product!.brandName;
          _titleController.text = _product!.title;
          _priceController.text = _product!.price.toString();
          _priceAfterDiscountController.text =
              _product!.priceAfetDiscount?.toString() ?? '';
          _describePercentController.text =
              _product!.describe?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product: $e')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true; // Bắt đầu loading
      });

      try {
        final updatedData = {
          'image': _imageController.text,
          'brandName': _brandNameController.text,
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'priceAfetDiscount': _priceAfterDiscountController.text.isNotEmpty
              ? double.parse(_priceAfterDiscountController.text)
              : null,
          'describe': _describePercentController.text,
        };

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.of(context).pop(true); // Quay lại sau khi cập nhật thành công
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $e')),
        );
      } finally {
        setState(() {
          _isUpdating = false; // Tắt loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Các TextFormField như cũ
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
                            if (value != null &&
                                value.isNotEmpty &&
                                double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          maxLines: 5,
                          controller: _describePercentController,
                          decoration: const InputDecoration(
                            labelText: 'Describe',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter a describe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isUpdating ? null : _updateProduct,
                          child: _isUpdating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white, // Màu sắc của loading
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text('Update Product'),
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
