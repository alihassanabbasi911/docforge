// lib/screens/processing/processing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for completion and auto-navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitAndNavigate();
    });
  }

  Future<void> _waitAndNavigate() async {
    // Small delay to let the UI settle
    await Future.delayed(const Duration(milliseconds: 400));

    // Wait for processing to complete
    while (mounted) {
      final status = ref.read(ocrProvider).status;
      if (status == OcrStatus.completed) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.pushReplacement(AppRoutes.editor);
        break;
      } else if (status == OcrStatus.failed) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ocrState = ref.watch(ocrProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // Back/cancel
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    ref.read(ocrProvider.notifier).reset();
                    context.go(AppRoutes.home);
                  },
                ),
              ),

              const SizedBox(height: 48),

              // Animated icon
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFF1E1B4B)
                        : AppColors.primaryContainer,
                    boxShadow: AppShadows.primary,
                  ),
                  child: ocrState.status == OcrStatus.completed
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 56,
                        )
                      : ocrState.status == OcrStatus.failed
                          ? const Icon(
                              Icons.error_rounded,
                              color: AppColors.error,
                              size: 56,
                            )
                          : const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.primary,
                              size: 56,
                            ),
                ),
              ),

              const SizedBox(height: 40),

              // Status text
              Text(
                ocrState.statusLabel,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                ocrState.status == OcrStatus.completed
                    ? 'Your document is ready to edit.'
                    : ocrState.status == OcrStatus.failed
                        ? 'Something went wrong. Please try again.'
                        : 'This usually takes a few seconds.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Progress section
              if (ocrState.status != OcrStatus.failed) ...[
                // Step indicators
                _ProcessingSteps(status: ocrState.status),

                const SizedBox(height: 40),

                // Progress bar
                _AnimatedProgressBar(progress: ocrState.progress),

                const SizedBox(height: 12),

                Text(
                  '${(ocrState.progress * 100).toInt()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],

              const Spacer(),

              if (ocrState.status == OcrStatus.failed) ...[
                FilledButton(
                  onPressed: () {
                    ref.read(ocrProvider.notifier).reset();
                    context.go(AppRoutes.home);
                  },
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 32),
              ],

              if (ocrState.status == OcrStatus.completed) ...[
                FilledButton(
                  onPressed: () => context.pushReplacement(AppRoutes.editor),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('View & Edit Document'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Dots while processing
              if (ocrState.status == OcrStatus.scanning ||
                  ocrState.status == OcrStatus.extracting) ...[
                const LoadingDots(),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessingSteps extends StatelessWidget {
  final OcrStatus status;

  const _ProcessingSteps({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final steps = [
      _Step(
        label: 'Scanning',
        icon: Icons.camera_alt_rounded,
        isDone: status == OcrStatus.extracting || status == OcrStatus.completed,
        isActive: status == OcrStatus.scanning,
      ),
      _Step(
        label: 'Extracting',
        icon: Icons.text_fields_rounded,
        isDone: status == OcrStatus.completed,
        isActive: status == OcrStatus.extracting,
      ),
      _Step(
        label: 'Complete',
        icon: Icons.check_rounded,
        isDone: status == OcrStatus.completed,
        isActive: false,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _StepIndicator(step: steps[i]),
          if (i < steps.length - 1) _StepConnector(done: steps[i].isDone),
        ],
      ],
    );
  }
}

class _Step {
  final String label;
  final IconData icon;
  final bool isDone;
  final bool isActive;

  const _Step({
    required this.label,
    required this.icon,
    required this.isDone,
    required this.isActive,
  });
}

class _StepIndicator extends StatelessWidget {
  final _Step step;

  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bg;
    Color iconColor;
    if (step.isDone) {
      bg = AppColors.success;
      iconColor = Colors.white;
    } else if (step.isActive) {
      bg = AppColors.primary;
      iconColor = Colors.white;
    } else {
      bg = theme.colorScheme.surfaceContainerHighest;
      iconColor = theme.colorScheme.onSurfaceVariant;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: step.isActive ? AppShadows.primary : [],
          ),
          child: Icon(step.icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          step.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: step.isActive || step.isDone
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool done;

  const _StepConnector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 40,
        height: 2,
        color: done ? AppColors.success : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double progress;

  const _AnimatedProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderFull,
      ),
      child: AnimatedFractionallySizedBox(
        widthFactor: progress,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: AppRadius.borderFull,
          ),
        ),
      ),
    );
  }
}
