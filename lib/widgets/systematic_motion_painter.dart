import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SystematicMotionPainter extends CustomPainter {
  final String exerciseId;
  final double progress; // 0.0 to 1.0 (phase animation trajectory)
  final int currentStep; // 0: Setup, 1: Action, 2: Peak, 3: Return

  SystematicMotionPainter({
    required this.exerciseId,
    required this.progress,
    required this.currentStep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.height / 230.0;

    // Grid background
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Floor line
    final floorPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(20, size.height - 20),
      Offset(size.width - 20, size.height - 20),
      floorPaint,
    );

    // Floor Ambient Occlusion Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 98 * scale),
        width: 85 * scale,
        height: 14 * scale,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Compute kinematic pose based on exact exercise ID and currentStep
    final poseData = _calculateKinematicPose(exerciseId.toLowerCase(), progress, center, scale, currentStep);

    // Muscle Glows
    _drawMuscleGlow(canvas, poseData.musclePoints, scale);

    // 3D Volumetric Animated Human Athlete
    _drawVolumetricHumanAthlete(canvas, poseData, scale, progress, center);


    // Motion Vector Arrow
    if (poseData.motionArrowStart != null && poseData.motionArrowEnd != null) {
      _drawMotionArrow(
        canvas,
        poseData.motionArrowStart!,
        poseData.motionArrowEnd!,
        scale,
      );
    }

    // Angle Badge Tag
    if (poseData.angleTagPoint != null && poseData.angleText != null) {
      _drawAngleBadge(
        canvas,
        poseData.angleTagPoint!,
        poseData.angleText!,
        scale,
      );
    }
  }

  void _drawMuscleGlow(Canvas canvas, List<Offset> points, double scale) {
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    for (final pt in points) {
      canvas.drawCircle(pt, 22 * scale, glowPaint);
    }
  }

  void _drawMotionArrow(Canvas canvas, Offset start, Offset end, double scale) {
    final paint = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 2.5 * scale
      ..style = PaintingStyle.stroke;

    final dashWidth = 5.0 * scale;
    final dashSpace = 3.0 * scale;
    final distance = (end - start).distance;
    if (distance < 1) return;
    final dx = (end.dx - start.dx) / distance;
    final dy = (end.dy - start.dy) / distance;

    double currentDist = 0;
    while (currentDist < distance) {
      final x1 = start.dx + dx * currentDist;
      final y1 = start.dy + dy * currentDist;
      final x2 = start.dx + dx * math.min(currentDist + dashWidth, distance);
      final y2 = start.dy + dy * math.min(currentDist + dashWidth, distance);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      currentDist += dashWidth + dashSpace;
    }

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowSize = 8.0 * scale;
    final p1 = Offset(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    final p2 = Offset(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    final arrowPaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }

  void _drawAngleBadge(Canvas canvas, Offset point, String text, double scale) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: AppColors.background,
        fontSize: 10 * scale,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: point,
        width: textPainter.width + 12 * scale,
        height: textPainter.height + 6 * scale,
      ),
      Radius.circular(6 * scale),
    );

    canvas.drawRRect(bgRect, Paint()..color = AppColors.primary);
    textPainter.paint(
      canvas,
      Offset(point.dx - textPainter.width / 2, point.dy - textPainter.height / 2),
    );
  }

  void _drawVolumetricHumanAthlete(
    Canvas canvas,
    _PoseData poseData,
    double scale,
    double progress,
    Offset center,
  ) {
    final joints = poseData.joints;

    // Premium Athletic Palette
    const skinLight = Color(0xFFF6C8A4);
    const skinShadow = Color(0xFFC78F65);
    const skinDark = Color(0xFFA66E45); // Background limbs

    const suitPrimary = Color(0xFF1E293B); // Titanium gym fabric
    const suitShadow = Color(0xFF0F172A);
    const suitHighlight = Color(0xFF10B981); // Emerald athletic trim
    const suitCyan = Color(0xFF06B6D4);

    const shortsColor = Color(0xFF141F30);

    const shoeMidsole = Color(0xFFF8FAFC);
    const shoeUpper = Color(0xFF06B6D4);
    const shoeDark = Color(0xFF0F172A);

    const hairColor = Color(0xFF1E1713);
    const headbandColor = Color(0xFF10B981);

    void drawLimbSegment({
      required Offset p1,
      required Offset p2,
      required double w1,
      required double w2,
      required Color color1,
      required Color color2,
      double bulge = 0.0,
      bool drawJointCap1 = true,
      bool drawJointCap2 = true,
      Color? seamColor,
      Color? compressionColor,
    }) {
      final dist = (p2 - p1).distance;
      if (dist < 1.0) return;
      final dx = (p2.dx - p1.dx) / dist;
      final dy = (p2.dy - p1.dy) / dist;
      final nx = -dy;
      final ny = dx;

      final p1L = Offset(p1.dx - nx * w1 * 0.5, p1.dy - ny * w1 * 0.5);
      final p1R = Offset(p1.dx + nx * w1 * 0.5, p1.dy + ny * w1 * 0.5);
      final p2L = Offset(p2.dx - nx * w2 * 0.5, p2.dy - ny * w2 * 0.5);
      final p2R = Offset(p2.dx + nx * w2 * 0.5, p2.dy + ny * w2 * 0.5);

      final mid = Offset((p1.dx + p2.dx) * 0.5, (p1.dy + p2.dy) * 0.5);
      final midW = (w1 + w2) * 0.5 + bulge;
      final midL = Offset(mid.dx - nx * midW * 0.5, mid.dy - ny * midW * 0.5);
      final midR = Offset(mid.dx + nx * midW * 0.5, mid.dy + ny * midW * 0.5);

      final path = Path()
        ..moveTo(p1L.dx, p1L.dy)
        ..quadraticBezierTo(midL.dx, midL.dy, p2L.dx, p2L.dy)
        ..lineTo(p2R.dx, p2R.dy)
        ..quadraticBezierTo(midR.dx, midR.dy, p1R.dx, p1R.dy)
        ..close();

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment(nx, ny),
          end: Alignment(-nx, -ny),
          colors: [color1, color2],
        ).createShader(Rect.fromPoints(p1L, p2R));

      canvas.drawPath(path, paint);

      if (seamColor != null) {
        final seamPaint = Paint()
          ..color = seamColor.withValues(alpha: 0.8)
          ..strokeWidth = 1.6 * scale
          ..style = PaintingStyle.stroke;
        final seamPath = Path()
          ..moveTo(p1.dx, p1.dy)
          ..quadraticBezierTo(mid.dx, mid.dy, p2.dx, p2.dy);
        canvas.drawPath(seamPath, seamPaint);
      }

      if (compressionColor != null) {
        final compPaint = Paint()
          ..color = compressionColor
          ..strokeWidth = 3.0 * scale
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(mid.dx - nx * midW * 0.45, mid.dy - ny * midW * 0.45),
          Offset(mid.dx + nx * midW * 0.45, mid.dy + ny * midW * 0.45),
          compPaint,
        );
      }

      if (drawJointCap1) {
        canvas.drawCircle(p1, w1 * 0.48, Paint()..color = color1);
      }
      if (drawJointCap2) {
        canvas.drawCircle(p2, w2 * 0.48, Paint()..color = color2);
      }
    }

    void drawSneaker(Offset ankle, Offset? toe, {bool isFar = false}) {
      final t = toe ?? Offset(ankle.dx + 15 * scale, ankle.dy + 3 * scale);
      final dirX = t.dx >= ankle.dx ? 1.0 : -1.0;

      final heel = Offset(ankle.dx - dirX * 6 * scale, ankle.dy + 5 * scale);
      final ball = Offset(ankle.dx + dirX * 12 * scale, ankle.dy + 5 * scale);
      final tip = Offset(ankle.dx + dirX * 18 * scale, ankle.dy + 3 * scale);

      final upperPath = Path()
        ..moveTo(heel.dx, heel.dy)
        ..lineTo(ankle.dx, ankle.dy - 3 * scale)
        ..quadraticBezierTo(ankle.dx + dirX * 7 * scale, ankle.dy + 1 * scale, ball.dx, ball.dy - 2 * scale)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(ball.dx, ball.dy)
        ..close();

      canvas.drawPath(
        upperPath,
        Paint()..color = isFar ? suitShadow : shoeUpper,
      );

      final solePath = Path()
        ..moveTo(heel.dx - dirX * 2 * scale, heel.dy + 3 * scale)
        ..lineTo(tip.dx + dirX * 1 * scale, tip.dy + 3 * scale)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(heel.dx, heel.dy)
        ..close();

      canvas.drawPath(
        solePath,
        Paint()..color = isFar ? const Color(0xFF94A3B8) : shoeMidsole,
      );

      final treadPaint = Paint()
        ..color = shoeDark
        ..strokeWidth = 2.0 * scale
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(heel.dx - dirX * 2 * scale, heel.dy + 3.5 * scale),
        Offset(tip.dx + dirX * 1 * scale, tip.dy + 3.5 * scale),
        treadPaint,
      );
    }

    void drawHead(Offset headPos, Offset neckPos) {
      final gazeDirX = headPos.dx >= neckPos.dx ? 1.0 : -1.0;
      final headRadius = 14 * scale;

      final facePaint = Paint()
        ..shader = RadialGradient(
          colors: [skinLight, skinShadow],
          center: const Alignment(-0.2, -0.3),
        ).createShader(Rect.fromCircle(center: headPos, radius: headRadius));

      canvas.drawCircle(headPos, headRadius, facePaint);

      final hairPath = Path()
        ..moveTo(headPos.dx - 12 * scale, headPos.dy - 2 * scale)
        ..quadraticBezierTo(headPos.dx - 14 * scale, headPos.dy - 14 * scale, headPos.dx, headPos.dy - 15 * scale)
        ..quadraticBezierTo(headPos.dx + 12 * scale, headPos.dy - 14 * scale, headPos.dx + 12 * scale * gazeDirX, headPos.dy - 5 * scale)
        ..lineTo(headPos.dx + 6 * scale * gazeDirX, headPos.dy - 7 * scale)
        ..quadraticBezierTo(headPos.dx, headPos.dy - 9 * scale, headPos.dx - 10 * scale, headPos.dy - 4 * scale)
        ..close();
      canvas.drawPath(hairPath, Paint()..color = hairColor);

      final bandPaint = Paint()
        ..color = headbandColor
        ..strokeWidth = 3.2 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(headPos.dx - 11 * scale, headPos.dy - 5 * scale),
        Offset(headPos.dx + 11 * scale, headPos.dy - 5 * scale),
        bandPaint,
      );

      final browPaint = Paint()
        ..color = hairColor
        ..strokeWidth = 1.8 * scale
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(headPos.dx + 3 * scale * gazeDirX, headPos.dy - 2 * scale),
        Offset(headPos.dx + 8 * scale * gazeDirX, headPos.dy - 2 * scale),
        browPaint,
      );
    }

    final head = joints['head'];
    final shoulder = joints['shoulder'];
    final elbow = joints['elbow'];
    final wrist = joints['wrist'];
    final hip = joints['hip'];
    final knee = joints['knee'];
    final ankle = joints['ankle'];

    // Check if bilateral
    final leftShoulder = joints['leftShoulder'];
    final rightShoulder = joints['rightShoulder'];
    final isBilateral = leftShoulder != null && rightShoulder != null;

    if (isBilateral) {
      final leftElbow = joints['leftElbow'];
      final rightElbow = joints['rightElbow'];
      final leftWrist = joints['leftWrist'];
      final rightWrist = joints['rightWrist'];
      final leftHip = joints['leftHip'] ?? Offset(center.dx - 18 * scale, center.dy + 20 * scale);
      final rightHip = joints['rightHip'] ?? Offset(center.dx + 18 * scale, center.dy + 20 * scale);
      final leftKnee = joints['leftKnee'];
      final rightKnee = joints['rightKnee'];
      final leftAnkle = joints['leftAnkle'];
      final rightAnkle = joints['rightAnkle'];

      // Draw Legs
      if (leftKnee != null && leftAnkle != null) {
        drawLimbSegment(p1: leftHip, p2: leftKnee, w1: 18 * scale, w2: 13 * scale, color1: skinLight, color2: skinShadow, bulge: 3 * scale, seamColor: suitCyan);
        drawLimbSegment(p1: leftKnee, p2: leftAnkle, w1: 13 * scale, w2: 9 * scale, color1: skinLight, color2: skinShadow, bulge: 2.5 * scale);
        drawSneaker(leftAnkle, null);
      }
      if (rightKnee != null && rightAnkle != null) {
        drawLimbSegment(p1: rightHip, p2: rightKnee, w1: 18 * scale, w2: 13 * scale, color1: skinLight, color2: skinShadow, bulge: 3 * scale, seamColor: suitCyan);
        drawLimbSegment(p1: rightKnee, p2: rightAnkle, w1: 13 * scale, w2: 9 * scale, color1: skinLight, color2: skinShadow, bulge: 2.5 * scale);
        drawSneaker(rightAnkle, null);
      }

      // Torso & Shorts
      final midShoulder = Offset((leftShoulder.dx + rightShoulder.dx) * 0.5, (leftShoulder.dy + rightShoulder.dy) * 0.5);
      final midHip = Offset((leftHip.dx + rightHip.dx) * 0.5, (leftHip.dy + rightHip.dy) * 0.5);

      final torsoPath = Path()
        ..moveTo(leftShoulder.dx, leftShoulder.dy)
        ..lineTo(rightShoulder.dx, rightShoulder.dy)
        ..lineTo(rightHip.dx + 5 * scale, rightHip.dy)
        ..lineTo(leftHip.dx - 5 * scale, leftHip.dy)
        ..close();
      canvas.drawPath(torsoPath, Paint()..shader = LinearGradient(colors: [suitPrimary, suitShadow]).createShader(Rect.fromPoints(leftShoulder, rightHip)));

      // Shorts
      final shortsPath = Path()
        ..moveTo(leftHip.dx - 7 * scale, leftHip.dy - 5 * scale)
        ..lineTo(rightHip.dx + 7 * scale, rightHip.dy - 5 * scale)
        ..lineTo(rightHip.dx + 8 * scale, rightHip.dy + 20 * scale)
        ..lineTo(midHip.dx, rightHip.dy + 12 * scale)
        ..lineTo(leftHip.dx - 8 * scale, leftHip.dy + 20 * scale)
        ..close();
      canvas.drawPath(shortsPath, Paint()..color = shortsColor);

      // Arms
      if (leftElbow != null && leftWrist != null) {
        drawLimbSegment(p1: leftShoulder, p2: leftElbow, w1: 15 * scale, w2: 11 * scale, color1: skinLight, color2: skinShadow, bulge: 2 * scale);
        drawLimbSegment(p1: leftElbow, p2: leftWrist, w1: 12 * scale, w2: 8.5 * scale, color1: skinLight, color2: skinShadow, bulge: 1.5 * scale, compressionColor: suitHighlight);
      }
      if (rightElbow != null && rightWrist != null) {
        drawLimbSegment(p1: rightShoulder, p2: rightElbow, w1: 15 * scale, w2: 11 * scale, color1: skinLight, color2: skinShadow, bulge: 2 * scale);
        drawLimbSegment(p1: rightElbow, p2: rightWrist, w1: 12 * scale, w2: 8.5 * scale, color1: skinLight, color2: skinShadow, bulge: 1.5 * scale, compressionColor: suitHighlight);
      }

      if (head != null) {
        drawHead(head, midShoulder);
      }
    } else if (shoulder != null && hip != null) {
      // Side Profile Volumetric Rendering

      // Far Leg / Rear Leg (if present, draw first in background shadow)
      final rearKnee = joints['rearKnee'];
      final rearAnkle = joints['rearAnkle'];
      if (rearKnee != null && rearAnkle != null) {
        final rearHip = Offset(hip.dx - 6 * scale, hip.dy);
        drawLimbSegment(p1: rearHip, p2: rearKnee, w1: 17 * scale, w2: 12 * scale, color1: skinDark, color2: suitShadow, bulge: 2.5 * scale);
        drawLimbSegment(p1: rearKnee, p2: rearAnkle, w1: 12 * scale, w2: 8.5 * scale, color1: skinDark, color2: suitShadow, bulge: 2.0 * scale);
        drawSneaker(rearAnkle, null, isFar: true);
      }

      // Far Arm (drawn slightly behind torso)
      if (elbow != null && wrist != null) {
        final farShoulder = Offset(shoulder.dx - 5 * scale, shoulder.dy);
        final farElbow = Offset(elbow.dx - 4 * scale, elbow.dy - 2 * scale);
        final farWrist = Offset(wrist.dx - 4 * scale, wrist.dy - 2 * scale);
        drawLimbSegment(p1: farShoulder, p2: farElbow, w1: 14 * scale, w2: 10 * scale, color1: skinDark, color2: suitShadow, bulge: 1.5 * scale);
        drawLimbSegment(p1: farElbow, p2: farWrist, w1: 11 * scale, w2: 8 * scale, color1: skinDark, color2: suitShadow, bulge: 1.2 * scale);
      }

      // Torso & Pelvis
      final torsoDir = (hip - shoulder);
      final torsoDist = torsoDir.distance;
      if (torsoDist > 1.0) {
        final tdx = torsoDir.dx / torsoDist;
        final tdy = torsoDir.dy / torsoDist;
        final tnx = -tdy;
        final tny = tdx;

        final chestW = 28 * scale;
        final waistW = 20 * scale;
        final hipW = 24 * scale;

        final sL = Offset(shoulder.dx - tnx * chestW * 0.5, shoulder.dy - tny * chestW * 0.5);
        final sR = Offset(shoulder.dx + tnx * chestW * 0.5, shoulder.dy + tny * chestW * 0.5);
        final midTorso = Offset((shoulder.dx + hip.dx) * 0.5, (shoulder.dy + hip.dy) * 0.5);
        final wL = Offset(midTorso.dx - tnx * waistW * 0.5, midTorso.dy - tny * waistW * 0.5);
        final wR = Offset(midTorso.dx + tnx * waistW * 0.5, midTorso.dy + tny * waistW * 0.5);
        final hL = Offset(hip.dx - tnx * hipW * 0.5, hip.dy - tny * hipW * 0.5);
        final hR = Offset(hip.dx + tnx * hipW * 0.5, hip.dy + tny * hipW * 0.5);

        final torsoPath = Path()
          ..moveTo(sL.dx, sL.dy)
          ..quadraticBezierTo(wL.dx, wL.dy, hL.dx, hL.dy)
          ..lineTo(hR.dx, hR.dy)
          ..quadraticBezierTo(wR.dx, wR.dy, sR.dx, sR.dy)
          ..close();

        canvas.drawPath(
          torsoPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment(tnx, tny),
              end: Alignment(-tnx, -tny),
              colors: [suitPrimary, suitShadow],
            ).createShader(Rect.fromPoints(sL, hR)),
        );

        // Athletic Seam Trim
        final trimPaint = Paint()
          ..color = suitHighlight
          ..strokeWidth = 2.0 * scale
          ..style = PaintingStyle.stroke;
        canvas.drawLine(sL, wL, trimPaint);

        // Athletic Gym Shorts
        final shortsEnd = Offset(hip.dx + tdx * 16 * scale, hip.dy + tdy * 16 * scale);
        final shL = Offset(shortsEnd.dx - tnx * (hipW + 2) * 0.5, shortsEnd.dy - tny * (hipW + 2) * 0.5);
        final shR = Offset(shortsEnd.dx + tnx * (hipW + 2) * 0.5, shortsEnd.dy + tny * (hipW + 2) * 0.5);

        final shortsPath = Path()
          ..moveTo(hL.dx, hL.dy)
          ..lineTo(shL.dx, shL.dy)
          ..lineTo(shR.dx, shR.dy)
          ..lineTo(hR.dx, hR.dy)
          ..close();
        canvas.drawPath(shortsPath, Paint()..color = shortsColor);
      }

      // Head
      if (head != null) {
        drawHead(head, shoulder);
      }

      // Near Leg (Foreground)
      if (knee != null && ankle != null) {
        drawLimbSegment(p1: hip, p2: knee, w1: 20 * scale, w2: 14 * scale, color1: skinLight, color2: skinShadow, bulge: 3.5 * scale, seamColor: suitCyan);
        // Knee Compression Brace
        canvas.drawCircle(knee, 7.5 * scale, Paint()..color = suitShadow);
        canvas.drawCircle(knee, 5 * scale, Paint()..color = suitHighlight);
        drawLimbSegment(p1: knee, p2: ankle, w1: 14 * scale, w2: 9.5 * scale, color1: skinLight, color2: skinShadow, bulge: 3.0 * scale);
        drawSneaker(ankle, joints['toe']);
      }

      // Near Arm (Foreground)
      if (elbow != null && wrist != null) {
        // Deltoid Cap
        canvas.drawCircle(shoulder, 8 * scale, Paint()..color = suitHighlight);
        drawLimbSegment(p1: shoulder, p2: elbow, w1: 16 * scale, w2: 12 * scale, color1: skinLight, color2: skinShadow, bulge: 2.5 * scale);
        drawLimbSegment(p1: elbow, p2: wrist, w1: 12 * scale, w2: 8.5 * scale, color1: skinLight, color2: skinShadow, bulge: 2.0 * scale, compressionColor: suitCyan);
        // Athletic Wristband & Glove
        canvas.drawCircle(wrist, 6 * scale, Paint()..color = suitHighlight);
        final handDir = (wrist - elbow);
        final hDist = handDir.distance;
        if (hDist > 0.5) {
          final handPos = Offset(wrist.dx + (handDir.dx / hDist) * 7 * scale, wrist.dy + (handDir.dy / hDist) * 7 * scale);
          canvas.drawCircle(handPos, 6.5 * scale, Paint()..color = suitShadow);
        }
      }
    }
  }

  _PoseData _calculateKinematicPose(
    String id,
    double t,
    Offset center,
    double scale,
    int step,
  ) {
    final joints = <String, Offset>{};
    final connections = <_Connection>[];
    final musclePoints = <Offset>[];
    Offset? arrowStart;
    Offset? arrowEnd;
    Offset? angleTag;
    String? angleText;

    // Realistic kinematic phase positioning matching step:
    // Step 0: Setup stance (steady with subtle breathing cycle)
    // Step 1: Eccentric lowering / start motion (smooth progress down/out)
    // Step 2: Peak contraction / isometric hold (held at apex with micro-tension)
    // Step 3+: Concentric return / lockout (smooth return back to start)
    // If step is out of bounds or negative, fallback to full sine wave
    final double cycle;
    switch (step) {
      case 0:
        cycle = math.sin(t * math.pi) * 0.05;
        break;
      case 1:
        cycle = (t.clamp(0.0, 1.0)) * 0.95;
        break;
      case 2:
        cycle = 0.92 + math.sin(t * math.pi) * 0.08;
        break;
      case 3:
        cycle = (1.0 - t).clamp(0.0, 1.0) * 0.95;
        break;
      default:
        cycle = math.sin(t * math.pi);
    }

    if (id.contains('squat')) {
      // 1. SQUATS & SUMO SQUATS
      final hipDrop = cycle * 45 * scale;
      final kneeBend = cycle * 35 * scale;

      joints['head'] = Offset(center.dx, center.dy - 70 * scale + hipDrop * 0.8);
      joints['shoulder'] = Offset(center.dx, center.dy - 40 * scale + hipDrop * 0.9);
      joints['hip'] = Offset(center.dx - 10 * scale, center.dy + 10 * scale + hipDrop);
      joints['knee'] = Offset(center.dx + 25 * scale + kneeBend, center.dy + 55 * scale);
      joints['ankle'] = Offset(center.dx + 10 * scale, center.dy + 95 * scale);
      joints['elbow'] = Offset(center.dx + 30 * scale, center.dy - 35 * scale + hipDrop * 0.8);
      joints['wrist'] = Offset(center.dx + 55 * scale, center.dy - 35 * scale + hipDrop * 0.8);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.addAll([joints['knee']!, joints['hip']!]);
      arrowStart = Offset(center.dx, center.dy - 40 * scale);
      arrowEnd = Offset(center.dx, center.dy);
      angleTag = joints['knee']!;
      final currentAngle = (170 - cycle * 80).round();
      angleText = '$currentAngle° Target: 90°';
    } else if (id.contains('wall_sit')) {
      // 2. WALL SIT
      joints['head'] = Offset(center.dx - 40 * scale, center.dy - 45 * scale);
      joints['shoulder'] = Offset(center.dx - 40 * scale, center.dy - 15 * scale);
      joints['hip'] = Offset(center.dx - 40 * scale, center.dy + 35 * scale);
      joints['knee'] = Offset(center.dx + 10 * scale, center.dy + 35 * scale);
      joints['ankle'] = Offset(center.dx + 10 * scale, center.dy + 95 * scale);
      joints['elbow'] = Offset(center.dx - 10 * scale, center.dy + 10 * scale);
      joints['wrist'] = Offset(center.dx + 5 * scale, center.dy + 25 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.addAll([joints['knee']!, joints['hip']!]);
      angleTag = joints['knee']!;
      angleText = 'Isometric 90° Hold';
    } else if (id.contains('lunge')) {
      // 3. LUNGES & SIDE LUNGES
      final dip = cycle * 35 * scale;
      joints['head'] = Offset(center.dx, center.dy - 65 * scale + dip * 0.8);
      joints['shoulder'] = Offset(center.dx, center.dy - 35 * scale + dip * 0.8);
      joints['hip'] = Offset(center.dx, center.dy + 15 * scale + dip);

      // Lead forward leg
      joints['knee'] = Offset(center.dx + 35 * scale, center.dy + 45 * scale + dip * 0.5);
      joints['ankle'] = Offset(center.dx + 35 * scale, center.dy + 95 * scale);

      // Rear trailing leg
      joints['knee_rear'] = Offset(center.dx - 25 * scale, center.dy + 65 * scale + dip * 0.8);
      joints['ankle_rear'] = Offset(center.dx - 45 * scale, center.dy + 95 * scale);

      joints['elbow'] = Offset(center.dx - 15 * scale, center.dy - 10 * scale + dip * 0.8);
      joints['wrist'] = Offset(center.dx - 15 * scale, center.dy + 15 * scale + dip * 0.8);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('hip', 'knee_rear'),
        _Connection('knee_rear', 'ankle_rear'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.addAll([joints['knee']!, joints['knee_rear']!]);
      arrowStart = Offset(center.dx + 35 * scale, center.dy + 25 * scale);
      arrowEnd = Offset(center.dx + 35 * scale, center.dy + 55 * scale);
      angleTag = joints['knee']!;
      final currentAngle = (160 - cycle * 70).round();
      angleText = '$currentAngle° 90° Front Knee';
    } else if (id.contains('calf')) {
      // 4. CALF RAISES
      final heelLift = cycle * 25 * scale;
      joints['head'] = Offset(center.dx, center.dy - 70 * scale - heelLift);
      joints['shoulder'] = Offset(center.dx, center.dy - 40 * scale - heelLift);
      joints['hip'] = Offset(center.dx, center.dy + 15 * scale - heelLift);
      joints['knee'] = Offset(center.dx, center.dy + 55 * scale - heelLift);
      joints['ankle'] = Offset(center.dx, center.dy + 95 * scale - heelLift);
      joints['toe'] = Offset(center.dx + 12 * scale, center.dy + 95 * scale);

      joints['elbow'] = Offset(center.dx + 15 * scale, center.dy - 15 * scale - heelLift);
      joints['wrist'] = Offset(center.dx + 15 * scale, center.dy + 15 * scale - heelLift);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('ankle', 'toe'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.add(joints['ankle']!);
      arrowStart = Offset(center.dx, center.dy + 95 * scale);
      arrowEnd = Offset(center.dx, center.dy + 70 * scale);
      angleTag = joints['ankle']!;
      angleText = 'Peak Plantarflexion';
    } else if (id.contains('bridge')) {
      // 5. GLUTE BRIDGES
      final hipLift = cycle * 35 * scale;
      joints['head'] = Offset(center.dx - 60 * scale, center.dy + 55 * scale);
      joints['shoulder'] = Offset(center.dx - 45 * scale, center.dy + 55 * scale);
      joints['hip'] = Offset(center.dx - 5 * scale, center.dy + 55 * scale - hipLift);
      joints['knee'] = Offset(center.dx + 35 * scale, center.dy + 25 * scale);
      joints['ankle'] = Offset(center.dx + 45 * scale, center.dy + 75 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
      ]);

      musclePoints.add(joints['hip']!);
      arrowStart = Offset(center.dx - 5 * scale, center.dy + 55 * scale);
      arrowEnd = Offset(center.dx - 5 * scale, center.dy + 20 * scale);
      angleTag = joints['hip']!;
      angleText = '180° Bridge Lockout';
    } else if (id.contains('pushup') || id.contains('dip')) {
      // 6. PUSH-UPS & TRICEP DIPS
      final dip = cycle * 22 * scale;
      joints['head'] = Offset(center.dx - 65 * scale, center.dy + dip);
      joints['shoulder'] = Offset(center.dx - 45 * scale, center.dy + dip);
      joints['elbow'] = Offset(center.dx - 45 * scale, center.dy + 25 * scale);
      joints['wrist'] = Offset(center.dx - 45 * scale, center.dy + 50 * scale);
      joints['hip'] = Offset(center.dx + 5 * scale, center.dy + dip * 0.9);
      joints['knee'] = Offset(center.dx + 45 * scale, center.dy + dip * 0.8);
      joints['ankle'] = Offset(center.dx + 75 * scale, center.dy + dip * 0.7);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
      ]);

      musclePoints.addAll([joints['shoulder']!, joints['elbow']!]);
      arrowStart = Offset(center.dx - 45 * scale, center.dy + 20 * scale);
      arrowEnd = Offset(center.dx - 45 * scale, center.dy - 10 * scale);
      angleTag = joints['elbow']!;
      final currentAngle = (165 - cycle * 75).round();
      angleText = '$currentAngle° Elbow Bend';
    } else if (id.contains('curl')) {
      // 7. BICEP CURLS
      final forearmAngle = -math.pi / 2 + cycle * (math.pi * 0.7);
      joints['head'] = Offset(center.dx, center.dy - 70 * scale);
      joints['shoulder'] = Offset(center.dx, center.dy - 40 * scale);
      joints['hip'] = Offset(center.dx, center.dy + 20 * scale);
      joints['knee'] = Offset(center.dx, center.dy + 60 * scale);
      joints['ankle'] = Offset(center.dx, center.dy + 95 * scale);

      joints['elbow'] = Offset(center.dx + 15 * scale, center.dy - 10 * scale);
      final wristX = joints['elbow']!.dx + 35 * scale * math.cos(forearmAngle);
      final wristY = joints['elbow']!.dy + 35 * scale * math.sin(forearmAngle);
      joints['wrist'] = Offset(wristX, wristY);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.add(joints['elbow']!);
      arrowStart = Offset(joints['elbow']!.dx + 25 * scale, joints['elbow']!.dy + 20 * scale);
      arrowEnd = Offset(joints['elbow']!.dx + 25 * scale, joints['elbow']!.dy - 20 * scale);
      angleTag = joints['elbow']!;
      final currentAngle = (160 - cycle * 115).round();
      angleText = '$currentAngle° Target: 45°';
    } else if (id.contains('press')) {
      // 8. SHOULDER PRESS
      final armRaise = cycle * 45 * scale;
      joints['head'] = Offset(center.dx, center.dy - 65 * scale);
      joints['shoulder'] = Offset(center.dx, center.dy - 35 * scale);
      joints['hip'] = Offset(center.dx, center.dy + 20 * scale);
      joints['knee'] = Offset(center.dx, center.dy + 60 * scale);
      joints['ankle'] = Offset(center.dx, center.dy + 95 * scale);

      joints['elbow'] = Offset(center.dx + 25 * scale, center.dy - 20 * scale - armRaise * 0.5);
      joints['wrist'] = Offset(center.dx + 25 * scale, center.dy - 45 * scale - armRaise);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.add(joints['shoulder']!);
      arrowStart = Offset(center.dx + 25 * scale, center.dy - 20 * scale);
      arrowEnd = Offset(center.dx + 25 * scale, center.dy - 65 * scale);
      angleTag = joints['elbow']!;
      final currentAngle = (80 + cycle * 95).round();
      angleText = '$currentAngle° Overhead';
    } else if (id.contains('raise') || id.contains('arm_circle')) {
      // 9. LATERAL RAISES & ARM CIRCLES
      final lateralAngle = math.pi / 2 - cycle * (math.pi / 2);
      joints['head'] = Offset(center.dx, center.dy - 65 * scale);
      joints['shoulder'] = Offset(center.dx, center.dy - 35 * scale);
      joints['hip'] = Offset(center.dx, center.dy + 20 * scale);
      joints['knee'] = Offset(center.dx, center.dy + 60 * scale);
      joints['ankle'] = Offset(center.dx, center.dy + 95 * scale);

      // Left and right arms moving out laterally
      final armLen = 45 * scale;
      joints['elbow_l'] = Offset(center.dx - armLen * 0.6 * math.sin(lateralAngle), center.dy - 35 * scale + armLen * 0.6 * math.cos(lateralAngle));
      joints['wrist_l'] = Offset(center.dx - armLen * math.sin(lateralAngle), center.dy - 35 * scale + armLen * math.cos(lateralAngle));
      joints['elbow_r'] = Offset(center.dx + armLen * 0.6 * math.sin(lateralAngle), center.dy - 35 * scale + armLen * 0.6 * math.cos(lateralAngle));
      joints['wrist_r'] = Offset(center.dx + armLen * math.sin(lateralAngle), center.dy - 35 * scale + armLen * math.cos(lateralAngle));

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow_l'),
        _Connection('elbow_l', 'wrist_l'),
        _Connection('shoulder', 'elbow_r'),
        _Connection('elbow_r', 'wrist_r'),
      ]);

      musclePoints.add(joints['shoulder']!);
      arrowStart = Offset(center.dx + 25 * scale, center.dy + 10 * scale);
      arrowEnd = Offset(center.dx + 45 * scale, center.dy - 35 * scale);
      angleTag = joints['shoulder']!;
      final deg = (15 + cycle * 75).round();
      angleText = '$deg° Lateral Abduction';
    } else if (id.contains('plank')) {
      // 10. PLANK & SIDE PLANK
      joints['head'] = Offset(center.dx - 65 * scale, center.dy + 15 * scale);
      joints['shoulder'] = Offset(center.dx - 45 * scale, center.dy + 15 * scale);
      joints['elbow'] = Offset(center.dx - 45 * scale, center.dy + 45 * scale);
      joints['wrist'] = Offset(center.dx - 30 * scale, center.dy + 45 * scale);
      joints['hip'] = Offset(center.dx + 5 * scale, center.dy + 15 * scale);
      joints['knee'] = Offset(center.dx + 45 * scale, center.dy + 20 * scale);
      joints['ankle'] = Offset(center.dx + 75 * scale, center.dy + 35 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
      ]);

      musclePoints.add(joints['hip']!);
      angleTag = joints['hip']!;
      angleText = 'Core 180° Flat Line';
    } else if (id.contains('crunch')) {
      // 11. CRUNCHES
      final curl = cycle * 25 * scale;
      joints['head'] = Offset(center.dx - 45 * scale + curl * 0.5, center.dy + 45 * scale - curl);
      joints['shoulder'] = Offset(center.dx - 30 * scale, center.dy + 55 * scale - curl * 0.7);
      joints['hip'] = Offset(center.dx + 5 * scale, center.dy + 55 * scale);
      joints['knee'] = Offset(center.dx + 35 * scale, center.dy + 20 * scale);
      joints['ankle'] = Offset(center.dx + 45 * scale, center.dy + 75 * scale);

      joints['elbow'] = Offset(center.dx - 20 * scale, center.dy + 35 * scale - curl);
      joints['wrist'] = Offset(center.dx - 35 * scale, center.dy + 40 * scale - curl);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
      ]);

      musclePoints.add(joints['hip']!);
      arrowStart = Offset(center.dx - 45 * scale, center.dy + 50 * scale);
      arrowEnd = Offset(center.dx - 45 * scale, center.dy + 20 * scale);
      angleTag = joints['shoulder']!;
      angleText = 'Torso 30° Curl';
    } else if (id.contains('leg_raise')) {
      // 12. LEG RAISES
      final legAngle = -cycle * (math.pi * 0.45);
      joints['head'] = Offset(center.dx - 55 * scale, center.dy + 55 * scale);
      joints['shoulder'] = Offset(center.dx - 35 * scale, center.dy + 55 * scale);
      joints['hip'] = Offset(center.dx + 5 * scale, center.dy + 55 * scale);

      final legLen = 65 * scale;
      final ankleX = joints['hip']!.dx + legLen * math.cos(legAngle);
      final ankleY = joints['hip']!.dy + legLen * math.sin(legAngle);
      joints['knee'] = Offset(joints['hip']!.dx + legLen * 0.5 * math.cos(legAngle), joints['hip']!.dy + legLen * 0.5 * math.sin(legAngle));
      joints['ankle'] = Offset(ankleX, ankleY);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
      ]);

      musclePoints.add(joints['hip']!);
      arrowStart = Offset(center.dx + 50 * scale, center.dy + 50 * scale);
      arrowEnd = Offset(center.dx + 25 * scale, center.dy);
      angleTag = joints['hip']!;
      final deg = (cycle * 90).round();
      angleText = '$deg° Leg Elevation';
    } else if (id.contains('climber')) {
      // 13. MOUNTAIN CLIMBERS
      final kneeDrive = cycle * 40 * scale;
      joints['head'] = Offset(center.dx - 60 * scale, center.dy + 15 * scale);
      joints['shoulder'] = Offset(center.dx - 40 * scale, center.dy + 15 * scale);
      joints['elbow'] = Offset(center.dx - 40 * scale, center.dy + 40 * scale);
      joints['wrist'] = Offset(center.dx - 40 * scale, center.dy + 65 * scale);
      joints['hip'] = Offset(center.dx + 10 * scale, center.dy + 15 * scale);

      // Alternating driving knee
      joints['knee'] = Offset(center.dx - 5 * scale + kneeDrive * 0.8, center.dy + 25 * scale);
      joints['ankle'] = Offset(center.dx + 10 * scale + kneeDrive * 0.5, center.dy + 45 * scale);

      // Stable rear leg
      joints['knee_rear'] = Offset(center.dx + 45 * scale, center.dy + 25 * scale);
      joints['ankle_rear'] = Offset(center.dx + 70 * scale, center.dy + 45 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('hip', 'knee_rear'),
        _Connection('knee_rear', 'ankle_rear'),
      ]);

      musclePoints.add(joints['knee']!);
      arrowStart = Offset(center.dx + 35 * scale, center.dy + 25 * scale);
      arrowEnd = Offset(center.dx, center.dy + 25 * scale);
      angleTag = joints['knee']!;
      angleText = 'Chest Knee Drive';
    } else if (id.contains('twist')) {
      // 14. RUSSIAN TWISTS
      final twistX = math.sin(t * math.pi * 2) * 25 * scale;
      joints['head'] = Offset(center.dx - 25 * scale, center.dy - 10 * scale);
      joints['shoulder'] = Offset(center.dx - 15 * scale, center.dy + 10 * scale);
      joints['hip'] = Offset(center.dx, center.dy + 50 * scale);
      joints['knee'] = Offset(center.dx + 35 * scale, center.dy + 25 * scale);
      joints['ankle'] = Offset(center.dx + 55 * scale, center.dy + 45 * scale);

      joints['elbow'] = Offset(center.dx + twistX * 0.7, center.dy + 25 * scale);
      joints['wrist'] = Offset(center.dx + twistX, center.dy + 45 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.add(joints['hip']!);
      arrowStart = Offset(center.dx - 20 * scale, center.dy + 45 * scale);
      arrowEnd = Offset(center.dx + 20 * scale, center.dy + 45 * scale);
      angleTag = joints['hip']!;
      angleText = 'Oblique Rotation';
    } else if (id.contains('jumping_jack')) {
      // 15. JUMPING JACKS
      final armArc = cycle * math.pi * 0.75;
      final legSpread = cycle * 25 * scale;
      joints['head'] = Offset(center.dx, center.dy - 65 * scale);
      joints['shoulder'] = Offset(center.dx, center.dy - 35 * scale);
      joints['hip'] = Offset(center.dx, center.dy + 20 * scale);

      // Legs jump wide
      joints['knee_l'] = Offset(center.dx - 10 * scale - legSpread * 0.5, center.dy + 60 * scale);
      joints['ankle_l'] = Offset(center.dx - 15 * scale - legSpread, center.dy + 95 * scale);
      joints['knee_r'] = Offset(center.dx + 10 * scale + legSpread * 0.5, center.dy + 60 * scale);
      joints['ankle_r'] = Offset(center.dx + 15 * scale + legSpread, center.dy + 95 * scale);

      // Arms sweep overhead
      final armLen = 45 * scale;
      joints['wrist_l'] = Offset(center.dx - armLen * math.sin(armArc), center.dy - 35 * scale - armLen * math.cos(armArc));
      joints['wrist_r'] = Offset(center.dx + armLen * math.sin(armArc), center.dy - 35 * scale - armLen * math.cos(armArc));

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee_l'),
        _Connection('knee_l', 'ankle_l'),
        _Connection('hip', 'knee_r'),
        _Connection('knee_r', 'ankle_r'),
        _Connection('shoulder', 'wrist_l'),
        _Connection('shoulder', 'wrist_r'),
      ]);

      musclePoints.addAll([joints['shoulder']!, joints['hip']!]);
      arrowStart = Offset(center.dx - 30 * scale, center.dy - 10 * scale);
      arrowEnd = Offset(center.dx - 10 * scale, center.dy - 70 * scale);
      angleTag = joints['shoulder']!;
      angleText = 'Overhead Arc';
    } else if (id.contains('knee') || id.contains('kick')) {
      // 16. HIGH KNEES & BUTT KICKS
      final kneeLift = cycle * 45 * scale;
      joints['head'] = Offset(center.dx, center.dy - 65 * scale);
      joints['shoulder'] = Offset(center.dx, center.dy - 35 * scale);
      joints['hip'] = Offset(center.dx, center.dy + 20 * scale);

      // Driving High Knee
      joints['knee'] = Offset(center.dx + 25 * scale, center.dy + 60 * scale - kneeLift);
      joints['ankle'] = Offset(center.dx + 25 * scale, center.dy + 95 * scale - kneeLift * 0.8);

      // Plant leg
      joints['knee_plant'] = Offset(center.dx - 10 * scale, center.dy + 60 * scale);
      joints['ankle_plant'] = Offset(center.dx - 10 * scale, center.dy + 95 * scale);

      // Running arms
      joints['elbow'] = Offset(center.dx - 20 * scale, center.dy - 15 * scale);
      joints['wrist'] = Offset(center.dx - 35 * scale, center.dy - 35 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('hip', 'knee_plant'),
        _Connection('knee_plant', 'ankle_plant'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.add(joints['knee']!);
      arrowStart = Offset(center.dx + 25 * scale, center.dy + 65 * scale);
      arrowEnd = Offset(center.dx + 25 * scale, center.dy + 20 * scale);
      angleTag = joints['knee']!;
      angleText = 'Hip Level 90° Drive';
    } else if (id.contains('burpee')) {
      // 17. BURPEES
      final squatProgress = cycle * 45 * scale;
      joints['head'] = Offset(center.dx, center.dy - 65 * scale + squatProgress);
      joints['shoulder'] = Offset(center.dx, center.dy - 35 * scale + squatProgress);
      joints['hip'] = Offset(center.dx - 10 * scale, center.dy + 15 * scale + squatProgress);
      joints['knee'] = Offset(center.dx + 20 * scale, center.dy + 55 * scale);
      joints['ankle'] = Offset(center.dx + 10 * scale, center.dy + 95 * scale);
      joints['elbow'] = Offset(center.dx + 30 * scale, center.dy - 20 * scale + squatProgress);
      joints['wrist'] = Offset(center.dx + 30 * scale, center.dy + 20 * scale + squatProgress);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.addAll([joints['hip']!, joints['knee']!]);
      angleTag = joints['hip']!;
      angleText = 'Squat-Plank Transition';
    } else if (id.contains('stretch') || id.contains('cobra')) {
      // 18. COBRA STRETCH
      final arch = cycle * 25 * scale;
      joints['head'] = Offset(center.dx - 45 * scale, center.dy + 20 * scale - arch);
      joints['shoulder'] = Offset(center.dx - 30 * scale, center.dy + 35 * scale - arch * 0.8);
      joints['elbow'] = Offset(center.dx - 30 * scale, center.dy + 55 * scale);
      joints['wrist'] = Offset(center.dx - 20 * scale, center.dy + 70 * scale);
      joints['hip'] = Offset(center.dx + 15 * scale, center.dy + 70 * scale);
      joints['knee'] = Offset(center.dx + 45 * scale, center.dy + 70 * scale);
      joints['ankle'] = Offset(center.dx + 75 * scale, center.dy + 70 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
      ]);

      musclePoints.add(joints['shoulder']!);
      arrowStart = Offset(center.dx - 35 * scale, center.dy + 40 * scale);
      arrowEnd = Offset(center.dx - 45 * scale, center.dy + 10 * scale);
      angleTag = joints['shoulder']!;
      angleText = 'Spine Extension';
    } else if (id.contains('child')) {
      // 19. CHILD'S POSE
      joints['head'] = Offset(center.dx - 25 * scale, center.dy + 55 * scale);
      joints['shoulder'] = Offset(center.dx - 10 * scale, center.dy + 45 * scale);
      joints['elbow'] = Offset(center.dx - 35 * scale, center.dy + 65 * scale);
      joints['wrist'] = Offset(center.dx - 60 * scale, center.dy + 70 * scale);
      joints['hip'] = Offset(center.dx + 30 * scale, center.dy + 45 * scale);
      joints['knee'] = Offset(center.dx + 25 * scale, center.dy + 70 * scale);
      joints['ankle'] = Offset(center.dx + 45 * scale, center.dy + 70 * scale);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
      ]);

      musclePoints.add(joints['shoulder']!);
      angleTag = joints['hip']!;
      angleText = 'Resting Spinal Decompression';
    } else {
      // Generic Adaptive Kinematic Pose
      final move = cycle * 25 * scale;
      joints['head'] = Offset(center.dx, center.dy - 65 * scale);
      joints['shoulder'] = Offset(center.dx, center.dy - 35 * scale);
      joints['hip'] = Offset(center.dx, center.dy + 20 * scale);
      joints['knee'] = Offset(center.dx - 10 * scale + move * 0.5, center.dy + 60 * scale);
      joints['ankle'] = Offset(center.dx, center.dy + 95 * scale);
      joints['elbow'] = Offset(center.dx + 25 * scale, center.dy - 10 * scale - move);
      joints['wrist'] = Offset(center.dx + 40 * scale, center.dy - 20 * scale - move * 1.2);

      connections.addAll([
        _Connection('head', 'shoulder'),
        _Connection('shoulder', 'hip'),
        _Connection('hip', 'knee'),
        _Connection('knee', 'ankle'),
        _Connection('shoulder', 'elbow'),
        _Connection('elbow', 'wrist'),
      ]);

      musclePoints.add(joints['shoulder']!);
      arrowStart = Offset(center.dx + 25 * scale, center.dy);
      arrowEnd = Offset(center.dx + 25 * scale, center.dy - 40 * scale);
      angleTag = joints['shoulder']!;
      angleText = 'Form Guide';
    }

    return _PoseData(
      joints: joints,
      connections: connections,
      musclePoints: musclePoints,
      motionArrowStart: arrowStart,
      motionArrowEnd: arrowEnd,
      angleTagPoint: angleTag,
      angleText: angleText,
    );
  }

  @override
  bool shouldRepaint(covariant SystematicMotionPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentStep != currentStep ||
        oldDelegate.exerciseId != exerciseId;
  }
}

class _PoseData {
  final Map<String, Offset> joints;
  final List<_Connection> connections;
  final List<Offset> musclePoints;
  final Offset? motionArrowStart;
  final Offset? motionArrowEnd;
  final Offset? angleTagPoint;
  final String? angleText;

  _PoseData({
    required this.joints,
    required this.connections,
    required this.musclePoints,
    this.motionArrowStart,
    this.motionArrowEnd,
    this.angleTagPoint,
    this.angleText,
  });
}

class _Connection {
  final String item1;
  final String item2;

  _Connection(this.item1, this.item2);
}
