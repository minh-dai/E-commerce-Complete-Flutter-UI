import 'package:image_picker/image_picker.dart';

import 'firebase_function.dart';

Future<XFile?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  try {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image; // Trả về tệp ảnh đã chọn
  } catch (e) {
    print("Failed to pick image: $e");
    return null;
  }
}


Future<void> pickAndUploadImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    await uploadImageToFirebase(image.path);
  } else {
    print("No image selected.");
  }
}
