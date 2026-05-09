// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  final _nameCtrl         = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmCtrl      = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading     = false;
  bool _obscureConfirm = true;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

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
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to continue'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created! Welcome, ${_nameCtrl.text.trim().split(' ').first} 🎉'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _socialRegister(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-up — connect OAuth to enable')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final size    = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

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
                          'Join DocForge — it only takes a minute',
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: SocialButton(
                                label: 'Apple',
                                icon: const AppleIcon(size: 20),
                                onTap: () => _socialRegister('Apple'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const OrDivider(),
                        const SizedBox(height: 24),

                        // ── Form ────────────────────────────────────
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Full name
                              ForgeTextField(
                                label: 'Full name',
                                hint: 'Ali Hassan Abbasi',
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

                              const SizedBox(height: 20),

                              // Terms checkbox
                              _TermsCheckbox(
                                accepted: _acceptedTerms,
                                onChanged: (v) =>
                                    setState(() => _acceptedTerms = v),
                                onTermsTap: () => _showTermsSheet(context),
                                onPrivacyTap: () => _showTermsSheet(context),
                              ),

                              const SizedBox(height: 24),

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

  void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.xl)),
      builder: (_) => const _TermsSheet(),
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
class _TermsCheckbox extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const _TermsCheckbox({
    required this.accepted,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!accepted),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accepted
              ? (isDark
                  ? const Color(0xFF1E1B4B)
                  : AppColors.primaryContainer)
              : (isDark ? AppColors.darkSurface2 : AppColors.neutral50),
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: accepted
                ? AppColors.primary.withOpacity(0.5)
                : (isDark ? AppColors.darkSurface3 : AppColors.neutral200),
            width: accepted ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: accepted,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: onTermsTap,
                        child: Text(
                          'Terms of Service',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: onPrivacyTap,
                        child: Text(
                          'Privacy Policy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: '. Your data is safe with us.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Terms Bottom Sheet
// ─────────────────────────────────────────────
class _TermsSheet extends StatelessWidget {
  const _TermsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      builder: (ctx, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.primary),
                const SizedBox(width: 10),
                Text('Terms of Service', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: theme.dividerColor),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TermsSection('1. Acceptance of Terms',
                      'By creating a DocForge account, you agree to these Terms of Service, our Privacy Policy, and all applicable laws and regulations.'),
                  _TermsSection('2. Use of Service',
                      'DocForge provides document scanning, OCR, and conversion services. You may use the service only for lawful purposes and in accordance with these Terms.'),
                  _TermsSection('3. Your Content',
                      'You retain ownership of documents you process through DocForge. By using the service, you grant us a limited license to process your content for the purpose of delivering our services.'),
                  _TermsSection('4. Privacy',
                      'We collect minimal data necessary to operate the service. We do not sell your personal information to third parties. Document content is processed ephemerally and not stored permanently unless you choose to save it.'),
                  _TermsSection('5. Intellectual Property',
                      'The DocForge application, including its design, code, and branding, is owned by DocForge Technologies and protected by applicable intellectual property laws.'),
                  _TermsSection('6. Limitation of Liability',
                      'DocForge provides OCR and conversion services on a best-effort basis. We do not guarantee 100% accuracy in text extraction and are not liable for errors in processed documents.'),
                  _TermsSection('7. Termination',
                      'We reserve the right to terminate or suspend accounts that violate these Terms. You may delete your account at any time from the Settings screen.'),
                  _TermsSection('8. Changes to Terms',
                      'We may update these Terms periodically. Continued use of the service after changes constitutes acceptance of the revised Terms.'),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: May 2025',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 8, 24, MediaQuery.paddingOf(context).bottom + 16),
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;
  const _TermsSection(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
              )),
          const SizedBox(height: 6),
          Text(body,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.7)),
        ],
      ),
    );
  }
}

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
        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
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
