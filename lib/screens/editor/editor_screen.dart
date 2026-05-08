// lib/screens/editor/editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _textController;
  final _focusNode = FocusNode();
  final bool _isEditing = false;
  bool _isBold = false;
  bool _isItalic = false;
  String _documentName = 'Extracted Text';
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: '');
    _nameController.text = _documentName;
  }

  @override
  void dispose() {
    _textController.dispose();
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _textController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  int get _charCount => _textController.text.length;

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  void _showRenameDialog() {
    _nameController.text = _documentName;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text('Rename Document'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Document name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _documentName = _nameController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.read(extractTextProvider);
    state.whenOrNull(
      data: (text) {
        if (text != null && _textController.text.isEmpty) {
          _textController.text = text;
        }
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: GestureDetector(
          onTap: _showRenameDialog,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _documentName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.edit_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy all',
            onPressed: _copyAll,
          ),
          const SizedBox(width: 4),
          // FilledButton.icon(
          //   onPressed: () => context.push(AppRoutes.export),
          //   icon: const Icon(Icons.file_download_rounded, size: 18),
          //   label: const Text('Export'),
          //   style: FilledButton.styleFrom(
          //     minimumSize: const Size(0, 36),
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     shape: const RoundedRectangleBorder(
          //       borderRadius: AppRadius.borderMd,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
          ),
        ),
      ),
      body: Column(
        children: [
          // Document stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: isDark ? AppColors.darkSurface2 : Colors.white,
            child: Row(
              children: [
                _StatPill(
                  icon: Icons.text_fields_rounded,
                  label: '$_wordCount words',
                ),
                const SizedBox(width: 12),
                _StatPill(
                  icon: Icons.format_size_rounded,
                  label: '$_charCount chars',
                ),
                const Spacer(),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
          ),

          // Editor area
          Expanded(
            child: Container(
              color: isDark ? AppColors.darkSurface : AppColors.neutral50,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 680),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface2 : Colors.white,
                      borderRadius: AppRadius.borderLg,
                      boxShadow: AppShadows.sm,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkSurface3
                            : AppColors.neutral200,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Formatting toolbar
                        _FormattingToolbar(
                          isBold: _isBold,
                          isItalic: _isItalic,
                          onBold: () => setState(() => _isBold = !_isBold),
                          onItalic: () =>
                              setState(() => _isItalic = !_isItalic),
                          onCopy: _copyAll,
                          onTranslate: () => _showTranslateBottomSheet(context),
                        ),

                        Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.darkSurface3
                              : AppColors.neutral200,
                        ),

                        // Text editor area
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            maxLines: null,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight:
                                  _isBold ? FontWeight.w700 : FontWeight.w400,
                              fontStyle: _isItalic
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              height: 1.8,
                              color: isDark
                                  ? AppColors.neutral200
                                  : AppColors.neutral800,
                              letterSpacing: 0.1,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              filled: false,
                              hintText: 'Extracted text will appear here…',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            cursorColor: AppColors.primary,
                            cursorWidth: 2,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating action button for export
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => context.push(AppRoutes.export),
      //   backgroundColor: AppColors.primary,
      //   foregroundColor: Colors.white,
      //   elevation: 2,
      //   icon: const Icon(Icons.ios_share_rounded, size: 20),
      //   label: const Text(
      //     'Convert & Export',
      //     style: TextStyle(fontWeight: FontWeight.w600),
      //   ),
      // ),
    );
  }

  void _showTranslateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.xl),
      ),
      builder: (ctx) => const _TranslateSheet(),
    );
  }
}

class _FormattingToolbar extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onCopy;
  final VoidCallback onTranslate;

  const _FormattingToolbar({
    required this.isBold,
    required this.isItalic,
    required this.onBold,
    required this.onItalic,
    required this.onCopy,
    required this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface3 : AppColors.neutral50,
        borderRadius: const BorderRadius.vertical(top: AppRadius.lg),
      ),
      child: Row(
        children: [
          _ToolbarButton(
            label: 'B',
            isActive: isBold,
            onTap: onBold,
            bold: true,
          ),
          const SizedBox(width: 4),
          _ToolbarButton(
            label: 'I',
            isActive: isItalic,
            onTap: onItalic,
            italic: true,
          ),
          const SizedBox(width: 8),
          Container(
            height: 20,
            width: 1,
            color: theme.dividerColor,
          ),
          const SizedBox(width: 8),
          _IconToolbarButton(
            icon: Icons.copy_rounded,
            tooltip: 'Copy all',
            onTap: onCopy,
          ),
          const SizedBox(width: 4),
          _IconToolbarButton(
            icon: Icons.translate_rounded,
            tooltip: 'Translate',
            onTap: onTranslate,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool bold;
  final bool italic;

  const _ToolbarButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.bold = false,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: AppRadius.borderSm,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: isActive
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _IconToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            borderRadius: AppRadius.borderSm,
          ),
          child: Icon(
            icon,
            size: 18,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _ClearDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      title: const Text('Clear text?'),
      content: const Text(
          'This will remove all extracted text. This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Clear'),
        ),
      ],
    );
  }
}

class _TranslateSheet extends StatelessWidget {
  const _TranslateSheet();

  static const _languages = [
    ('English', '🇬🇧'),
    ('Urdu (اردو)', '🇵🇰'),
    ('Arabic (العربية)', '🇸🇦'),
    ('French', '🇫🇷'),
    ('German', '🇩🇪'),
    ('Spanish', '🇪🇸'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.translate_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text('Translate To', style: theme.textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  'Coming soon',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _languages.map((lang) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Translation to ${lang.$1} coming soon')),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang.$2, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(lang.$1, style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
