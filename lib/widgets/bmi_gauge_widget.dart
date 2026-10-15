import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';

class BmiGaugeWidget extends StatelessWidget {
  final User user;
  final VoidCallback? onEditRequested;

  const BmiGaugeWidget({
    super.key,
    required this.user,
    this.onEditRequested,
  });

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF38BDF8); // Sky blue
    if (bmi < 25.0) return const Color(0xFF10B981); // Emerald green
    if (bmi < 30.0) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Crimson red
  }

  @override
  Widget build(BuildContext context) {
    final bmi = user.bmi;
    final category = user.bmiCategory;
    final bmiColor = _getBmiColor(bmi);

    // Normalize BMI for 0.0 - 1.0 progress bar (Range: 15.0 to 35.0)
    final clampedBmi = bmi.clamp(15.0, 35.0);
    final normalized = (clampedBmi - 15.0) / (35.0 - 15.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Biometric Health & BMI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (onEditRequested != null)
                TextButton.icon(
                  onPressed: onEditRequested,
                  icon: const Icon(Icons.edit_note, size: 18, color: AppColors.primary),
                  label: const Text(
                    'Update',
                    style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Biometric Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildBioTile(
                  label: 'Height',
                  value: '${user.height.toStringAsFixed(0)} cm',
                  icon: Icons.height,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBioTile(
                  label: 'Weight',
                  value: '${user.weight.toStringAsFixed(1)} kg',
                  icon: Icons.scale_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBioTile(
                  label: 'BMI Score',
                  value: bmi.toStringAsFixed(1),
                  badgeColor: bmiColor,
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Clinical Category Badge & Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clinical Classification:',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: bmiColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bmiColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  category,
                  style: TextStyle(color: bmiColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segmented Gradient Scale
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final indicatorPos = (width * normalized - 6.0).clamp(0.0, width - 12.0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 4 Zone Color Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          // Underweight (<18.5) -> (18.5-15)/20 = 17.5%
                          Expanded(
                            flex: 17,
                            child: Container(color: const Color(0xFF38BDF8)),
                          ),
                          const SizedBox(width: 2),
                          // Normal (18.5-25) -> (25-18.5)/20 = 32.5%
                          Expanded(
                            flex: 33,
                            child: Container(color: const Color(0xFF10B981)),
                          ),
                          const SizedBox(width: 2),
                          // Overweight (25-30) -> (30-25)/20 = 25%
                          Expanded(
                            flex: 25,
                            child: Container(color: const Color(0xFFF59E0B)),
                          ),
                          const SizedBox(width: 2),
                          // Obese (>30) -> (35-30)/20 = 25%
                          Expanded(
                            flex: 25,
                            child: Container(color: const Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pointer Needle
                  Positioned(
                    left: indicatorPos,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                        border: Border.all(color: bmiColor, width: 2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          // Scale Legend labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15.0', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              Text('18.5 (Normal)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              Text('25.0 (Over)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              Text('30.0+', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 14),
          // Caloric Burn & BMR Insights
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubStat('Basal BMR', '${user.bmr.round()} kcal'),
                Container(height: 20, width: 1, color: AppColors.border),
                _buildSubStat('Maintenance TDEE', '${user.tdee.round()} kcal'),
                Container(height: 20, width: 1, color: AppColors.border),
                _buildSubStat('Calorie Target', '${user.targetCalories} kcal'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioTile({
    required String label,
    required String value,
    required IconData icon,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: badgeColor ?? AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: badgeColor ?? AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String title, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
