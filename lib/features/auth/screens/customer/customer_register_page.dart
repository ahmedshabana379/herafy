import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/components/text-field-label.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/screens/login.dart';

class CustomerRegisterPage extends StatefulWidget {
  const CustomerRegisterPage({super.key});
  static const String routeName = "Register";
  @override
  State<CustomerRegisterPage> createState() => _CustomerRegisterPageState();
}

class _CustomerRegisterPageState extends State<CustomerRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.05;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.handyman_rounded, color: Color(0xFF2b2854)),
            const SizedBox(width: 8),
            const Text(
              "إنضم إلي حرفي",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2b2854),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(AppColors.cardsColor),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  size: 70,
                  color: Color(AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "إنضم إلى حرفي",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'انضم إلى حرفي وابدأ في استكشاف خدماتنا الاحترافية',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(AppColors.secondaryColor),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
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
                    BlocConsumer<AuthCubit, AuthState>(
                      builder: (context, state) {
                        bool isLoading = state is RegisterLoading;
                        return AppButton(
                          text: "إنشاء الحساب",
                          isButtonEnabled: true,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().register(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            }
                          },
                          isLoading: isLoading,
                        );
                      },
                      listener: (context, state) {
                        if (state is RegisterSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text('تم إنشاء الحساب بنجاح!')),
                              backgroundColor: Color(AppColors.primaryColor),
                            ),
                          );
                          Navigator.pushNamed(context, LoginPage.routeName);
                        } else if (state is RegisterError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
