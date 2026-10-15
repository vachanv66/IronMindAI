import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FormTrendChartPainter extends CustomPainter {
  final List<int> scores;
  final double animationValue;

  FormTrendChartPainter({
    required this.scores,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final padLeft = 32.0;
    final padRight = 16.0;
    final padTop = 20.0;
    final padBottom = 26.0;

    final chartWidth = size.width - padLeft - padRight;
    final chartHeight = size.height - padTop - padBottom;

    // Draw horizontal reference grid lines (0%, 50%, 75%, 100%)
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: AppColors.textSecondary.withValues(alpha: 0.7),
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (final pct in [50, 75, 100]) {
      final y = padTop + chartHeight * (1.0 - (pct / 100.0));
      canvas.drawLine(Offset(padLeft, y), Offset(size.width - padRight, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: '$pct%', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y - 6));
    }

    // Compute coordinate points
    final count = scores.length;
    final stepX = count <= 1 ? chartWidth : chartWidth / (count - 1);
    final points = <Offset>[];

    for (int i = 0; i < count; i++) {
      final rawScore = scores[i].clamp(0, 100);
      final x = padLeft + i * stepX;
      final yTarget = padTop + chartHeight * (1.0 - (rawScore / 100.0));
      // Animate up from bottom baseline
      final yBase = padTop + chartHeight;
      final y = yBase - (yBase - yTarget) * animationValue;
      points.add(Offset(x, y));
    }

    // Build curved path
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient Area Fill
    final fillPath = Path.from(linePath);
    fillPath.lineTo(points.last.dx, padTop + chartHeight);
    fillPath.lineTo(points.first.dx, padTop + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, padTop),
        Offset(0, padTop + chartHeight),
        [
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Glowing Line Stroke
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(linePath, glowPaint);

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, strokePaint);

    // Render Data Point Bulbs
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      // Outer shadow ring
      canvas.drawCircle(
        p,
        5.5,
        Paint()..color = AppColors.background,
      );
      // Colored accent dot
      final isLast = i == points.length - 1;
      canvas.drawCircle(
        p,
        isLast ? 4.5 : 3.5,
        Paint()..color = isLast ? AppColors.accent : AppColors.primary,
      );

      // Session number label on bottom
      final labelTp = TextPainter(
        text: TextSpan(
          text: 'S${i + 1}',
          style: TextStyle(
            color: isLast ? AppColors.primary : AppColors.textMuted,
            fontSize: 9,
            fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(canvas, Offset(p.dx - labelTp.width / 2, padTop + chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant FormTrendChartPainter oldDelegate) {
    return oldDelegate.scores != scores || oldDelegate.animationValue != animationValue;
  }
}
