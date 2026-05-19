import 'package:FlexScan/providers/auth_providers.dart';
import 'package:FlexScan/router/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthStateScreen extends ConsumerStatefulWidget {
  const AuthStateScreen({super.key});

  @override
  ConsumerState<AuthStateScreen> createState() => _AuthStateScreenState();
}

class _AuthStateScreenState extends ConsumerState<AuthStateScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(authStateProvider, (prev, next) {
      next.when(
        data: (user) {
          if (user != null) {
            context.go(AppRoutes.home);
          } else {
            context.go(AppRoutes.onboarding);
          }
        },
        error: (e, st) {
          context.go(AppRoutes.onboarding);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
        loading: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
