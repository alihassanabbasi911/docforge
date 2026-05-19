// lib/screens/scan/scan_screen.dart

import 'package:FlexScan/screens/scan/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  bool _flashOn = false;
  bool _gridOn = false;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scanLineAnim = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    ref.listen(extractTextProvider, (prev, next) {
      next.whenOrNull(
        data: (data) {
          if (data != null) {
            context.pop();
            context.go(AppRoutes.editor);
          }
        },
        loading: () {
          showAdaptiveDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return const AlertDialog(
                  title: Text('Extracting text…'),
                  content: SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              });
        },
        error: (error, st) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error extracting text: $error'),
              behavior: SnackBarBehavior.fixed,
              duration: const Duration(minutes: 4),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0D0D0D),
            child: Stack(
              children: [
                // Simulated camera gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Color(0xFF1A1A2E),
                        Color(0xFF0D0D0D),
                      ],
                    ),
                  ),
                ),

                // Grid overlay (optional)
                if (_gridOn) _CameraGrid(),
              ],
            ),
          ),

          // Document frame overlay
          Center(
            child: _DocumentFrame(
              width: size.width * 0.85,
              height: size.height * 0.80, // A4 ratio
              scanLineAnim: _scanLineAnim,
            ),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  _ControlButton(
                    icon: Icons.close_rounded,
                    onTap: () => context.pop(),
                  ),

                  // Title
                  const Text(
                    'Scan Document',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.25,
                    ),
                  ),

                  // Settings / more
                  // _ControlButton(
                  //   icon: Icons.tune_rounded,
                  //   onTap: () => _showScanOptions(context),
                  // ),
                ],
              ),
            ),
          ),

          // Camera controls row
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 72),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer(builder: (context, ref, child) {
                      final torchOn = ref.watch(torchControlProvider);
                      return _SideControl(
                        icon: torchOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        label: 'Flash',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(torchControlProvider.notifier).toggle();
                        },
                        active: torchOn,
                      );
                    }),
                    const SizedBox(height: 16),
                    // _SideControl(
                    //   icon: Icons.grid_on_rounded,
                    //   label: 'Grid',
                    //   onTap: () => setState(() => _gridOn = !_gridOn),
                    //   active: _gridOn,
                    // ),
                  ],
                ),
              ),
            ),
          ),

          // Hint text
          Align(
            alignment: const Alignment(0, 0.82),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: AppRadius.borderFull,
              ),
              child: const Text(
                'Position document within the frame',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                32,
                24,
                32,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Import from gallery
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _importFromGallery();
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Capture button

                  // Import from files
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _importFromFiles();
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.folder_open_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
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

  void _importFromGallery() async {
    final path = await ref.read(docReaderProvider.notifier).readImage();
    if (path != null) {
      await ref.read(extractTextProvider.notifier).extractText(path);
      context.push(AppRoutes.editor);
    }
  }

  void _importFromFiles() async {
    final path = await ref.read(docReaderProvider.notifier).readDocument();
    if (path != null) {
      await ref.read(extractTextProvider.notifier).extractText(path);
      context.push(AppRoutes.editor);
    }
  }

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.xl),
      ),
      builder: (ctx) => const _ScanOptionsSheet(),
    );
  }
}

class _DocumentFrame extends StatelessWidget {
  final double width;
  final double height;
  final Animation<double> scanLineAnim;

  const _DocumentFrame({
    required this.width,
    required this.height,
    required this.scanLineAnim,
  });

  @override
  Widget build(BuildContext context) {
    const cornerSize = 28.0;
    const cornerThickness = 3.0;
    const cornerColor = AppColors.primaryLight;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          CameraScreen(width: width, height: height),
          // Dark overlay outside frame
          ClipPath(
            clipper: _FrameClipper(width: width, height: height),
            child: Container(color: Colors.black54),
          ),

          // Corner indicators
          // TL
          const Positioned(
            top: 0,
            left: 0,
            child: _Corner(
                size: cornerSize,
                thickness: cornerThickness,
                color: cornerColor,
                position: _CornerPosition.topLeft),
          ),
          // TR
          const Positioned(
            top: 0,
            right: 0,
            child: _Corner(
                size: cornerSize,
                thickness: cornerThickness,
                color: cornerColor,
                position: _CornerPosition.topRight),
          ),
          // BL
          const Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(
                size: cornerSize,
                thickness: cornerThickness,
                color: cornerColor,
                position: _CornerPosition.bottomLeft),
          ),
          // BR
          const Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(
                size: cornerSize,
                thickness: cornerThickness,
                color: cornerColor,
                position: _CornerPosition.bottomRight),
          ),

          // Animated scan line
          AnimatedBuilder(
            animation: scanLineAnim,
            builder: (_, __) => Positioned(
              top: height * scanLineAnim.value - 1,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      cornerColor.withAlpha(80),
                      cornerColor,
                      cornerColor.withAlpha(80),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameClipper extends CustomClipper<Path> {
  final double width;
  final double height;

  _FrameClipper({required this.width, required this.height});

  @override
  Path getClip(Size size) {
    // This creates a "hole" in the overlay
    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(Rect.fromLTWH(
            -size.width, -size.height, size.width * 3, size.height * 3)),
      Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, width, height),
          const Radius.circular(4),
        )),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

enum _CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  final double size;
  final double thickness;
  final Color color;
  final _CornerPosition position;

  const _Corner({
    required this.size,
    required this.thickness,
    required this.color,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          thickness: thickness,
          position: position,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final _CornerPosition position;

  _CornerPainter(
      {required this.color, required this.thickness, required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    switch (position) {
      case _CornerPosition.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
      case _CornerPosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
      case _CornerPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
      case _CornerPosition.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SideControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _SideControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.7)
              : Colors.white.withOpacity(0.12),
          borderRadius: AppRadius.borderMd,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 0.5;
    // 3x3 grid
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      final y = size.height * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanOptionsSheet extends StatelessWidget {
  const _ScanOptionsSheet();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white70, fontSize: 14);
    const titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 36,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('Scan Options', style: titleStyle),
          SizedBox(height: 20),
          _OptionTile(
              icon: Icons.auto_fix_high_rounded,
              label: 'Auto enhance',
              subtitle: 'Sharpen & improve contrast'),
          _OptionTile(
              icon: Icons.crop_rotate_rounded,
              label: 'Auto deskew',
              subtitle: 'Correct document angle'),
          _OptionTile(
              icon: Icons.color_lens_rounded,
              label: 'Color mode',
              subtitle: 'Original / Grayscale / B&W'),
          _OptionTile(
              icon: Icons.layers_rounded,
              label: 'Multi-page scan',
              subtitle: 'Combine into single document'),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _OptionTile(
      {required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: false,
            onChanged: (_) {},
            activeThumbColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}
