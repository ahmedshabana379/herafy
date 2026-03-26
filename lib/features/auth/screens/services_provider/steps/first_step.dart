import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/components/text-field-label.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';

class FirstRegisterationStep extends StatelessWidget {
  const FirstRegisterationStep({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required this.onNext,
  }) : _formKey = formKey,
       _nameController = nameController,
       _emailController = emailController,
       _passwordController = passwordController,
       _confirmPasswordController = confirmPasswordController;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _nameController;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _confirmPasswordController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldLabel(title: "الاسم الكامل"),
            CustomTextField(
              isPassword: false,
              hintText: "أدخل إسمك بالكامل",
              icon: Icons.person_outline,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                } else if (value.length < 3) {
                  return 'الاسم الكامل يجب أن يكون على الأقل 3 أحرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFieldLabel(title: "البريد الإلكتروني"),
            CustomTextField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                // Simple email validation
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'الرجاء إدخال بريد إلكتروني صالح';
                }
                return null;
              },
              isPassword: false,
              hintText: "أدخل بريدك الإلكتروني",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 10),
            TextFieldLabel(title: "كلمة المرور"),
            CustomTextField(
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون على الأقل 6 أحرف';
                }
                return null;
              },
              isPassword: true,
              hintText: "أدخل كلمة المرور",
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 10),
            TextFieldLabel(title: "تأكيد كلمة المرور"),
            CustomTextField(
              controller: _confirmPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _passwordController.text) {
                  return 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
              isPassword: true,
              hintText: "أدخل كلمة المرور مرة أخرى",
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 30),
            AppButton(
              isButtonEnabled: true,
              text: "متابعة",
              isLoading: false,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final cubit = context.read<AuthCubit>();
                  cubit.providerName = _nameController.text.trim();
                  cubit.providerEmail = _emailController.text.trim();
                  cubit.providerPassword = _passwordController.text.trim();
      
                  onNext();
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
