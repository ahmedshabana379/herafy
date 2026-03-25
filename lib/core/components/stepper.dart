
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class CustomHorizontalStepper extends StatelessWidget {
  const CustomHorizontalStepper({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(AppColors.primaryColor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(isCompleted: true, title: "تم التقديم"),
        const Expanded(
          child: Divider(
            color: primaryColor,
            thickness: 1.5,
            endIndent: 5,
            indent: 5,
          ),
        ),
        _buildStepIndicator(
          isCompleted: true,
          isCurrent: true,
          title: "قيد المراجعة",
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1.5,
            endIndent: 5,
            indent: 5,
          ),
        ),
        _buildStepIndicator(isCompleted: false, title: "تم الموافقة"),
      ],
    );
  }

  Widget _buildStepIndicator({
    required bool isCompleted,
    bool isCurrent = false,
    required String title,
  }) {
    const primaryColor = Color(AppColors.primaryColor);
    const textColor = Color(AppColors.secondaryColor);

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? primaryColor : Colors.white,
            shape: BoxShape.circle,
            border: isCurrent
                ? null
                : Border.all(
                    color: isCompleted ? primaryColor : Colors.grey[300]!,
                    width: 1.5,
                  ),
          ),
          child: Center(
            child: isCurrent
                ? const Icon(
                    Icons.circle_rounded,
                    color: Colors.white,
                    size: 14,
                  )
                : Icon(
                    isCompleted
                        ? Icons.check_circle_outline
                        : Icons.circle_outlined,
                    color: isCompleted ? Colors.white : Colors.grey[400]!,
                    size: 18,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isCurrent || isCompleted ? textColor : Colors.grey[400]!,
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
