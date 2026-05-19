// lib/providers/app_providers.dart
import 'dart:async';

import 'package:FlexScan/features/services/extract_text.dart';
import 'package:FlexScan/features/services/file_picker_service.dart';
import 'package:FlexScan/repositories/document_repository.dart';
import 'package:FlexScan/repositories/theme_repo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document.dart';

// ---------------------------------------------------------------------------
// Theme Provider
// ---------------------------------------------------------------------------
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
    (ref) => ThemeNotifier(ThemeRepository()));

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final ThemeRepository repository;

  ThemeNotifier(this.repository) : super(repository.getTheme());

  void setTheme(ThemeMode mode) {
    repository.saveTheme(mode);
    state = mode;
  }
}

// ---------------------------------------------------------------------------
// Document History Provider
// ---------------------------------------------------------------------------
class DocumentNotifier extends StateNotifier<List<Document>> {
  DocumentNotifier() : super(SampleData.documents);

  void addDocument(Document doc) {
    state = [doc, ...state];
  }

  void removeDocument(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void updateDocument(Document updated) {
    state = state.map((d) => d.id == updated.id ? updated : d).toList();
  }
}

final documentProvider =
    StateNotifierProvider<DocumentNotifier, List<Document>>(
  (ref) => DocumentNotifier(),
);

// ---------------------------------------------------------------------------
// OCR Processing State
// ---------------------------------------------------------------------------
enum OcrStatus { idle, scanning, extracting, completed, failed }

class OcrState {
  final OcrStatus status;
  final String? imagePath;
  final String? extractedText;
  final String? errorMessage;
  final double progress;

  const OcrState({
    this.status = OcrStatus.idle,
    this.imagePath,
    this.extractedText,
    this.errorMessage,
    this.progress = 0.0,
  });

  OcrState copyWith({
    OcrStatus? status,
    String? imagePath,
    String? extractedText,
    String? errorMessage,
    double? progress,
  }) {
    return OcrState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  String get statusLabel {
    switch (status) {
      case OcrStatus.idle:
        return 'Ready';
      case OcrStatus.scanning:
        return 'Scanning document…';
      case OcrStatus.extracting:
        return 'Extracting text…';
      case OcrStatus.completed:
        return 'Processing complete';
      case OcrStatus.failed:
        return 'Processing failed';
    }
  }
}

class OcrNotifier extends StateNotifier<OcrState> {
  OcrNotifier() : super(const OcrState());

  Future<void> processImage(String imagePath) async {
    state = state.copyWith(
      status: OcrStatus.scanning,
      imagePath: imagePath,
      progress: 0.1,
    );

    await Future.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(
      status: OcrStatus.extracting,
      progress: 0.5,
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulated extracted text
    state = state.copyWith(
      status: OcrStatus.completed,
      progress: 1.0,
      extractedText:
          '''This Agreement is entered into as of the 1st day of April, 2025, between DocForge Technologies (hereinafter "Company") and the undersigned party.

1. SCOPE OF SERVICES
The Company agrees to provide intelligent document processing services including optical character recognition, text extraction, and multi-format document conversion.

2. TERMS AND CONDITIONS
All services are provided on an "as-is" basis. The Company makes no warranties, expressed or implied, regarding the accuracy of OCR processing, which may vary depending on document quality and language.

3. CONFIDENTIALITY
Both parties agree to maintain strict confidentiality regarding any proprietary information shared during the course of this agreement.

4. PAYMENT TERMS
Services shall be billed monthly at the agreed rate. Payment is due within 30 days of invoice date.''',
    );
  }

  void updateText(String text) {
    state = state.copyWith(extractedText: text);
  }

  void reset() {
    state = const OcrState();
  }
}

final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>(
  (ref) => OcrNotifier(),
);

// ---------------------------------------------------------------------------
// Export State
// ---------------------------------------------------------------------------
enum ExportStatus { idle, exporting, done, failed }

class ExportState {
  final ExportStatus status;
  final DocumentFormat? selectedFormat;
  final double progress;

  const ExportState({
    this.status = ExportStatus.idle,
    this.selectedFormat,
    this.progress = 0.0,
  });

  ExportState copyWith({
    ExportStatus? status,
    DocumentFormat? selectedFormat,
    double? progress,
  }) {
    return ExportState(
      status: status ?? this.status,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      progress: progress ?? this.progress,
    );
  }
}

class ExportNotifier extends StateNotifier<ExportState> {
  ExportNotifier() : super(const ExportState());

  void selectFormat(DocumentFormat format) {
    state = state.copyWith(selectedFormat: format);
  }

  Future<void> exportDocument() async {
    if (state.selectedFormat == null) return;
    state = state.copyWith(status: ExportStatus.exporting, progress: 0.0);
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      state = state.copyWith(progress: i / 10.0);
    }
    state = state.copyWith(status: ExportStatus.done, progress: 1.0);
  }

