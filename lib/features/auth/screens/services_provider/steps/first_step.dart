import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/components/text-field-label.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/screens/login.dart';

class FirstRegisterationStep extends StatefulWidget {
  const FirstRegisterationStep({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required this.onNext,
    required this.onProgressChanged,
  }) : _formKey = formKey,
       _firstNameController = firstNameController,
       _lastNameController = lastNameController,
       _emailController = emailController,
       _passwordController = passwordController,
       _confirmPasswordController = confirmPasswordController;

  final GlobalKey<FormState> _formKey;
  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;
  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _confirmPasswordController;
  final VoidCallback onNext;
  final Function(double) onProgressChanged;

  @override
  State<FirstRegisterationStep> createState() => _FirstRegisterationStepState();
}

class _FirstRegisterationStepState extends State<FirstRegisterationStep> {
  void _calculateProgress() {
    int filled = 0;
    const int total = 10; // إجمالي كل الـ fields في الصفحتين
    if (widget._firstNameController.text.trim().isNotEmpty) filled++;
    if (widget._lastNameController.text.trim().isNotEmpty) filled++;
    if (widget._emailController.text.trim().isNotEmpty) filled++;
    if (widget._passwordController.text.length >= 6) filled++;
    if (widget._confirmPasswordController.text ==
            widget._passwordController.text &&
        widget._confirmPasswordController.text.isNotEmpty) {
      filled++;
    }

    widget.onProgressChanged(filled / total);
  }

  @override
  void initState() {
    super.initState();
    widget._firstNameController.addListener(_calculateProgress);
    widget._lastNameController.addListener(_calculateProgress);
    widget._emailController.addListener(_calculateProgress);
    widget._passwordController.addListener(_calculateProgress);
    widget._confirmPasswordController.addListener(_calculateProgress);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: widget._formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldLabel(title: "الاسم الكامل"),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextFieldLabel(title: " إسم العائلة"),
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        hintText: "إسم العائلة",
                        icon: Icons.person_outline,
                        controller: widget._firstNameController,
                        validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextFieldLabel(title: "الإسم الأول"),
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        hintText: "إسمك",
                        icon: Icons.people_outline,
                        controller: widget._lastNameController,
                        validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFieldLabel(title: "البريد الإلكتروني"),
            CustomTextField(
              keyboardType: TextInputType.emailAddress,
              controller: widget._emailController,
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
              keyboardType: TextInputType.text,
              controller: widget._passwordController,
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
              keyboardType: TextInputType.text,
              controller: widget._confirmPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != widget._passwordController.text) {
                  return 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
              isPassword: true,
              hintText: "أدخل كلمة المرور مرة أخرى",
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 30),
            BlocConsumer<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is RegisterLoading;
                return AppButton(
                  isButtonEnabled: !isLoading,
                  text: "إنشاء الحساب",
                  isLoading: isLoading,
                  buttonText: "جاري إنشاء الحساب...",
                  onPressed: () {
                    if (widget._formKey.currentState!.validate()) {
                      final cubit = context.read<AuthCubit>();
                      cubit.register(
                        firstName: widget._firstNameController.text.trim(),
                        lastName: widget._lastNameController.text.trim(),
                        email: widget._emailController.text.trim(),
                        password: widget._passwordController.text.trim(),
                        isProvider: true,
                      );
                    }
                  },
                );
              },
              listener: (context, state) {
                if (state is RegisterSuccess) {
                  SnackBarHelper.showSuccessSnackBar(
                    context,
                    'تم إنشاء الحساب بنجاح!',
                  );
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                } else if (state is RegisterError) {
                  SnackBarHelper.showErrorSnackBar(context, state.message);
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
