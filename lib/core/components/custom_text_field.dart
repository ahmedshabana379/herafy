import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.isPassword,
    required this.hintText,
    required this.icon,
    this.controller,
    this.validator,
  });
  final bool isPassword;
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool obscureText;
  @override
  void initState() {
    super.initState();
    obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofillHints: widget.isPassword ? [AutofillHints.password] : [AutofillHints.email],
      controller: widget.controller,
      validator: widget.validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        fillColor: Color(AppColors.fillColor),
        filled: true,
        hint: Text(widget.hintText),
        prefixIcon: Icon(widget.icon, color: Colors.grey.shade400),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
