// lib/router/app_router.dart
import 'package:docforge/auth_state.dart';
import 'package:docforge/screens/auth/login_screen.dart';
import 'package:docforge/screens/auth/register_screen.dart';
import 'package:docforge/screens/auth/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/processing/processing_screen.dart';
import '../screens/editor/editor_screen.dart';
import '../screens/export/export_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';

abstract class AppRoutes {
  static const authStateChanges = '/';
  static const onboarding = '/onboarding';
  static const register = '/register';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const scan = '/scan';
  static const processing = '/processing';
  static const editor = '/editor';
  static const export = '/export';
  static const history = '/history';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (ctx, state) => _fadeTransition(
        state,
        const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.authStateChanges,
      pageBuilder: (ctx, state) => _fadeTransition(
        state,
        const AuthStateScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (ctx, state) => _slideTransition(state, const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (ctx, state) =>
          _slideTransition(state, const RegisterScreen()),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      pageBuilder: (ctx, state) =>
          _slideTransition(state, const ForgotPasswordScreen()),
    ),
    ShellRoute(
      builder: (ctx, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (ctx, state) =>
              _slideTransition(state, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.history,
          pageBuilder: (ctx, state) =>
              _slideTransition(state, const HistoryScreen()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (ctx, state) =>
              _slideTransition(state, const SettingsScreen()),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.scan,
      pageBuilder: (ctx, state) =>
          _slideUpTransition(state, const ScanScreen()),
    ),
    GoRoute(
      path: AppRoutes.processing,
      pageBuilder: (ctx, state) =>
          _fadeTransition(state, const ProcessingScreen()),
    ),
    GoRoute(
      path: AppRoutes.editor,
      pageBuilder: (ctx, state) =>
          _slideTransition(state, const EditorScreen()),
    ),
    GoRoute(
      path: AppRoutes.export,
      pageBuilder: (ctx, state) =>
          _slideUpTransition(state, const ExportScreen()),
    ),
  ],
);

CustomTransitionPage<void> _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (ctx, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

CustomTransitionPage<void> _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (ctx, animation, secondary, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}

CustomTransitionPage<void> _slideUpTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (ctx, animation, secondary, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 320),
  );
}
