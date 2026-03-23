import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/screens/services_provider/steps/first_step.dart';
import 'package:herafy/features/auth/screens/services_provider/steps/second_step.dart';

class ProviderRegisterPage extends StatefulWidget {
  const ProviderRegisterPage({super.key});
  static const String routeName = "ProviderRegister";
  @override
  State<ProviderRegisterPage> createState() => _ProviderRegisterPageState();
}

class _ProviderRegisterPageState extends State<ProviderRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  void nextStep() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void previousStep() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
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
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Color(AppColors.cardsColor),
                  child: Text(
                    "${_currentPage + 1}",
                    style: TextStyle(
                      color: Color(AppColors.primaryColor),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
      
            LinearProgressIndicator(
              value: (_currentPage + 1) / 2,
              backgroundColor: Colors.grey[200],
              color: Color(AppColors.primaryColor),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(AppColors.cardsColor),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.handyman_rounded,
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
              'إبدا رحلتك المهنية مع تطبيق حرفي الأن',
              style: TextStyle(
                fontSize: 20,
                color: Color(AppColors.secondaryColor),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  FirstRegisterationStep(
                    onNext: nextStep,
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                  ),
                  SecondRegisterationStep(onBack: previousStep),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
