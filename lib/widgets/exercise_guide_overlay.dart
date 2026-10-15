import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';

class ExerciseGuideOverlay extends StatefulWidget {
  final Exercise exercise;
  final String activeCue;
  final int formScore;

  const ExerciseGuideOverlay({
    super.key,
    required this.exercise,
    required this.activeCue,
    required this.formScore,
  });

  @override
  State<ExerciseGuideOverlay> createState() => _ExerciseGuideOverlayState();
}

class _ExerciseGuideOverlayState extends State<ExerciseGuideOverlay> {
  bool expanded = false;

  bool get isFormFault => widget.formScore > 0 && widget.formScore < 75;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFormFault
            ? AppColors.error.withValues(alpha: 0.90)
            : AppColors.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFormFault ? AppColors.error : AppColors.primary,
          width: isFormFault ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFormFault ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          InkWell(
            onTap: () => setState(() => expanded = !expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isFormFault ? Colors.white : AppColors.primary)
                          .withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFormFault ? Icons.warning_amber_rounded : widget.exercise.icon,
                      color: isFormFault ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFormFault ? '⚠️ POSTURE CORRECTION' : widget.exercise.name,
                          style: TextStyle(
                            color: isFormFault ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          isFormFault
                              ? 'Adjust position: ${widget.activeCue}'
                              : 'Tap for anatomical technique guide',
                          style: TextStyle(
                            color: isFormFault
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isFormFault ? Colors.white : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Technique & Form Correction Panel
          if (expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '✅ Correct Form Checklist:',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...widget.exercise.correctFormGuide.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppColors.primary, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '❌ Avoid Common Errors:',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...widget.exercise.commonErrors.map(
                    (err) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel_outlined,
                              color: AppColors.error, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              err,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.exercise.targetMuscles
                        .map(
                          (m) => Chip(
                            label: Text(
                              m,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
