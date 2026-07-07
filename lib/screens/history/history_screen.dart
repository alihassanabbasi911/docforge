// lib/screens/history/history_screen.dart

import 'package:flex_scan/features/utils/share_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/document.dart';
import '../../providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DocumentFormat? _filterFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchQuery = ref.watch(historySearchProvider);
    final allDocs = ref.watch(documentsProvider);
    final sortOptions = ref.watch(sortOptionProvider);

    // Apply search + format filter
    var filtered = allDocs.where((d) {
      final matchesQuery = searchQuery.isEmpty ||
          d.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          d.format.label.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFormat = _filterFormat == null || d.format == _filterFormat;
      return matchesQuery && matchesFormat;
    }).toList();

    // Group by date
    final grouped = _groupByDate(filtered);
    if (sortOptions.$2) {
      // Group by name
      // This will override the date grouping, but that's expected
      grouped.clear();
      grouped.addAll(_groupByName(filtered));
    } else if (sortOptions.$3) {
      // Group by format
      grouped.clear();
      grouped.addAll(_groupByFormat(filtered));
    } else if (!sortOptions.$1) {
      // Oldest first (default is newest first)
      grouped.clear();
      grouped.addAll(_sortByOldestFirst(filtered));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortOptions(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search + Filter bar
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                ForgeSearchBar(
                  onChanged: (q) =>
                      ref.read(historySearchProvider.notifier).state = q,
                ),
                const SizedBox(height: 12),
                // Format filter chips
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _filterFormat == null,
                        onTap: () => setState(() => _filterFormat = null),
                      ),
                      const SizedBox(width: 8),
                      ...DocumentFormat.values.map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: !(f == DocumentFormat.jpeg ||
                                    f == DocumentFormat.png ||
                                    f == DocumentFormat.doc ||
                                    f == DocumentFormat.jpg)
                                ? _FilterChip(
                                    label: f.label,
                                    isSelected: _filterFormat == f,
                                    color: f.color,
                                    onTap: () => setState(() {
                                      _filterFormat =
                                          _filterFormat == f ? null : f;
                                    }),
                                  )
                                : null,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
          ),

          // Document list
          Expanded(
            child: filtered.isEmpty
                ? _EmptyHistoryState(
                    hasQuery: searchQuery.isNotEmpty || _filterFormat != null,
                    onClear: () {
                      ref.read(historySearchProvider.notifier).state = '';
                      setState(() => _filterFormat = null);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    itemCount: grouped.entries.length,
                    itemBuilder: (ctx, sectionIdx) {
                      final entry = grouped.entries.elementAt(sectionIdx);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 4),
                            child: Text(
                              entry.key,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Documents
                          ...entry.value.map((doc) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: DocumentCard(
                                  document: doc,
                                  onTap: () {
                                    // Load doc into OCR state and navigate
                                    final text = doc.extractedText;
                                    if (text != null && text.isNotEmpty) {
                                      ref
                                          .read(extractTextProvider.notifier)
                                          .updateText(text);
                                    }
                                    context.push(AppRoutes.editor);
                                  },
                                  onShare: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Sharing ${doc.name}…')),
                                    );
                                    if (doc.path != null) {
                                      await shareDocument(doc.path!);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'File not found for ${doc.name}')),
                                      );
                                    }
                                  },
                                  onDelete: () =>
                                      _confirmDelete(context, ref, doc),
                                ),
                              )),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Document>> _groupByFormat(List<Document> docs) {
    final result = <String, List<Document>>{};

    docs.sort((a, b) => a.format.label
        .toLowerCase()
        .trim()
        .compareTo(b.format.label.toLowerCase().trim()));

    for (final doc in docs) {
      final raw = doc.format.label;

      final key = (raw.trim().isEmpty) ? 'Unknown' : raw.trim();

      result.putIfAbsent(key, () => []).add(doc);
    }

    return result;
  }

  Map<String, List<Document>> _groupByName(List<Document> docs) {
    final result = <String, List<Document>>{};

    docs.sort((a, b) =>
        a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()));

    for (final doc in docs) {
      final trimmed = doc.name.trim();

      String key;

      if (trimmed.isEmpty) {
        key = '#';
      } else {
        final firstChar = trimmed.characters.first;

        if (RegExp(r'[A-Za-z]').hasMatch(firstChar)) {
          key = firstChar.toUpperCase();
        } else {
          key = '#';
        }
      }

      result.putIfAbsent(key, () => []).add(doc);
    }

    return result;
  }

  Map<String, List<Document>> _sortByOldestFirst(List<Document> docs) {
    final now = DateTime.now();

    docs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final Map<String, List<Document>> result = {};

    for (final doc in docs) {
      final diff = now.difference(doc.createdAt).inDays;

      String key;
      if (diff == 0) {
        key = 'Today';
      } else if (diff == 1) {
        key = 'Yesterday';
      } else if (diff < 7) {
        key = 'This Week';
      } else if (diff < 30) {
        key = 'This Month';
      } else {
        key = DateFormat('MMMM yyyy').format(doc.createdAt);
      }

      result.putIfAbsent(key, () => []).add(doc);
    }

    return result;
  }

  Map<String, List<Document>> _groupByDate(List<Document> docs) {
    final now = DateTime.now();

    // STEP 1: Sort (newest first)
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<Document>> result = {};

    for (final doc in docs) {
      final diff = now.difference(doc.createdAt).inDays;

      String key;
      if (diff == 0) {
        key = 'Today';
      } else if (diff == 1) {
        key = 'Yesterday';
      } else if (diff < 7) {
        key = 'This Week';
      } else if (diff < 30) {
        key = 'This Month';
      } else {
        key = DateFormat('MMMM yyyy').format(doc.createdAt);
      }

      result.putIfAbsent(key, () => []).add(doc);
    }

    return result;
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Document doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text('Delete document?'),
        content: Text('${doc.name} will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              context.pop(); // Close dialog
              final scaffold = ScaffoldMessenger.of(context);
              await ref.read(documentsProvider.notifier).remove(doc.id);

              scaffold.showSnackBar(
                SnackBar(content: Text('${doc.name} deleted')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.xl),
      ),
      builder: (ctx) => const _SortSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withAlpha(isDark ? 80 : 30)
              : (isDark ? AppColors.darkSurface2 : AppColors.neutral100),
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: isSelected
                ? activeColor.withAlpha(isDark ? 200 : 150)
                : (isDark ? AppColors.darkSurface3 : AppColors.neutral200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                isSelected ? activeColor : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  final bool hasQuery;
  final VoidCallback onClear;

  const _EmptyHistoryState({required this.hasQuery, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasQuery ? Icons.search_off_rounded : Icons.history_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No results found' : 'No documents yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try adjusting your search or filters.'
                  : 'Scan or import your first document\nto see it here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasQuery) ...[
              const SizedBox(height: 20),
              TextButton(
                  onPressed: onClear, child: const Text('Clear filters')),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends ConsumerStatefulWidget {
  const _SortSheet();

  @override
  ConsumerState<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends ConsumerState<_SortSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortOptions = ref.watch(sortOptionProvider);

    final options = [
      ('Date (Newest first)', Icons.calendar_today_rounded, sortOptions.$1),
      ('Date (Oldest first)', Icons.calendar_today_outlined, !sortOptions.$1),
      ('Name (A–Z)', Icons.sort_by_alpha_rounded, sortOptions.$2),
      ('Format type', Icons.filter_list_rounded, sortOptions.$3),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
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
            Text('Sort By', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            ...options.map((opt) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: Icon(opt.$2),
                  title: Text(opt.$1),
                  trailing: opt.$3
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () {
                    final option = ref.read(sortOptionProvider.notifier);
                    if (opt.$1.contains('Newest')) {
                      option.setSort((true, false, false));
                    } else if (opt.$1.contains('Oldest')) {
                      option.setSort((false, false, false));
                    } else if (opt.$1.contains('Name')) {
                      option.setSort((false, true, false));
                    } else if (opt.$1.contains('Format')) {
                      option.setSort((false, false, true));
                    }

                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
