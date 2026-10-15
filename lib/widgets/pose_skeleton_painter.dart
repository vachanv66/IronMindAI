import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../theme/app_colors.dart';

class PoseSkeletonPainter extends CustomPainter {
  final Pose? pose;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;

  PoseSkeletonPainter({
    required this.pose,
    required this.imageSize,
    required this.rotation,
    this.isFrontCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose == null || imageSize.width == 0 || imageSize.height == 0) return;

    final paintDot = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintLowConf = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Scale coordinates accurately from camera frame space to preview widget space
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    Offset landmarkToOffset(PoseLandmark lm) {
      double x = lm.x * scaleX;
      double y = lm.y * scaleY;
      // Front camera preview in Flutter is mirrored horizontally
      if (isFrontCamera) {
        x = size.width - x;
      }
      return Offset(x, y);
    }

    void drawBone(PoseLandmarkType t1, PoseLandmarkType t2) {
      final lm1 = pose!.landmarks[t1];
      final lm2 = pose!.landmarks[t2];
      if (lm1 != null && lm2 != null && lm1.likelihood > 0.18 && lm2.likelihood > 0.18) {
        canvas.drawLine(landmarkToOffset(lm1), landmarkToOffset(lm2), paintLine);
      }
    }

    // Connect skeleton limbs
    // Upper Body
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawBone(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawBone(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    // Torso & Hips
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    // Lower Body
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawBone(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawBone(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawBone(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    // Draw Landmark Dots
    for (final lm in pose!.landmarks.values) {
      if (lm.likelihood > 0.18) {
        final pos = landmarkToOffset(lm);
        canvas.drawCircle(pos, 5.0, lm.likelihood > 0.40 ? paintDot : paintLowConf);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PoseSkeletonPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}
