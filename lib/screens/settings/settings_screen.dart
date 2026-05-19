// lib/screens/settings/settings_screen.dart
import 'dart:ui';

import 'package:FlexScan/features/utils/cache_clearer.dart';
import 'package:FlexScan/features/utils/open_links.dart';
import 'package:FlexScan/links/app_links.dart';
import 'package:FlexScan/main.dart';
import 'package:FlexScan/providers/auth_providers.dart';
import 'package:FlexScan/router/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> sendFeedback() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'almaaturidi@gmail.com',
      queryParameters: {
        'subject': 'FlexScan Feedback',
        'body': '''
App Version: $version
Platform: ${Platform.operatingSystem}

Describe your issue or feedback below:

''',
      },
    );

    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final documentCount = ref.watch(documentsProvider).length;

    ref.listen(authProvider, (prev, next) {
      next.whenOrNull(data: (data) {
        context.pop();
        context.go(AppRoutes.authStateChanges);
      }, error: (e, stackTrace) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
            backgroundColor: AppColors.primary,
          ),
        );
      }, loading: () {
        showAdaptiveDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Please Wait...",
                  )
                ],
              ),
            );
          },
        );
      });
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            // _ProfileCard(documentCount: documentCount),

            const SizedBox(height: 10),

            // Appearance
            SettingsGroup(
              title: 'Appearance',
              children: [
                SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Theme',
                  subtitle: _themeModeLabel(themeMode),
                  iconColor: const Color(0xFF6366F1),
                  trailing: _ThemeSegmentedControl(
                    current: themeMode,
                    onChange: (m) =>
                        ref.watch(themeModeProvider.notifier).setTheme(m),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Language
            // SettingsGroup(
            //   title: 'Language & Region',
            //   children: [
            //     SettingsTile(
            //       icon: Icons.language_rounded,
            //       title: 'App Language',
            //       subtitle: 'English (US)',
            //       iconColor: const Color(0xFF059669),
            //       onTap: () => _showLanguageSheet(context),
            //     ),
            //     SettingsTile(
            //       icon: Icons.translate_rounded,
            //       title: 'OCR Languages',
            //       subtitle: 'English, Urdu',
            //       iconColor: const Color(0xFFF59E0B),
            //       onTap: () => _showOcrLanguageSheet(context),
            //     ),
            //   ],
            // ),

            //const SizedBox(height: 20),

            // Export
            // SettingsGroup(
            //   title: 'Export Defaults',
            //   children: [
            //     SettingsTile(
            //       icon: Icons.picture_as_pdf_rounded,
            //       title: 'Default Format',
            //       subtitle: 'PDF',
            //       iconColor: AppColors.pdfColor,
            //       onTap: () {},
            //     ),
            //     SettingsTile(
            //       icon: Icons.compress_rounded,
            //       title: 'PDF Quality',
            //       subtitle: 'High (300 DPI)',
            //       iconColor: AppColors.docxColor,
            //       onTap: () {},
            //     ),
            //     SettingsTile(
            //       icon: Icons.auto_fix_high_rounded,
            //       title: 'Auto-enhance Images',
            //       subtitle: 'Improve contrast before OCR',
            //       iconColor: const Color(0xFF8B5CF6),
            //       trailing: Switch(
            //         value: true,
            //         onChanged: (_) {},
            //         activeThumbColor: AppColors.primary,
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 20),

            // Storage
            SettingsGroup(
              title: 'Storage',
              children: [
                SettingsTile(
                  icon: Icons.folder_rounded,
                  title: 'Document Storage',
                  subtitle: '$documentCount documents',
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () {
                    _confirmClearStorage(context, ref);
                  },
                ),
                SettingsTile(
                  icon: Icons.delete_sweep_rounded,
                  title: 'Clear Cache',
                  subtitle: 'Free up temporary files',
                  iconColor: AppColors.error,
                  onTap: () => _confirmClearCache(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // About
            SettingsGroup(
              title: 'About',
              children: [
                const SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  subtitle: appVersion,
                  iconColor: AppColors.neutral500,
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  iconColor: AppColors.neutral500,
                  onTap: () async {
                    await openLink(AppLinks.privacy);
                  },
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  iconColor: AppColors.neutral500,
                  onTap: () async {
                    await openLink(AppLinks.terms);
                  },
                ),
                SettingsTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate FlexScan',
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Coming Soon'),
                        content: const Text(
                          'FlexScan will be available on Play Store soon.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  iconColor: AppColors.primary,
                  onTap: () async {
                    try {
                      await sendFeedback();
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            SettingsGroup(title: "Account", children: [
              SettingsTile(
                icon: Icons.logout,
                iconColor: Colors.redAccent,
                title: "Logout",
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                },
              ),
              SettingsTile(
                icon: Icons.no_accounts_rounded,
                iconColor: Colors.red,
                title: "Delete Account",
                onTap: () async {
                  final provider =
                      ref.read(authProvider.notifier).getProviderId();
                  if (provider == 'password') {
                    context.push(AppRoutes.deleteAccountPage);
                  } else if (provider == 'google.com') {
                    await ref.read(authProvider.notifier).deleteSocialAccount();
                  }
                },
              ),
            ]),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'DocForge',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Intelligent Document Processing',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // void _showLanguageSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: AppRadius.xl),
  //     ),
  //     builder: (ctx) => const _LanguageSheet(),
  //   );
  // }

  // void _showOcrLanguageSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: AppRadius.xl),
  //     ),
  //     builder: (ctx) => const _OcrLanguageSheet(),
  //   );
  // }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text('Clear cache?'),
        content: const Text(
            'Temporary files will be removed. Your documents will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await clearAppCache();
              ctx.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmClearStorage(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        title: const Text('Clear storage?'),
        content:
            const Text('All stored data will be removed including documents.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(documentsProvider.notifier).clearAll();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error clearing storage: $e')),
                );
                return;
              }

              ctx.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final int documentCount;

  const _ProfileCard({required this.documentCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [AppColors.primaryContainer, const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ali Hassan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$documentCount documents processed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white60
                        : AppColors.primary.withValues(alpha: 70),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.borderFull,
            ),
            child: const Text(
              'Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChange;

  const _ThemeSegmentedControl({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface3 : AppColors.neutral100,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeSegment(
            icon: Icons.light_mode_rounded,
            mode: ThemeMode.light,
            current: current,
            onTap: () => onChange(ThemeMode.light),
          ),
          _ThemeSegment(
            icon: Icons.brightness_auto_rounded,
            mode: ThemeMode.system,
            current: current,
            onTap: () => onChange(ThemeMode.system),
          ),
          _ThemeSegment(
            icon: Icons.dark_mode_rounded,
            mode: ThemeMode.dark,
            current: current,
            onTap: () => onChange(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode current;
  final VoidCallback onTap;

  const _ThemeSegment({
    required this.icon,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == mode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 30,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).cardTheme.color
              : Colors.transparent,
          borderRadius: AppRadius.borderSm,
          boxShadow: isSelected ? AppShadows.xs : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  static const _languages = [
    ('English (US)', '🇺🇸', true),
    ('Urdu (اردو)', '🇵🇰', false),
    ('Arabic (العربية)', '🇸🇦', false),
    ('French (Français)', '🇫🇷', false),
    ('German (Deutsch)', '🇩🇪', false),
    ('Spanish (Español)', '🇪🇸', false),
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
            Text('App Language', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            ..._languages.map((lang) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(lang.$2, style: const TextStyle(fontSize: 24)),
                  title: Text(lang.$1),
                  trailing: lang.$3
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context),
                )),
          ],
        ),
      ),
    );
  }
}

class _OcrLanguageSheet extends StatelessWidget {
  const _OcrLanguageSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final langs = [
      ('English', '🇺🇸', true),
      ('Urdu (اردو)', '🇵🇰', true),
      ('Arabic (العربية)', '🇸🇦', false),
      ('French', '🇫🇷', false),
      ('Chinese', '🇨🇳', false),
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
            Text('OCR Languages', style: theme.textTheme.titleMedium),
            Text(
              'Select languages for text recognition',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...langs.map((lang) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(lang.$2, style: const TextStyle(fontSize: 22)),
                  title: Text(lang.$1),
                  trailing: Switch(
                    value: lang.$3,
                    onChanged: (_) {},
                    activeThumbColor: AppColors.primary,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
