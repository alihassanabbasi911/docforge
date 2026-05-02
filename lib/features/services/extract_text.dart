import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:doc_text_extractor/doc_text_extractor.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

class ExtractText {
  final TextRecognizer recognizer = TextRecognizer();

  Future<String?> extractPDFTextFromPath(String filePath) async {
    try {
      final doc = await PDFDoc.fromPath(filePath);
      String? text = await doc.text;
      if (!_isTextUsable(text)) {
        text = await extractTextFromScannedPdf(filePath);
      }
      print(text);
      return text;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> extractDOCText(String path) async {
    final extractor = TextExtractor();
    final result;
    try {
      final dir = await getTemporaryDirectory();

      result = await extractor.extractText(path, isUrl: false);
      print(result.text);
    } catch (e) {
      rethrow;
    }
    return result.text;
  }

  Future<String> extractTextFromImage(String imagePath) async {
    final image = InputImage.fromFilePath(imagePath);

    final text = await recognizer.processImage(image);
    recognizer.close();
    return text.text;
  }

  Future<String?> extractText(String filePath) async {
    String format;
    try {
      format = filePath.split('.').last.toLowerCase();
      switch (format) {
        case 'pdf':
          return await extractPDFTextFromPath(filePath);
        case 'docx':
        case 'doc':
          return await extractDOCText(filePath);
        case 'jpg':
        case 'jpeg':
        case 'png':
          return await extractTextFromImage(filePath);
        default:
          throw Exception('Unsupported file format: $format');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> extractTextFromScannedPdf(String path) async {
    final buffer = StringBuffer();
    final doc;

    try {
      doc = await PdfDocument.openFile(path);
      for (int i = 0; i < doc.pageCount; i++) {
        try {
          final page = await doc.getPage(i + 1);

          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
          );

          final text = await extractTextFromImageBytes(
            pageImage.bytes,
            pageImage.width,
            pageImage.height,
          );

          buffer.writeln(text);
          buffer.writeln('\n');

          await page.close();
        } catch (pageError) {
          print("Error processing page ${i + 1}: $pageError");
        }
      }
      await doc.close();
    } catch (e) {
      rethrow;
    }

    return buffer.toString();
  }

  bool _isTextUsable(String? text) {
    if (text == null || text.trim().isEmpty) return false;

    if (text.length < 50) return false;

    int readableChars = RegExp(r'[a-zA-Z0-9]').allMatches(text).length;
    double ratio = readableChars / text.length;

    return ratio > 0.3;
  }

  Future<String> extractTextFromImageBytes(
      Uint8List bytes, int width, int height) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/page_ocr.png');
    await file.writeAsBytes(bytes);
    final inputImage = InputImage.fromFilePath(file.path);
    final result = await recognizer.processImage(inputImage);
    recognizer.close();
    return result.text;
  }
}
