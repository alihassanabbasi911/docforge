# DocForge 📄

**Intelligent Document OCR & Conversion App**

A clean, modern, premium-quality Flutter application for scanning documents, extracting text via OCR, and converting to PDF, DOCX, or TXT. Built with Riverpod, GoRouter, and a carefully crafted design system.

---

## ✨ Features

| Feature | Status |
|---|---|
| Onboarding (3 screens) | ✅ |
| Home Dashboard | ✅ |
| Camera Scan UI | ✅ |
| Gallery / File Import | ✅ |
| OCR Processing Screen | ✅ |
| Text Editor w/ Toolbar | ✅ |
| Export to PDF / DOCX / TXT | ✅ |
| Document History | ✅ |
| Search & Filter | ✅ |
| Settings (Theme, Language) | ✅ |
| Light & Dark Mode | ✅ |
| Urdu / Arabic language support | ✅ (UI ready) |

---

## 🎨 Design System

### Color Palette
- **Primary**: Indigo `#4F46E5` — trustworthy, intelligent
- **Neutrals**: Warm Slate scale (50→900)
- **Format accents**: PDF Red, DOCX Blue, TXT Green
- **Semantic**: Success, Warning, Error

### Typography
- **Display / Headlines**: Fraunces (editorial, characterful serif)
- **Body / UI**: Plus Jakarta Sans (clean, modern sans-serif)

### Components
- `FormatBadge` — color-coded format indicator
- `DocumentCard` — full-feature card with context menu
- `QuickActionCard` — home screen action tiles
- `FormatCard` — animated export selection card
- `SettingsTile` / `SettingsGroup` — settings UI system
- `LoadingDots` — animated 3-dot loader
- `ForgeSearchBar` — custom search input
- `StatChip` — compact stat display

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point
│
├── theme/
│   └── app_theme.dart               # Complete design system:
│                                    #   AppColors, AppRadius, AppShadows,
│                                    #   AppTheme (light + dark)
│
├── models/
│   └── document.dart                # Document model, DocumentFormat enum,
│                                    #   SampleData for demo
│
├── providers/
│   └── app_providers.dart           # All Riverpod providers:
│                                    #   themeModeProvider
│                                    #   documentProvider (DocumentNotifier)
│                                    #   ocrProvider (OcrNotifier)
│                                    #   exportProvider (ExportNotifier)
│                                    #   navIndexProvider
│                                    #   historySearchProvider
│                                    #   filteredDocumentsProvider
│
├── router/
│   └── app_router.dart              # GoRouter config with custom transitions
│
├── widgets/
│   └── common_widgets.dart          # All reusable widgets
│
└── screens/
    ├── onboarding/
    │   └── onboarding_screen.dart   # 3-page onboarding
    ├── shell/
    │   └── app_shell.dart           # NavigationBar shell
    ├── home/
    │   └── home_screen.dart         # Dashboard
    ├── scan/
    │   └── scan_screen.dart         # Camera UI
    ├── processing/
    │   └── processing_screen.dart   # OCR progress
    ├── editor/
    │   └── editor_screen.dart       # Text editor
    ├── export/
    │   └── export_screen.dart       # Format selection & export
    ├── history/
    │   └── history_screen.dart      # Document history
    └── settings/
        └── settings_screen.dart     # App settings
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.3.0` (stable channel)
- Dart `>=3.3.0`

### Installation

```bash
# 1. Get dependencies
flutter pub get

# 2. Run code generation (Riverpod annotations)
dart run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

### Adding Real OCR

Replace the simulated processing in `OcrNotifier.processImage()` with:

```yaml
# pubspec.yaml — add these
google_mlkit_text_recognition: ^0.13.0
camera: ^0.10.5
image_picker: ^1.1.2
file_picker: ^8.0.0
```

```dart
// In OcrNotifier
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Future<void> processImage(String imagePath) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final inputImage = InputImage.fromFilePath(imagePath);
  final result = await recognizer.processImage(inputImage);
  recognizer.close();
  
  state = state.copyWith(
    status: OcrStatus.completed,
    extractedText: result.text,
    progress: 1.0,
  );
}
```

### Adding Real Export

```yaml
# pubspec.yaml — add these
pdf: ^3.11.1
docx_template: ^0.5.1
path_provider: ^2.1.3
share_plus: ^9.0.0
```

---

## 📱 Navigation Flow

```
Onboarding (3 pages)
    └─→ Home Dashboard
         ├─→ Scan Screen ─→ Processing ─→ Text Editor ─→ Export
         ├─→ History Screen
         └─→ Settings Screen
```

---

## 🔧 State Management

All state is managed via Riverpod `StateNotifier` providers:

| Provider | Type | Manages |
|---|---|---|
| `themeModeProvider` | `StateProvider<ThemeMode>` | App theme |
| `documentProvider` | `StateNotifierProvider<DocumentNotifier, List<Document>>` | Document history |
| `ocrProvider` | `StateNotifierProvider<OcrNotifier, OcrState>` | OCR processing & extracted text |
| `exportProvider` | `StateNotifierProvider<ExportNotifier, ExportState>` | Export format & progress |
| `navIndexProvider` | `StateProvider<int>` | Bottom nav index |
| `historySearchProvider` | `StateProvider<String>` | Search query |
| `filteredDocumentsProvider` | `Provider<List<Document>>` | Derived: search + filter |

---

## 🌍 Localization

The app is scaffolded for multi-language support:

- `flutter_localizations` included
- Supported locales: `en_US`, `ur_PK`, `ar_SA`
- RTL support inherited from Material 3 + `flutter_localizations`
- Add `intl` ARB files for full string localization

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `google_fonts` | Fraunces + Plus Jakarta Sans |
| `intl` | Date/number formatting |
| `uuid` | Document ID generation |
| `shared_preferences` | Local persistence (ready) |
| `flutter_localizations` | i18n |

---

## 🏗️ Architecture Principles

1. **Separation of concerns** — screens consume state, never mutate it directly
2. **Stateless first** — screens use `ConsumerWidget`, only lift to `ConsumerStatefulWidget` when local animation state is needed
3. **Reusable widgets** — all repeated UI patterns extracted to `common_widgets.dart`
4. **Design tokens** — all colors, radii, shadows referenced via `AppColors` / `AppRadius` / `AppShadows` constants
5. **Responsive** — `ConstrainedBox(maxWidth: 680)` on editor for tablet/web, `MediaQuery`-aware padding everywhere

---

*Built by Ali Hassan · DocForge v1.0.0*
