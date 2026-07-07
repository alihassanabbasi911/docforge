// lib/widgets/auth_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
// FlexScan Logo Mark
// ─────────────────────────────────────────────
class ForgeLogoMark extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const ForgeLogoMark({super.key, this.size = 48, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.borderMd,
            boxShadow: AppShadows.primary,
          ),
          child: Icon(
            Icons.description_rounded,
            color: Colors.white,
            size: size * 0.46,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 10),
          Text(
            'FlexScan',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Forge Text Field (auth variant)
// ─────────────────────────────────────────────
class ForgeTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final Widget? suffix;

  const ForgeTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.inputFormatters,
    this.autofocus = false,
    this.suffix,
  });

  @override
  State<ForgeTextField> createState() => _ForgeTextFieldState();
}

class _ForgeTextFieldState extends State<ForgeTextField> {
  bool _obscure = true;
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
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            widget.prefixIcon,
            size: 20,
            color: _isFocused
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 52),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffix,
                  )
                : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Password Strength Indicator
// ─────────────────────────────────────────────
enum PasswordStrength { empty, weak, fair, strong, veryStrong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  PasswordStrength get _strength {
    if (password.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.fair;
    if (score == 3) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  Color _color(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.empty:
        return AppColors.neutral300;
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.fair:
        return AppColors.warning;
      case PasswordStrength.strong:
        return AppColors.success;
      case PasswordStrength.veryStrong:
        return const Color(0xFF059669);
    }
  }

  String _label(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  int _filledBars(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.empty:
        return 0;
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.fair:
        return 2;
      case PasswordStrength.strong:
        return 3;
      case PasswordStrength.veryStrong:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _strength;
    final color = _color(strength);
    final filled = _filledBars(strength);

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < filled
                        ? color
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.borderFull,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.shield_outlined,
                size: 13, color: AppColors.neutral400),
            const SizedBox(width: 4),
            Text(
              'Password strength: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _label(strength),
                key: ValueKey(strength),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Social Sign-In Button
// ─────────────────────────────────────────────
class SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : Colors.white,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
            width: 1.5,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Or Divider
// ─────────────────────────────────────────────
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: theme.colorScheme.outline, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.colorScheme.outline, height: 1)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Google Icon (inline SVG-style)
// ─────────────────────────────────────────────
class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Simplified Google "G" icon using colored arcs
    final red = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final green = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final yellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;

    final outerRect = Rect.fromCircle(center: center, radius: r);

    // Draw quadrant arcs to approximate the Google logo
    canvas.drawArc(outerRect, -1.57, 1.57, true, blue); // top right (blue)
    canvas.drawArc(outerRect, 0, 1.57, true, red); // bottom right (red)
    canvas.drawArc(outerRect, 1.57, 1.57, true, yellow); // bottom left (yellow)
    canvas.drawArc(outerRect, -3.14, 1.57, true, green); // top left (green)

    // White center circle to create the "G" cutout feel
    canvas.drawCircle(center, r * 0.55, Paint()..color = Colors.white);

    // Blue bar (the horizontal bar of the "G")
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - r * 0.12, r * 0.95, r * 0.25),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Apple Icon
// ─────────────────────────────────────────────
class MicrosoftIcon extends StatelessWidget {
  final double size;
  const MicrosoftIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      Icons.window_sharp,
      size: size,
      color: isDark ? Colors.yellow : Colors.indigo,
    );
  }
}

// ─────────────────────────────────────────────
// Auth Link Row (e.g. "Don't have an account? Sign Up")
// ─────────────────────────────────────────────
class AuthLinkRow extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  const AuthLinkRow({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            ' $actionLabel',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Auth Screen Background (subtle gradient + pattern)
// ─────────────────────────────────────────────
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D0B1E), AppColors.darkSurface],
                    stops: [0.0, 0.5],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEEF2FF), AppColors.neutral50],
                    stops: [0.0, 0.45],
                  ),
          ),
        ),

        // Decorative circles (top-right + bottom-left)
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(isDark ? 21 : 16),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3AED).withAlpha(isDark ? 26 : 18),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(isDark ? 13 : 10),
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Verification Code Input (4-digit OTP boxes)
// ─────────────────────────────────────────────
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;

  const OtpInput({super.key, this.length = 6, required this.onCompleted});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String val) {
    if (val.length > 1) {
      // Handle paste
      final chars = val.split('').take(widget.length - i).toList();
      for (int j = 0; j < chars.length; j++) {
        _controllers[i + j].text = chars[j];
      }
      final nextIdx = (i + chars.length).clamp(0, widget.length - 1);
      _focusNodes[nextIdx].requestFocus();
    } else if (val.isNotEmpty && i < widget.length - 1) {
      _focusNodes[i + 1].requestFocus();
    } else if (val.isEmpty && i > 0) {
      _focusNodes[i - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length) widget.onCompleted(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextFormField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 2, // 2 to allow replace-in-place
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => _onChanged(i, v),
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: isDark ? AppColors.darkSurface2 : Colors.white,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
