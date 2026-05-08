import 'package:share_plus/share_plus.dart';

Future<void> shareDocument(String filePath) async {
  await SharePlus.instance.share(ShareParams(
    text: 'Check out this document I extracted with DocForge!',
    files: [XFile(filePath)],
  ));
}
