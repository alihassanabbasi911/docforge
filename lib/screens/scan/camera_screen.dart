import 'package:flex_scan/providers/app_providers.dart';
import 'package:flex_scan/router/app_router.dart';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key, required this.width, required this.height});
  final double width;
  final double height;
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  late CameraController controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();

    if (!mounted) return;

    setState(() => isReady = true);
  }

  @override
  void dispose() {
    controller.dispose(); // CRITICAL
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final torchOn = ref.watch(torchControlProvider);
    torchOn
        ? controller.setFlashMode(FlashMode.torch)
        : controller.setFlashMode(FlashMode.off);
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: CameraPreview(controller),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(extractTextProvider);
                state.whenOrNull(
                  loading: () => const CircularProgressIndicator(),
                );
                return GestureDetector(
                  onTap: () async {
                    final scaffold = ScaffoldMessenger.of(context);
                    final path = await captureImage();
                    if (!context.mounted) return;
                    try {
                      await ref
                          .read(extractTextProvider.notifier)
                          .extractText(path);
                      if (!context.mounted) return;
                      context.push(AppRoutes.editor);
                    } catch (e) {
                      scaffold.showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Failed to extract text from image. Please try again.')),
                      );
                    }
                  },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<String> captureImage() async {
    final file = await controller.takePicture();
    return file.path;
  }
}
