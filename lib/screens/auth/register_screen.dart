// lib/screens/auth/register_screen.dart

import 'package:flex_scan/providers/auth_providers.dart';
import 'package:flex_scan/router/app_router.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscureConfirm = true;

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

    // Rebuild on password change so strength indicator updates
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    // API call
    await ref.read(authProvider.notifier).registerWithEmailAndPassword(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
    final state = ref.read(authProvider);
    state.whenData(
      (value) {
        showAdaptiveDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text(
                  "Congratulations",
                  style: TextStyle(
                      color: Colors.green,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'Account Created! Please verify your email to login',
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ),
                ],
              );
            });
        context.go(AppRoutes.login);
      },
    );

    setState(() => _isLoading = false);
  }

  void _socialRegister(String provider) async {
    HapticFeedback.lightImpact();

    if (provider == 'Google') {
      await ref.read(authProvider.notifier).signInWithGoogle();
      final state = ref.read(authProvider);
      state.whenData(
        (value) {
          context.go(AppRoutes.home);
        },
      );
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
          // Account created successfully, but user still needs to verify email
          context.pop();
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
              shape: Border.all(),
              backgroundColor: Colors.blue,
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
                      Text('Creating account...'),
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
                        Text('Create account',
                            style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Join FlexScan — it only takes a minute',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Social quick-register ───────────────────
                        Row(
                          children: [
                            Expanded(
                              child: SocialButton(
                                label: 'Google',
                                icon: const GoogleIcon(size: 18),
                                onTap: () => _socialRegister('Google'),
                              ),
                            ),
                            // const SizedBox(width: 12),
                            // Expanded(
                            //   child: SocialButton(
                            //     label: 'Microsoft',
                            //     icon: const MicrosoftIcon(size: 20),
                            //     onTap: () => _socialRegister('Microsoft'),
                            //   ),
                            // ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const OrDivider(),
                        const SizedBox(height: 24),

                        // ── Form ────────────────────────────────────
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full name
                              ForgeTextField(
                                label: 'Full name',
                                hint: 'John Doe',
                                prefixIcon: Icons.person_outline_rounded,
                                controller: _nameCtrl,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                autofocus: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z\s]')),
                                ],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Full name is required';
                                  }
                                  if (v.trim().split(' ').length < 2) {
                                    return 'Please enter your first and last name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Email
                              ForgeTextField(
                                label: 'Email address',
                                hint: 'you@example.com',
                                prefixIcon: Icons.email_outlined,
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
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
                                hint: 'Min. 8 characters',
                                prefixIcon: Icons.lock_outline_rounded,
                                controller: _passwordCtrl,
                                isPassword: true,
                                textInputAction: TextInputAction.next,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$')
                                      .hasMatch(v)) {
                                    return 'Password must contain letters and numbers';
                                  }
                                  if (_confirmCtrl.text.isNotEmpty &&
                                      v != _confirmCtrl.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              // Password strength
                              PasswordStrengthIndicator(
                                  password: _passwordCtrl.text),

                              const SizedBox(height: 16),

                              // Confirm password
                              _ConfirmPasswordField(
                                controller: _confirmCtrl,
                                passwordController: _passwordCtrl,
                                obscure: _obscureConfirm,
                                onToggle: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),

                              const SizedBox(height: 24),

                              // Terms checkbox

                              // Create account button
                              _SubmitButton(
                                label: 'Create Account',
                                icon: Icons.person_add_rounded,
                                isLoading: _isLoading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 32),

                        // ── Login link ──────────────────────────────
                        AuthLinkRow(
                          question: 'Already have an account?',
                          actionLabel: 'Sign in',
                          onTap: () => Navigator.pushReplacement(
                            context,
                            _fadeRoute(const LoginScreen()),
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
// Confirm Password Field (custom — needs access
// to the password controller for cross-validation)
// ─────────────────────────────────────────────
class _ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback onToggle;

  const _ConfirmPasswordField({
    required this.controller,
    required this.passwordController,
    required this.obscure,
    required this.onToggle,
  });

  @override
  State<_ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<_ConfirmPasswordField> {
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscure,
      textInputAction: TextInputAction.done,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Confirm password',
        hintText: '••••••••',
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: _isFocused
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 52),
        suffixIcon: IconButton(
          icon: Icon(
            widget.obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: widget.onToggle,
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != widget.passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}

// ─────────────────────────────────────────────
// Terms & Privacy Checkbox
// ─────────────────────────────────────────────

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
                        color: Colors.white),
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
