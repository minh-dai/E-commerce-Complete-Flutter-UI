import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> uploadImageToFirebase(String filePath) async {
  try {
    final File file = File(filePath);

    // Tạo tên tệp dựa trên DateTime
    final String fileName = DateTime.now().toIso8601String() + '.jpg';

    // Đường dẫn nơi ảnh sẽ được lưu trong Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

    // Upload tệp
    final uploadTask = await storageRef.putFile(file);

    // Lấy URL của tệp đã upload
    final downloadUrl = await storageRef.getDownloadURL();

    print("Upload successful! File URL: $downloadUrl");
  } catch (e) {
    print("Failed to upload image: $e");
  }
}
