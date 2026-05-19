import 'package:FlexScan/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hasTyped = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _passwordController.addListener(() {
      if (!_hasTyped && _passwordController.text.isNotEmpty) {
        setState(() => _hasTyped = true);
      } else if (_hasTyped && _passwordController.text.isEmpty) {
        setState(() => _hasTyped = false);
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  Future<void> _handleDelete() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .deletePasswordAccount(_passwordController.text);

      if (!mounted) return;
      _showSuccessAndExit();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _triggerShake();
      _showErrorSnackbar(e.toString());
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE53935),
              size: 40,
            ),
            title: const Text(
              'Delete account?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            content: const Text(
              'This will permanently erase your account and all associated data. '
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Yes, delete my account'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessAndExit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your account has been deleted.'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                const _DangerBadge(),
                const SizedBox(height: 20),
                Text(
                  'Delete account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your password to confirm. This action is permanent '
                  'and cannot be reversed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Warning card ─────────────────────────────────
                const _WarningCard(
                  items: [
                    'All your data will be permanently deleted',
                    'You will lose access to all your content',
                    'Any active subscriptions will be cancelled',
                  ],
                ),

                const SizedBox(height: 32),

                // ── Password form ────────────────────────────────
                Form(
                  key: _formKey,
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final offset =
                          _shakeController.isAnimating ? _shakeOffset() : 0.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleDelete(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your current password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withOpacity(0.4),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Delete button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _handleDelete,
                    style: FilledButton.styleFrom(
                      backgroundColor: _hasTyped
                          ? const Color(0xFFE53935)
                          : colorScheme.onSurface.withAlpha(30),
                      foregroundColor: _hasTyped
                          ? Colors.white
                          : colorScheme.onSurface.withAlpha(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_forever_rounded),
                    label: Text(
                      _isLoading ? 'Deleting account…' : 'Delete my account',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Cancel link ──────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text('Cancel, keep my account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Produces a sine-wave offset for the shake animation.
  double _shakeOffset() {
    const amplitude = 10.0;
    const frequency = 3.0;
    return amplitude *
        (1 - _shakeAnimation.value) *
        (2 * 3.14159 * frequency * _shakeAnimation.value).clamp(-1.0, 1.0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DangerBadge extends StatelessWidget {
  const _DangerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dangerous_outlined, size: 14, color: Color(0xFFE53935)),
          SizedBox(width: 6),
          Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE53935),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final List<String> items;
  const _WarningCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Color(0xFFF57F17)),
              SizedBox(width: 6),
              Text(
                'What will happen',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFFF57F17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child:
                        Icon(Icons.circle, size: 5, color: Color(0xFFF57F17)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                          fontSize: 13, height: 1.4, color: Color(0xFF5D4037)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
