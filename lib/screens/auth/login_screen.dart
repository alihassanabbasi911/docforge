// lib/screens/auth/login_screen.dart
import 'package:flex_scan/providers/auth_providers.dart';
import 'package:flex_scan/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    // Simulate API call
    await ref.read(authProvider.notifier).loginInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    setState(() => _isLoading = false);
  }

  void _socialLogin(String provider) async {
    HapticFeedback.lightImpact();
    if (provider == 'Google') {
      await ref.read(authProvider.notifier).signInWithGoogle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    ref.listen(authProvider, (prev, next) {
      next.when(
        data: (value) {
          context.go(AppRoutes.home);
        },
        error: (e, st) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderSm),
              backgroundColor: const Color.fromARGB(255, 106, 26, 243),
            ),
          );
        },
        loading: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Logging in...'),
                    ],
                  ),
                );
              });
        },
      );
    });

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(28, 20, 28, padding.bottom + 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - padding.top - padding.bottom - 44,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo ────────────────────────────────────
                        const Center(child: ForgeLogoMark(size: 52)),

                        const SizedBox(height: 40),

                        // ── Headline ────────────────────────────────
                        Text('Welcome back',
                            style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to your account to continue',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Form ────────────────────────────────────
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email
                              ForgeTextField(
                                label: 'Email address',
                                hint: 'you@example.com',
                                prefixIcon: Icons.email_outlined,
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofocus: true,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                          r'^[\w\-.]+@([\w\-]+\.)+[\w]{2,}$')
                                      .hasMatch(v.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password
                              ForgeTextField(
                                label: 'Password',
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                controller: _passwordCtrl,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                onEditingComplete: _submit,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              // Remember me + Forgot password
                              Row(
                                children: [
                                  const Spacer(),

                                  // Forgot password
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // Sign In Button
                              _SubmitButton(
                                label: 'Sign In',
                                icon: Icons.arrow_forward_rounded,
                                isLoading: _isLoading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Social Auth ─────────────────────────────
                        const OrDivider(),
                        const SizedBox(height: 20),

                        SocialButton(
                          label: 'Continue with Google',
                          icon: const GoogleIcon(size: 20),
                          onTap: () => _socialLogin('Google'),
                        ),
                        // const SizedBox(height: 12),
                        // SocialButton(
                        //   label: 'Continue with Microsoft',
                        //   icon: const MicrosoftIcon(size: 22),
                        //   onTap: () => _socialLogin('Microsoft'),
                        // ),

                        const Spacer(),
                        const SizedBox(height: 32),

                        // ── Register Link ───────────────────────────
                        AuthLinkRow(
                          question: "Don't have an account?",
                          actionLabel: 'Create one',
                          onTap: () => Navigator.pushReplacement(
                            context,
                            _fadeRoute(const RegisterScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Register Screen
// ─────────────────────────────────────────────

// lib/screens/auth/register_screen.dart
// (imported above — see separate file)

// ─────────────────────────────────────────────
// Shared: animated submit button
// ─────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withAlpha(120),
        elevation: 0,
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.white.withAlpha(30)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: isLoading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                key: const ValueKey('label'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: Colors.white),
                ],
              ),
      ),
    );
  }
}

PageRouteBuilder<void> _fadeRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
