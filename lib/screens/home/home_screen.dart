// lib/screens/home/home_screen.dart
import 'package:docforge/features/utils/share_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/document.dart';
import '../../providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final documents = ref.watch(documentsProvider);
    final recentDocs = documents.take(3).toList();
    ref.listen(extractTextProvider, (prev, next) {
      next.whenOrNull(
        data: (data) {
          if (data != null) {
            context.pop();
            context.push(AppRoutes.editor);
          }
        },
        loading: () {
          showAdaptiveDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return const AlertDialog(
                  title: Text('Extracting text…'),
                  content: SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              });
        },
        error: (error, st) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error extracting text: $error'),
              behavior: SnackBarBehavior.fixed,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      );
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()} ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'DocForge',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                      // Avatar / Profile button
                      GestureDetector(
                        onTap: () =>
                            ref.read(navIndexProvider.notifier).state = 1,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withAlpha(77),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Divider(
                height: 1,
                color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row

                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.camera_alt_rounded,
                          label: 'Scan',
                          subtitle: 'Use camera',
                          color: AppColors.primary,
                          isPrimary: true,
                          onTap: () => context.push(AppRoutes.scan),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.upload_file_rounded,
                          label: 'Import',
                          subtitle: 'From files',
                          color: const Color(0xFF059669),
                          onTap: () async {
                            final path = await ref
                                .read(docReaderProvider.notifier)
                                .readDocument();
                            if (path != null) {
                              await ref
                                  .read(extractTextProvider.notifier)
                                  .extractText(path);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No file selected'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final state = ref.watch(extractTextProvider);
                            return QuickActionCard(
                              icon: Icons.image_rounded,
                              label: 'Gallery',
                              subtitle: 'Pick image',
                              color: const Color(0xFFF59E0B),
                              onTap: () async {
                                final path = await ref
                                    .read(docReaderProvider.notifier)
                                    .readImage();
                                if (path != null) {
                                  await ref
                                      .read(extractTextProvider.notifier)
                                      .extractText(path);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No image selected'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.history_rounded,
                          label: 'History',
                          subtitle: 'All documents',
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            ref.read(navIndexProvider.notifier).state = 1;
                            context.go(AppRoutes.history);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SectionHeader(
                    title: 'Recent Documents',
                    action: 'See all',
                    onAction: () {
                      ref.read(navIndexProvider.notifier).state = 1;
                      context.go(AppRoutes.history);
                    },
                  ),
                  const SizedBox(height: 16),

                  if (recentDocs.isEmpty)
                    _EmptyState()
                  else
                    ...recentDocs.map(
                      (doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DocumentCard(
                          document: doc,
                          onTap: () async {
                            final text = doc.extractedText;
                            if (text != null) {
                              ref
                                  .read(extractTextProvider.notifier)
                                  .updateText(text);
                              context.push(AppRoutes.editor);
                            }
                          },
                          onShare: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sharing ${doc.name}…'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            if (doc.path != null) {
                              await shareDocument(doc.path!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('File not found for ${doc.name}')),
                              );
                            }
                          },
                          onDelete: () {
                            ref.read(documentsProvider.notifier).remove(doc.id);
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Tips card
                  _TipCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppColors.darkSurface3
              : AppColors.neutral200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text('No documents yet', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            'Scan or import your first document\nto get started.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderXl,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppRadius.borderMd,
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hold the camera still for 2s for automatic capture in good lighting.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
