import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/components/text-field-label.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/screens/role_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String routeName = "Login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  void _loadUserSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('saved_email') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
      rememberMe = prefs.getBool('remember_me') ?? false;
    });
  }

  void saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('saved_email', _emailController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserSavedData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.handyman_rounded, color: Color(0xFF2b2854)),
            const SizedBox(width: 8),
            const Text(
              "حرفي",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2b2854),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "مرحباً بعودتك ",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بتسجيل الدخول إلى حسابك للمتابعة',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(AppColors.secondaryColor),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // lable and text field for email and password
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
                    hintText: "example@email.com",
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
                        return 'كلمة المرور ضعيفه جدا ';
                      }
                      return null;
                    },
                    isPassword: true,
                    hintText: "**********",
                    icon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        activeColor: Color(AppColors.primaryColor),
                      ),
                      const Text(
                        "تذكرني",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "نسيت كلمة المرور؟",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  BlocConsumer<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        isLoading: state is LoginLoading,
                        isButtonEnabled: state is! LoginLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Perform login action
                            context.read<AuthCubit>().login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          }
                        },
                        text: 'تسجيل الدخول',
                      );
                    },
                    listener: (context, state) {
                      if (state is LoginSuccess) {
                        saveUserData();
                        Navigator.pushNamed(
                          context,
                          RoleSelectionPage.routeName,
                        );
                      } else if (state is LoginError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),

                  // او متابعه عبر جوجل

                  //  //////////
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RoleSelectionPage.routeName,
                          );
                        },
                        child: Text(
                          "سجل الأن",
                          style: TextStyle(
                            color: Color(AppColors.primaryColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "ليس لديك حساب؟",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
