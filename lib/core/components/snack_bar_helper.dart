import 'package:flutter/material.dart';

class SnackBarHelper {
  static void showSuccessSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green, Icons.check_circle_outline);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red, Icons.error_outline);
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orange, Icons.warning_outlined);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue, Icons.info_outline);
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
