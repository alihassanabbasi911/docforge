// lib/screens/export/export_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/document.dart';
import '../../providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exportState = ref.watch(exportProvider);
    final ocrState = ref.watch(ocrProvider);

    final wordCount = ocrState.extractedText
            ?.trim()
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .length ??
        0;
    final charCount = ocrState.extractedText?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Export Document'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
          ),
        ),
      ),
      body: exportState.status == ExportStatus.done
          ? _ExportSuccess(
              format: exportState.selectedFormat!,
              onDone: () {
                // Save document to history
                ref.read(documentProvider.notifier).addDocument(
                      Document(
                          id: const Uuid().v4(),
                          name:
                              'Document ${DateFormat('MMM d').format(DateTime.now())}',
                          format: exportState.selectedFormat!,
                          extractedText: ocrState.extractedText ?? '',
                          createdAt: DateTime.now(),
                          wordCount: wordCount,
                          characterCount: charCount,
                          status: DocumentStatus.completed),
                    );
                ref.read(exportProvider.notifier).reset();
                ref.read(ocrProvider.notifier).reset();
                context.go(AppRoutes.home);
              },
            )
          : exportState.status == ExportStatus.exporting
              ? _ExportingView(progress: exportState.progress)
              : _ExportForm(
                  wordCount: wordCount,
                  charCount: charCount,
                  selectedFormat: exportState.selectedFormat,
                  onSelectFormat: (f) =>
                      ref.read(exportProvider.notifier).selectFormat(f),
                  onExport: exportState.selectedFormat != null
                      ? () => ref.read(exportProvider.notifier).exportDocument()
                      : null,
                ),
    );
  }
}

class _ExportForm extends StatelessWidget {
  final int wordCount;
  final int charCount;
  final DocumentFormat? selectedFormat;
  final ValueChanged<DocumentFormat> onSelectFormat;
  final VoidCallback? onExport;

  const _ExportForm({
    required this.wordCount,
    required this.charCount,
    required this.selectedFormat,
    required this.onSelectFormat,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : Colors.white,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Document Preview',
                              style: theme.textTheme.titleSmall),
                          Text(
                            'Ready for conversion',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _DocStat(label: 'Words', value: '$wordCount')),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            _DocStat(label: 'Characters', value: '$charCount')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _DocStat(
                            label: 'Pages',
                            value: '~${(wordCount / 300).ceil()}')),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const SectionHeader(title: 'Choose Format'),
          const SizedBox(height: 16),

          // Format cards grid
          Row(
            children: DocumentFormat.values.map((format) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: format != DocumentFormat.txt ? 10 : 0,
                  ),
                  child: FormatCard(
                    format: format,
                    isSelected: selectedFormat == format,
                    onTap: () => onSelectFormat(format),
                  ),
                ),
              );
            }).toList(),
          ),

          if (selectedFormat != null) ...[
            const SizedBox(height: 20),
            _FormatDetailsCard(format: selectedFormat!),
          ],

          const SizedBox(height: 32),

          const SectionHeader(title: 'Share Options'),
          const SizedBox(height: 16),

          _ShareOptionsGrid(),

          const SizedBox(height: 40),

          // Export button
          FilledButton(
            onPressed: onExport,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderLg,
              ),
              backgroundColor:
                  selectedFormat != null ? AppColors.primary : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.file_download_rounded, size: 20),
                const SizedBox(width: 10),
                Text(
                  selectedFormat != null
                      ? 'Convert to ${selectedFormat!.label}'
                      : 'Select a format first',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DocStat extends StatelessWidget {
  final String label;
  final String value;

  const _DocStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface3 : AppColors.neutral50,
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatDetailsCard extends StatelessWidget {
  final DocumentFormat format;

  const _FormatDetailsCard({required this.format});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final details = {
      DocumentFormat.pdf: [
        'Searchable text layer',
        'Compressed file size',
        'Universal compatibility',
        'Print-ready quality',
      ],
      DocumentFormat.docx: [
        'Fully editable in Word',
        'Preserved formatting',
        'Track changes support',
        'Compatible with Google Docs',
      ],
      DocumentFormat.txt: [
        'Plain text, no formatting',
        'Smallest file size',
        'Maximum compatibility',
        'UTF-8 / Urdu ready',
      ],
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: format.bgColor.withAlpha(isDark ? 40 : 20),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: format.color.withAlpha(120),
        ),
      ),
      child: Column(
        children: details[format]!.map((detail) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: format.color,
                ),
                const SizedBox(width: 8),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ShareOptionsGrid extends StatelessWidget {
  static const _options = [
    _ShareOption(Icons.email_rounded, 'Email', Color(0xFFEA4335)),
    _ShareOption(Icons.cloud_upload_rounded, 'Drive', Color(0xFF4285F4)),
    _ShareOption(Icons.share_rounded, 'Share', AppColors.primary),
    _ShareOption(Icons.save_alt_rounded, 'Save', Color(0xFF059669)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _options.map((opt) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${opt.label} — coming soon')),
            );
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : Colors.white,
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkSurface3 : AppColors.neutral200,
                  ),
                ),
                child: Icon(opt.icon, color: opt.color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(opt.label, style: theme.textTheme.labelMedium),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ShareOption {
  final IconData icon;
  final String label;
  final Color color;

  const _ShareOption(this.icon, this.label, this.color);
}

class _ExportingView extends StatelessWidget {
  final double progress;

  const _ExportingView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: AppColors.neutral200,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Converting Document…', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Preparing your file for download.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            const LoadingDots(),
          ],
        ),
      ),
    );
  }
}

class _ExportSuccess extends StatelessWidget {
  final DocumentFormat format;
  final VoidCallback onDone;

  const _ExportSuccess({required this.format, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.successContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 52,
              ),
            ),
            const SizedBox(height: 32),
            Text('Export Complete!', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Your document has been converted to ${format.label} successfully.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Action buttons
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening share sheet…')),
                );
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share File'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onDone,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
