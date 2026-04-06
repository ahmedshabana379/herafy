import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/screens/edit_account_page.dart';

class ClientDrawer extends StatelessWidget {
  final int receivedOffersCount;

  const ClientDrawer({super.key, this.receivedOffersCount = 3});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width:
          MediaQuery.of(context).size.width *
          0.8, // الدرور ياخد 80% من الشاشة عشان يبان شيك
      child: Column(
        children: [
          // Header المطور
          _buildProfileHeader(context),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.edit_note_rounded,
                  title: "تعديل الحساب",
                  onTap: () {
                    Navigator.pop(context); // قفل الدرور الأول
                    Navigator.pushNamed(context, EditAccountPage.routeName);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_active_outlined,
                  title: "الإشعارات",
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.local_offer_outlined,
                  title: "عروض الحرفيين",
                  trailing: _buildCounterBadge(receivedOffersCount),
                  onTap: () {},
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Divider(color: Color(0xFFEEEEEE)),
                ),

                _buildMenuItem(
                  icon: Icons.palette_outlined,
                  title: "مظهر التطبيق",
                  trailing: Switch(
                    value: false, // تربطه بالـ Theme Provider
                    onChanged: (val) {},
                    activeColor: Color(AppColors.primaryColor),
                    activeTrackColor: Color(
                      AppColors.primaryColor,
                    ).withOpacity(0.3),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // تسجيل الخروج في الأسفل بشكل أنيق
          _buildLogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 70, bottom: 25, right: 24, left: 24),
      decoration: BoxDecoration(
        // Gradient خفيف بألوان الهوية
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(AppColors.primaryColor),
            Color(AppColors.primaryColor).withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.primaryColor).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFF3F3F7),
              child: Icon(Icons.person, size: 45, color: Color(0xFF2b2854)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "أحمد شبانة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "عميل مميز",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
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

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: Colors.redAccent,
          backgroundColor: Colors.red.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          "تسجيل الخروج",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
