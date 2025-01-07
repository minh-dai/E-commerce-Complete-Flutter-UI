import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy mật khẩu hiện tại từ Firestore
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final currentPassword = userData['password'];

        // Kiểm tra mật khẩu hiện tại
        if (currentPassword != _currentPasswordController.text) {
          _showErrorSnackBar('Current password is incorrect');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Cập nhật mật khẩu mới
        await FirebaseFirestore.instance.collection('users').doc(email).update({
          'password': _newPasswordController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar('User not found');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.bold, // Chữ in đậm
            color: Colors.white,         // Màu chữ
          ),
        ),
        backgroundColor: Colors.red,     // Màu nền đỏ
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildPasswordField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                obscureText: !_currentPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _currentPasswordVisible = !_currentPasswordVisible;
                  });
                },
                isVisible: _currentPasswordVisible,
              ),
              SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                labelText: 'New Password',
                obscureText: !_newPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _newPasswordVisible = !_newPasswordVisible;
                  });
                },
                isVisible: _newPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                obscureText: !_confirmPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                },
                isVisible: _confirmPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool isVisible,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }
}
