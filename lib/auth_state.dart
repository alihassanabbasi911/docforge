import 'package:flex_scan/providers/app_providers.dart';
import 'package:flex_scan/providers/auth_providers.dart';
import 'package:flex_scan/router/app_router.dart';

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
    final persistence = ref.read(persistenceProvider);
    ref.listenManual(authStateProvider, (prev, next) {
      next.when(
        data: (user) {
          if (user != null && persistence) {
            context.go(AppRoutes.home);
          } else if (user != null && !persistence) {
            context.go(AppRoutes.login);
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
    return SizedBox(
      child: Container(),
    );
  }
}
