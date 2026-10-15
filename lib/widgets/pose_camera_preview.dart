import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../pose_engine/pose_detector_factory.dart';
import '../theme/app_colors.dart';
import 'pose_skeleton_painter.dart';

class PoseCameraPreview extends StatefulWidget {
  final bool active;
  final String exerciseId;
  final String exerciseName;
  final String kind;
  final VoidCallback onRep;
  final ValueChanged<String> onCue;
  final ValueChanged<int> onScore;

  const PoseCameraPreview({
    super.key,
    required this.active,
    required this.exerciseId,
    required this.exerciseName,
    required this.kind,
    required this.onRep,
    required this.onCue,
    required this.onScore,
  });

  @override
  State<PoseCameraPreview> createState() => _PoseCameraPreviewState();
}

class _PoseCameraPreviewState extends State<PoseCameraPreview> {
  CameraController? _controller;
  late final PoseDetector _detector;
  late final PoseDetectorEngine _engine;
  bool _busy = false;
  String _message = 'Tap Start camera session to enable AI coaching.';
  Pose? _currentPose;
  Size _imageSize = Size.zero;
  InputImageRotation _imageRotation = InputImageRotation.rotation0deg;
  bool _isFrontCamera = true;
  bool _bodyDetected = false;

  @override
  void initState() {
    super.initState();
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
    _engine = PoseDetectorEngine(
      exerciseId: widget.exerciseId,
      exerciseName: widget.exerciseName,
      kind: widget.kind,
    );
  }

  @override
  void didUpdateWidget(PoseCameraPreview old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _start();
    }
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _isFrontCamera = front.lensDirection == CameraLensDirection.front;

      final next = CameraController(
        front,
        ResolutionPreset.medium, // 720p HD balanced for speed and clarity
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );
      await next.initialize();
      await next.startImageStream(_processFrame);
      if (mounted) {
        setState(() {
          _controller = next;
          _message = 'AI Camera Active • Stand centered in view';
        });
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _message = 'Camera error: ${e.description ?? e.code}');
      }
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation0deg;

    // Build byte buffer safely across single-plane and multi-plane platforms
    Uint8List bytes;
    if (image.planes.length == 1) {
      bytes = image.planes.first.bytes;
    } else {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      bytes = allBytes.done().buffer.asUint8List();
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
        (image.planes.length == 1 ? InputImageFormat.nv21 : InputImageFormat.yuv_420_888);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_busy || _controller == null) return;
    _busy = true;
    try {
      final input = _buildInputImage(image);
      if (input == null) return;

      final poses = await _detector.processImage(input);
      if (poses.isNotEmpty) {
        final pose = poses.first;
        final hasKeyJoints = pose.landmarks.values.any((l) => l.likelihood > 0.35);

        if (mounted) {
          setState(() {
            _currentPose = pose;
            _bodyDetected = hasKeyJoints;

            // In portrait rotation (90 or 270 deg), camera width & height are swapped
            if (input.metadata?.rotation == InputImageRotation.rotation90deg ||
                input.metadata?.rotation == InputImageRotation.rotation270deg) {
              _imageSize = Size(image.height.toDouble(), image.width.toDouble());
            } else {
              _imageSize = Size(image.width.toDouble(), image.height.toDouble());
            }
            _imageRotation = input.metadata!.rotation;
          });
        }

        _engine.evaluate(
          pose: pose,
          onCue: widget.onCue,
          onScore: widget.onScore,
          onRep: widget.onRep,
        );
      } else {
        if (mounted && _bodyDetected) {
          setState(() => _bodyDetected = false);
        }
      }
    } catch (e) {
      debugPrint('Pose detection frame processing error: $e');
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detector.close();
    _engine.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _bodyDetected
              ? AppColors.primary
              : AppColors.border,
          width: _bodyDetected ? 2 : 1,
        ),
      ),
      child: c != null && c.value.isInitialized
          ? LayoutBuilder(
              builder: (context, constraints) {
                // Ensure proper aspect ratio without squishing or black bars
                final double cameraAspectRatio = c.value.aspectRatio; // e.g. 16/9
                final double previewAspectRatio = 1 / cameraAspectRatio; // portrait: 9/16
                final double containerAspectRatio = constraints.maxWidth / constraints.maxHeight;

                double scale;
                if (containerAspectRatio < previewAspectRatio) {
                  scale = (constraints.maxHeight * previewAspectRatio) / constraints.maxWidth;
                } else {
                  scale = constraints.maxWidth / (constraints.maxHeight * previewAspectRatio);
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Perfectly Scaled Camera Preview (Cover Fit)
                    Center(
                      child: Transform.scale(
                        scale: scale,
                        child: AspectRatio(
                          aspectRatio: previewAspectRatio,
                          child: CameraPreview(c),
                        ),
                      ),
                    ),

                    // Perfectly Aligned AI Skeleton Overlay
                    Center(
                      child: Transform.scale(
                        scale: scale,
                        child: AspectRatio(
                          aspectRatio: previewAspectRatio,
                          child: CustomPaint(
                            painter: PoseSkeletonPainter(
                              pose: _currentPose,
                              imageSize: _imageSize,
                              rotation: _imageRotation,
                              isFrontCamera: _isFrontCamera,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Camera Placement & Framing Overlay (Silhouette Target Box)
                    _buildFramingGuideBox(),

                    // Top Placement & Tracking Status Chip
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xDD0B1220),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _bodyDetected ? AppColors.primary : AppColors.warning,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _bodyDetected ? Icons.check_circle : Icons.person_pin_circle_outlined,
                              color: _bodyDetected ? AppColors.primary : AppColors.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _bodyDetected
                                  ? 'Body Tracked • Ready for Reps'
                                  : 'Stand 4–6 ft away • Center body',
                              style: TextStyle(
                                color: _bodyDetected ? AppColors.textPrimary : AppColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 76,
                  color: widget.active ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
    );
  }

  Widget _buildFramingGuideBox() {
    return IgnorePointer(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _bodyDetected
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.warning.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
