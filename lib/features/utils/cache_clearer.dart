import 'package:path_provider/path_provider.dart';

Future<void> clearAppCache() async {
  try {
    final tempDir = await getTemporaryDirectory();

    if (await tempDir.exists()) {
      for (final entity in tempDir.listSync()) {
        await entity.delete(recursive: true);
      }
    }
  } catch (e) {
    throw Exception("Cache clearing failed: $e");
  }
}
