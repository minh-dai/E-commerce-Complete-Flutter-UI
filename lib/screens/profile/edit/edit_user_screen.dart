import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUserScreen extends StatefulWidget {
  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  String? _selectedGender;
  File? _avatarFile;
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

    final localAvatarFile = File(_avatarFileLocal);

    setState(() {
      email = savedEmail;
      if (localAvatarFile.existsSync()) {
        _avatarFile = localAvatarFile; // Gán ảnh từ bộ nhớ cục bộ
      }
      _isLoading = false;
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
          _selectedGender = userData['gender'] ?? null;
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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory(); // Thư mục cục bộ
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.png'; // Tên tệp duy nhất
      final localFile = File('${appDir.path}/$fileName');

      // Copy ảnh vào thư mục cục bộ
      final newAvatarFile = await File(pickedFile.path).copy(localFile.path);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('avatar', localFile.path ?? '');

      // Xóa các avatar cũ
      final dir = Directory(appDir.path);
      dir.listSync().forEach((file) {
        if (file.path.contains('avatar_') && file.path != newAvatarFile.path) {
          file.deleteSync();
        }
      });

      setState(() {
        _avatarFile = newAvatarFile;
      });

      print('Avatar updated: ${newAvatarFile.path}');
    }
  }

  Future<void> _selectBirthday() async {
    DateTime initialDate = _birthdayController.text.isNotEmpty
        ? DateTime.tryParse(_birthdayController.text) ?? DateTime.now()
        : DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdayController.text =
            pickedDate.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      await users.doc(email).update({
        'name': _nameController.text,
        'phoneNumber': _phoneNumberController.text,
        'birthday': _birthdayController.text,
        'gender': _selectedGender,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User information updated successfully!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateUser,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 20),
              SizedBox(
                height: 100,
                width: 100,
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 100.0,
                    child: _avatarFile != null
                        ? Image.file(
                            _avatarFile!,
                            fit: BoxFit.contain, // Hiển thị toàn bộ ảnh
                          )
                        : Image.asset(
                            'assets/images/avatar.png',
                            fit: BoxFit.contain, // Hiển thị toàn bộ ảnh
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _birthdayController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selectBirthday,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a gender' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
