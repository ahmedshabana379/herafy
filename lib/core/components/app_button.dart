import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.isButtonEnabled,
    this.onPressed,
    required this.text,
    this.isLoading = false,  this.buttonText,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isButtonEnabled;
  final bool isLoading;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,

      child: ElevatedButton(
        onPressed: isButtonEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: isButtonEnabled ? 2 : 0,
          backgroundColor: Color(AppColors.primaryColor),
          disabledBackgroundColor: Color(
            AppColors.primaryColor,
          ).withValues(alpha: 0.5),

          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ?  Text( buttonText! ,
                style: TextStyle(
                  color: Color(AppColors.primaryColor),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            // SizedBox(
            //     height: 20,
            //     width: 20,
            //     child: CircularProgressIndicator(
            //       color: Color(AppColors.primaryColor),
            //       strokeWidth: 2.5,
            //     ),
            //   )
            : Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
