class UserModel {
  final String email;
  final String? password; // Để bảo mật, không nên lưu mật khẩu khi nhận từ Firestore
  final String? name;
  final String? phoneNumber;
  final String? createdAt;

  UserModel({
    required this.email,
    this.password, // Chỉ nên lưu khi tạo user mới
    this.name,
    this.phoneNumber,
    this.createdAt,
  });

  // Chuyển từ Firestore Document thành UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] as String,
      password: data['password'] as String?,
      name: data['name'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      createdAt: data['createdAt'] as String?,
    );
  }

  // Chuyển từ UserModel thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
    };
  }
}
