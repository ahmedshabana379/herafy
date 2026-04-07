import 'package:flutter/material.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/screens/services_provider/steps/first_step.dart';
import 'package:herafy/features/auth/screens/services_provider/steps/second_step.dart';

class ProviderRegisterPage extends StatefulWidget {
  const ProviderRegisterPage({
    super.key,
    this.startFromSecondStep = false,
  });
  static const String routeName = "ProviderRegister";
  final bool startFromSecondStep;
  @override
  State<ProviderRegisterPage> createState() => _ProviderRegisterPageState();
}

class _ProviderRegisterPageState extends State<ProviderRegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  double _progress = 0.0;

  void _updateProgress(double progress) {
    setState(() => _progress = progress);
  }

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
  void initState() {
    super.initState();
    _loadSavedProgress();

    if (widget.startFromSecondStep) {
      _currentPage = 1;
      if (_progress < 0.5) {
        _progress = 0.5;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pageController.jumpToPage(1);
          setState(() {});
        }
      });
    }
  }

  Future<void> _loadSavedProgress() async {
    final savedProgress = await CacheHelper.getProviderProgress();
    if (!mounted) return;
    setState(() {
      if (savedProgress > _progress) {
        _progress = savedProgress;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.05;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.startFromSecondStep
          ? AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(AppColors.primaryColor),
                ),
              ),
              automaticallyImplyLeading: false,
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
            )
          : AppBar(
              leading: _currentPage > 0
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color(AppColors.primaryColor),
                      ),
                      onPressed: previousStep,
                    )
                  : IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color(AppColors.primaryColor),
                      ),
                    ),
              automaticallyImplyLeading: false,
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
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(_progress * 100).toInt()}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.primaryColor),
                  ),
                ),
                Text(
                  "التقدم الحالي",
                  style: TextStyle(
                    color: Color(AppColors.secondaryColor),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              color: Color(AppColors.primaryColor),
              borderRadius: BorderRadius.circular(10),
              minHeight: 6,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  if (!widget.startFromSecondStep)
                    FirstRegisterationStep(
                      onProgressChanged: _updateProgress,
                      onNext: nextStep,
                      formKey: _formKey,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                    ),
                  if (widget.startFromSecondStep)
                    SecondRegisterationStep(
                      onBack: previousStep,
                      onProgressChanged: _updateProgress,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
