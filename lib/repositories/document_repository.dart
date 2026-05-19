import 'package:FlexScan/models/document.dart';

import 'package:hive/hive.dart';

class DocumentRepository {
  final box = Hive.box('documents');

  Future<void> add(Document doc) async {
    await box.put(doc.id, doc.toMap());
  }

  Future<List<Document>> getAll() async {
    return box.values
        .map((e) => Document.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> delete(String key) async {
    await box.delete(key);
  }

  Future<void> update(Document doc) async {
    await box.put(doc.id, doc.toMap());
  }

  Future<void> clearAll() async {
    await box.clear();
  }
}
