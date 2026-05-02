// lib/screens/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history_rounded),
      label: 'History',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navIndex,
          onDestinationSelected: (i) {
            ref.read(navIndexProvider.notifier).state = i;
            switch (i) {
              case 0:
                context.go(AppRoutes.home);
              case 1:
                context.go(AppRoutes.history);
              case 2:
                context.go(AppRoutes.settings);
            }
          },
          destinations: _destinations,
        ),
      ),
    );
  }
}
