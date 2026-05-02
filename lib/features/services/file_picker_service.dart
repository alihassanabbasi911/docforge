import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<String?> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'docx',
        'pdf',
        'jpg',
        'png',
        'jpeg',
      ],
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.single.path;
  }

  Future<String?> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    return result.files.single.path;
  }
}
