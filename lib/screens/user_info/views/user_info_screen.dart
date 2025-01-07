import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../route/route_constants.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String email = '';
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  String gender = '';

  String? _avatarFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    final _avatarFileLocal = prefs.getString('avatar') ?? '';

    if (savedEmail.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No email found in SharedPreferences')),
      );
      return;
    }

    setState(() {
      email = savedEmail;
      _avatarFile = _avatarFileLocal;
    });

    try {
      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _phoneNumberController.text = userData['phoneNumber'] ?? '';
          _birthdayController.text = userData['birthday'] ?? '';
          gender = userData['gender'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found in Firestore')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: ${e.toString()}')),
      );
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
            'Functionality to change password is not implemented yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, editProfile);
              if (result == true) {
                _loadProfileData();
              }
            },
            child: const Text('Edit', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: _avatarFile != null
                          ? ClipRRect(
                              borderRadius: new BorderRadius.circular(100.0),
                              child: Image.file(
                                File(_avatarFile!),
                                fit: BoxFit.fill, // Hiển thị toàn bộ ảnh
                              ),
                            )
                          : Image.asset(
                              'assets/images/avatar.png',
                              fit: BoxFit.contain, // Hiển thị toàn bộ ảnh
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileField('Name', _nameController.text),
              _buildProfileField('Date of Birth', _birthdayController.text),
              _buildProfileField('Phone Number', _phoneNumberController.text),
              _buildProfileField('Gender', gender),
              _buildProfileField('Email', email),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, changePassword),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
