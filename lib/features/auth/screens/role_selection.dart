import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/role_card.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AuthCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "حرفي",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2b2854),
            ),
          ),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, state) {
            int? selectedRole = (state is SelectRoleState)
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
                      isSelected: selectedRole == 0,
                      onTap: () => context.read<AuthCubit>().selectRole(0),
                    ),
                    const SizedBox(height: 16),
                    RoleCard(
                      role: 'مزود خدمات',
                      isSelected: selectedRole == 1,
                      onTap: () => context.read<AuthCubit>().selectRole(1),
                      description: 'أرغب في اقديم خدماتي المهنية للعملاء',
                      icon: Icons.build_rounded,
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () {
                                context.read<AuthCubit>().onContinue();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonEnabled
                              ? Color(AppColors.primaryColor)
                              : Colors.grey.shade400,
                          minimumSize: Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "متابعة",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
