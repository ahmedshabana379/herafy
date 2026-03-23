import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/role_card.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/core/resourses/constants.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/screens/customer/customer_register_page.dart';
import 'package:herafy/features/auth/screens/services_provider/provider_register_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});
  static const String routeName = "RoleSelection";
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
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (BuildContext context, state) {
          final selected = context.read<AuthCubit>().selectedRole;
          UserRole? selectedRole = (state is SelectRoleState)
              ? state.selectedRole
              : null;
          bool isButtonEnabled = selectedRole != null;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "إنشاء حساب جديد",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر نوع الحساب للبدء في استخدام تطبيق حرفي',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(AppColors.secondaryColor),
                    ),
                  ),
                  const SizedBox(height: 40),
                  RoleCard(
                    role: "عميل",
                    description: "أبحث عن فنيين وخدمات احترافية لمنزلي",
                    icon: Icons.person_search_rounded,
                    isSelected: selectedRole == UserRole.client,
                    onTap: () =>
                        context.read<AuthCubit>().selectRole(UserRole.client),
                  ),
                  const SizedBox(height: 16),
                  RoleCard(
                    role: 'مزود خدمات',
                    isSelected: selectedRole == UserRole.serviceProvider,
                    onTap: () => context.read<AuthCubit>().selectRole(
                      UserRole.serviceProvider,
                    ),
                    description: 'أرغب في اقديم خدماتي المهنية للعملاء',
                    icon: Icons.handyman_rounded,
                  ),
                  SizedBox(height: 40),
                  AppButton(
                    isButtonEnabled: isButtonEnabled,
                    onPressed: () => selected == null
                        ? null
                        : context.read<AuthCubit>().onContinue(),
                    text: 'متابعة',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            color: Color(AppColors.primaryColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "لديك حساب بالفعل؟",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        listener: (BuildContext context, AuthState state) {
          if (state is NavigateToCustomerRegister) {
            Navigator.pushNamed(context, CustomerRegisterPage.routeName);
          } else if (state is NavigateToProviderRegister) {
            Navigator.pushNamed(context, ProviderRegisterPage.routeName);
          }
        },
      ),
    );
  }
}
