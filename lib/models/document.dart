// lib/models/document.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DocumentFormat { pdf, docx, txt, jpeg, png, jpg, doc }

enum DocumentStatus { pending, processing, completed, failed }

extension DocumentFormatExt on DocumentFormat {
  String get label {
    switch (this) {
      case DocumentFormat.pdf:
        return 'PDF';
      case DocumentFormat.docx:
        return 'DOCX';
      case DocumentFormat.txt:
        return 'TXT';
      case DocumentFormat.jpeg:
        return 'JPEG';
      case DocumentFormat.png:
        return 'PNG';
      case DocumentFormat.jpg:
        return 'JPG';
      case DocumentFormat.doc:
        return 'DOC';
    }
  }

  String get description {
    switch (this) {
      case DocumentFormat.pdf:
        return 'Portable Document';
      case DocumentFormat.docx:
        return 'Word Document';
      case DocumentFormat.txt:
        return 'Plain Text';
      case DocumentFormat.jpeg:
        return 'JPEG Image';
      case DocumentFormat.png:
        return 'PNG Image';
      case DocumentFormat.jpg:
        return 'JPG Image';
      case DocumentFormat.doc:
        return 'Word Document';
    }
  }

  String get extension {
    switch (this) {
      case DocumentFormat.pdf:
        return '.pdf';
      case DocumentFormat.docx:
        return '.docx';
      case DocumentFormat.txt:
        return '.txt';
      case DocumentFormat.jpeg:
        return '.jpeg';
      case DocumentFormat.png:
        return '.png';
      case DocumentFormat.jpg:
        return '.jpg';
      case DocumentFormat.doc:
        return '.doc';
    }
  }

  Color get color {
    switch (this) {
      case DocumentFormat.pdf:
        return AppColors.pdfColor;
      case DocumentFormat.docx:
        return AppColors.docxColor;
      case DocumentFormat.txt:
        return AppColors.txtColor;
      case DocumentFormat.jpeg:
        return AppColors.jpegColor;
      case DocumentFormat.png:
        return AppColors.pngColor;
      case DocumentFormat.jpg:
        return AppColors.jpgColor;
      case DocumentFormat.doc:
        return AppColors.docColor;
    }
  }

  Color get bgColor {
    switch (this) {
      case DocumentFormat.pdf:
        return const Color(0xFFFEE2E2);
      case DocumentFormat.docx:
        return const Color(0xFFDBEAFE);
      case DocumentFormat.txt:
        return const Color(0xFFD1FAE5);
      case DocumentFormat.jpeg:
        return const Color(0xFFFEF3C7);
      case DocumentFormat.png:
        return const Color(0xFFD1FAE5);
      case DocumentFormat.jpg:
        return const Color(0xFFFEF3C7);
      case DocumentFormat.doc:
        return const Color(0xFFDBEAFE);
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentFormat.pdf:
        return Icons.picture_as_pdf_rounded;
      case DocumentFormat.docx:
        return Icons.article_rounded;
      case DocumentFormat.txt:
        return Icons.text_snippet_rounded;
      case DocumentFormat.jpeg:
        return Icons.photo_rounded;
      case DocumentFormat.png:
        return Icons.photo_rounded;
      case DocumentFormat.jpg:
        return Icons.photo_rounded;
      case DocumentFormat.doc:
        return Icons.article_rounded;
    }
  }
}

class Document {
  final String id;
  final String name;
  final DocumentFormat format;
  final String? extractedText;
  final DateTime createdAt;
  final String? path;
  final int? wordCount;
  final int? characterCount;
  final DocumentStatus status;

  const Document({
    required this.id,
    required this.name,
    required this.format,
    this.extractedText,
    required this.createdAt,
    this.path,
    this.wordCount,
    this.characterCount,
    required this.status,
  });

  Document copyWith({
    String? id,
    String? name,
    DocumentFormat? format,
    Object? extractedText = _noChange,
    DateTime? createdAt,
    String? path,
    int? wordCount,
    int? characterCount,
    DocumentStatus? status,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      format: format ?? this.format,
      extractedText: extractedText == _noChange
          ? this.extractedText
          : extractedText as String?,
      createdAt: createdAt ?? this.createdAt,
      path: path ?? this.path,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      status: status ?? this.status,
    );
  }

  static const _noChange = Object();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'format': format.name,
      'extractedText': extractedText,
      'createdAt': createdAt.toIso8601String(),
      'path': path,
      'wordCount': wordCount,
      'characterCount': characterCount,
      'status': status.name,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as String,
      name: map['name'] as String,
      format: DocumentFormat.values.firstWhere(
        (e) => e.name == map['format'],
        orElse: () => DocumentFormat.pdf, // fallback
      ),
      extractedText: map['extractedText'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      path: map['path'] as String?,
      wordCount: map['wordCount'] as int?,
      characterCount: map['characterCount'] as int?,
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DocumentStatus.pending,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Document && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Sample data for UI demonstration
class SampleData {
  static final documents = [
    Document(
      id: '1',
      name: 'Contract Agreement',
      format: DocumentFormat.pdf,
      extractedText:
          'This agreement is entered into as of the date first written above...',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      wordCount: 847,
      characterCount: 4823,
      status: DocumentStatus.completed,
    ),
    Document(
      id: '2',
      name: 'Meeting Notes Q1',
      format: DocumentFormat.docx,
      extractedText:
          'Attendees: Ali Hassan, Sarah Ahmed, Umar Khalid. Agenda items discussed...',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      wordCount: 312,
      characterCount: 1840,
      status: DocumentStatus.completed,
    ),
    Document(
      id: '3',
      name: 'Product Requirements',
      format: DocumentFormat.txt,
      extractedText:
          'Feature: User authentication. Priority: High. Status: In Progress...',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      wordCount: 1204,
      characterCount: 7120,
      status: DocumentStatus.processing,
    ),
    Document(
      id: '4',
      name: 'Invoice #INV-2024',
      format: DocumentFormat.pdf,
      extractedText:
          'Bill To: Systems Ltd. Services Rendered: Software Development...',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      wordCount: 204,
      characterCount: 1102,
      status: DocumentStatus.completed,
    ),
    Document(
      id: '5',
      name: 'Research Summary',
      format: DocumentFormat.docx,
      extractedText:
          'Abstract: This paper investigates the application of machine learning...',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      wordCount: 3200,
      characterCount: 18400,
      status: DocumentStatus.failed,
    ),
  ];
}