  void reset() {
    state = const ExportState();
  }
}

final exportProvider = StateNotifierProvider<ExportNotifier, ExportState>(
  (ref) => ExportNotifier(),
);

// ---------------------------------------------------------------------------
// Bottom Nav Index
// ---------------------------------------------------------------------------
final navIndexProvider = StateProvider<int>((ref) => 0);

// ---------------------------------------------------------------------------
// Search query for History
// ---------------------------------------------------------------------------
final historySearchProvider = StateProvider<String>((ref) => '');

final filteredDocumentsProvider = Provider<List<Document>>((ref) {
  final docs = ref.watch(documentProvider);
  final query = ref.watch(historySearchProvider).toLowerCase();
  if (query.isEmpty) return docs;
  return docs
      .where((d) =>
          d.name.toLowerCase().contains(query) ||
          d.format.label.toLowerCase().contains(query))
      .toList();
});

final docReaderProvider = AsyncNotifierProvider<DocReaderControler, String?>(
  () => DocReaderControler(),
);

class DocReaderControler extends AsyncNotifier<String?> {
  late final FilePickerService filePicker;
  @override
  FutureOr<String?> build() {
    filePicker = FilePickerService();
    return null;
  }

  Future<String?> readDocument() async {
    // Simulate reading document content
    state = const AsyncValue.loading();
    try {
      String? path = await filePicker.pickFile();
      state = AsyncValue.data(path);
      return path;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<String?> readImage() async {
    // Simulate reading document content
    state = const AsyncValue.loading();
    try {
      String? path = await filePicker.pickImage();
      state = AsyncValue.data(path);
      return path;
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      return null;
    }
  }
}

final extractTextProvider =
    AsyncNotifierProvider<ExtractTextController, String?>(
  ExtractTextController.new,
);

class ExtractTextController extends AsyncNotifier<String?> {
  final ExtractText extractor = ExtractText();
  DocumentStatus status = DocumentStatus.pending;

  @override
  Future<String?> build() async {
    return null; // initial state
  }

  Future<String?> extractText(String path) async {
    state = const AsyncValue.loading();
    status = DocumentStatus.processing;
    Document? doc;
    try {
      final result = await extractor.extractText(path);
      doc = Document(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: path.split('/').last,
        format: DocumentFormat.values.firstWhere(
          (f) => f.name == path.split('.').last.toLowerCase(),
          orElse: () => DocumentFormat.pdf,
        ),
        extractedText: result,
        createdAt: DateTime.now(),
        path: path,
        status: status,
      );

      state = AsyncValue.data(result);
      status = DocumentStatus.completed;
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      status = DocumentStatus.failed;
      return null;
    } finally {
      try {
        doc != null &&
                status == DocumentStatus.completed &&
                !(doc.format == DocumentFormat.jpeg ||
                    doc.format == DocumentFormat.png ||
                    doc.format == DocumentFormat.jpg)
            ? await ref.read(documentsProvider.notifier).add(doc)
            : null;
      } catch (e) {
        rethrow;
      }
    }
  }

  void updateText(String text) {
    state = const AsyncValue.loading();
    state = AsyncValue.data(text);
  }
}

final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, List<Document>>(
  (ref) => DocumentsNotifier(DocumentRepository()),
);

class DocumentsNotifier extends StateNotifier<List<Document>> {
  final DocumentRepository repo;

  DocumentsNotifier(this.repo) : super([]) {
    load();
  }

  Future<void> load() async {
    final docs = await repo.getAll();

    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = docs;
  }

  Future<void> add(Document doc) async {
    await repo.add(doc);
    state = [doc, ...state];
  }

  Future<void> remove(String id) async {
    await repo.delete(id);
    state = state.where((d) => d.id != id).toList();
  }

  Future<void> update(Document doc) async {
    await repo.update(doc);

    state = [
      for (final d in state)
        if (d.id == doc.id) doc else d
    ];
  }

  Future<void> clearAll() async {
    await repo.clearAll();
    state = [];
  }
}

final torchControlProvider = StateNotifierProvider<TorchNotifier, bool>(
  (ref) => TorchNotifier(),
);

class TorchNotifier extends StateNotifier<bool> {
  TorchNotifier() : super(false);

  void toggle() => state = !state;
}

final sortOptionProvider =
    StateNotifierProvider<SortNotifier, (bool, bool, bool)>(
  (ref) => SortNotifier(),
);

class SortNotifier extends StateNotifier<(bool, bool, bool)> {
  SortNotifier() : super((true, false, false));

  void setSort((bool, bool, bool) option) => state = option;
}

final persistenceProvider =
    StateNotifierProvider<UserPersistenceNotifier, bool>(
        (ref) => UserPersistenceNotifier());

class UserPersistenceNotifier extends StateNotifier<bool> {
  UserPersistenceNotifier() : super(true);
  void togglePersistence() => state = !state;
}
