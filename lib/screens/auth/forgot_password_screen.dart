// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

/// Two-step flow:
///   Step 1 → Enter email → Send reset link
///   Step 2 → Enter OTP → Verify
///   Step 3 → Success
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  int    _step      = 0; // 0 = email, 1 = OTP, 2 = success
  bool   _isLoading = false;
  String _otpCode   = '';
  int    _resendSec = 59;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _step = 1;
    });
    _animCtrl.forward(from: 0);
    _startResendTimer();
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _step = 2;
    });
    _animCtrl.forward(from: 0);
  }

  void _startResendTimer() async {
    setState(() => _resendSec = 59);
    while (_resendSec > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _resendSec--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () {
                        if (_step > 0) {
                          setState(() => _step--);
                          _animCtrl.forward(from: 0);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    // Step progress
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _step ? 24 : 8,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i <= _step
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: AppRadius.borderFull,
                            ),
                          );
                        }),
                      ),
                    ),
                    // Balance the back button
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        28, 24, 28, padding.bottom + 24),
                    child: _buildStep(theme),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(ThemeData theme) {
    switch (_step) {
      case 0:
        return _EmailStep(
          formKey: _formKey,
          controller: _emailCtrl,
          isLoading: _isLoading,
          onSubmit: _sendCode,
        );
      case 1:
        return _OtpStep(
          email: _emailCtrl.text.trim(),
          resendSec: _resendSec,
          isLoading: _isLoading,
          onCompleted: (code) => setState(() => _otpCode = code),
          onVerify: _verifyOtp,
          onResend: () {
            _startResendTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('New code sent!')),
            );
          },
        );
      case 2:
      default:
        return _SuccessStep(onDone: () => Navigator.pop(context));
    }
  }
}

// ─────────────────────────────────────────────
// Step 0 — Email entry
// ─────────────────────────────────────────────
class _EmailStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _EmailStep({
    required this.formKey,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.borderXl,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),

        Text('Forgot password?', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          "No worries — enter your email and we'll send a verification code to reset it.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),

        Form(
          key: formKey,
          child: ForgeTextField(
            label: 'Email address',
            hint: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofocus: true,
            onEditingComplete: onSubmit,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w]{2,}$')
                  .hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 28),

        FilledButton(
          onPressed: isLoading ? null : onSubmit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
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
                : const Row(
                    key: ValueKey('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Send Reset Code',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // Info row
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Check your spam folder if you don\'t receive the code within 2 minutes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Step 1 — OTP entry
// ─────────────────────────────────────────────
class _OtpStep extends StatelessWidget {
  final String email;
  final int resendSec;
  final bool isLoading;
  final ValueChanged<String> onCompleted;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const _OtpStep({
    required this.email,
    required this.resendSec,
    required this.isLoading,
    required this.onCompleted,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.successContainer,
            borderRadius: AppRadius.borderXl,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.success,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),

        Text('Check your email', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            children: [
              const TextSpan(text: 'We sent a 6-digit code to '),
              TextSpan(
                text: email,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                  text: '. Enter it below to continue.'),
            ],
          ),
        ),

        const SizedBox(height: 36),

        Text(
          'Verification code',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16),

        OtpInput(length: 6, onCompleted: onCompleted),

        const SizedBox(height: 28),

        FilledButton(
          onPressed: isLoading ? null : onVerify,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape:
                const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
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
                : const Row(
                    key: ValueKey('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Verify Code',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle_outline_rounded,
                          size: 18, color: Colors.white),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // Resend row
        Center(
          child: resendSec > 0
              ? Text(
                  'Resend code in 0:${resendSec.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : TextButton.icon(
                  onPressed: onResend,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("Didn't receive it? Resend"),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Step 2 — Success
// ─────────────────────────────────────────────
class _SuccessStep extends StatelessWidget {
  final VoidCallback onDone;

  const _SuccessStep({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),

        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: AppColors.successContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 52,
          ),
        ),

        const SizedBox(height: 32),

        Text('Password reset!', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Your password has been successfully reset.\nYou can now sign in with your new credentials.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        FilledButton(
          onPressed: onDone,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape:
                const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Back to Sign In',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              SizedBox(width: 8),
              Icon(Icons.login_rounded, size: 18, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
