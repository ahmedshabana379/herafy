import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/models/user_model.dart';
import 'package:herafy/features/auth/screens/login.dart';
import 'package:herafy/features/screens/edit_account_page.dart';

class AppDrawer extends StatelessWidget {
  final int receivedOffersCount;
  final UserModel? user;
  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    String domain = AppEndPoints.baseUrl.replaceAll('/api/', '');
    return domain.endsWith('/') ? "$domain$path" : "$domain/$path";
  }

  const AppDrawer({super.key, this.receivedOffersCount = 3, this.user});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          // Profile Header connected to real data
          _buildProfileHeader(context),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.edit_note_rounded,
                  title: "تعديل الحساب",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, EditAccountPage.routeName);
                  },
                ),
                // _buildMenuItem(
                //   icon: Icons.history_rounded,
                //   title: "المحفوظات ",
                //   onTap: () {},
                // ),
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  title: "خدماتك ",
                  onTap: () {},
                ),

                user?.isProvider == true
                    ? _buildMenuItem(
                        icon: Icons.local_offer_outlined,
                        title: "عروض الحرفيين",
                        trailing: _buildCounterBadge(receivedOffersCount),
                        onTap: () {},
                      )
                    : const SizedBox(),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Divider(color: Color(0xFFEEEEEE)),
                ),
              ],
            ),
          ),

          // Logout button with BlocListener
          _buildLogoutSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          current is UserDataUpdated ||
          current is LoginSuccess ||
          current is LogoutSuccess,
      builder: (context, state) {
        final user = context.read<AuthCubit>().currentUser;
        final displayEmail = user?.email ?? "";
        final isProvider = user?.isProvider ?? false;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 70,
            bottom: 25,
            right: 24,
            left: 24,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(AppColors.primaryColor),
                Color(AppColors.primaryColor).withOpacity(0.85),
              ],
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFF3F3F7),
                  backgroundImage: user?.pictureUrl != null
                      ? NetworkImage(_getFullImageUrl(user!.pictureUrl!))
                      : null,
                  child: user?.pictureUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 45,
                          color: Color(0xFF2b2854),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                displayEmail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isProvider ? "حرفي" : "عميل مميز",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            LoginPage.routeName,
            (route) => false,
          );
        } else if (state is LogoutError) {
          SnackBarHelper.showErrorSnackBar(context, state.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return TextButton.icon(
              onPressed: state is LogoutLoading
                  ? null
                  : () {
                      context.read<AuthCubit>().logout();
                    },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                backgroundColor: Colors.red.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: state is LogoutLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.redAccent,
                      ),
                    )
                  : const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                state is LogoutLoading ? "جاري الخروج..." : "تسجيل الخروج",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(AppColors.primaryColor).withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Color(AppColors.primaryColor), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          fontFamily: 'Cairo',
        ),
      ),
      trailing: trailing,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }

  Widget _buildCounterBadge(int count) {
    if (count == 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
