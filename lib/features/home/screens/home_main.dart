import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/models/user_model.dart';
import 'package:herafy/features/auth/screens/services_provider/provider_register_page.dart';
import 'package:herafy/features/home/screens/PagesView/community_page1.dart';
import 'package:herafy/features/home/screens/PagesView/drawers/client_drawer.dart';
import 'package:herafy/features/home/screens/PagesView/notifications.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/screens/offers_page.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/pages/provider_dashboard_page.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/screens/quick_request_page.dart';
import 'package:herafy/features/home/widgets/bar_of_tapbar_buttons.dart';
import 'package:herafy/features/home/widgets/post_type_sheet.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = "Home";
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  bool _isBarVisible = true;
  bool _approvedBannerDismissed = false; // ← جديد
  UserModel? _user;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection.name == 'reverse') {
        if (_isBarVisible) setState(() => _isBarVisible = false);
      } else {
        if (!_isBarVisible) setState(() => _isBarVisible = true);
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      var user = context.read<AuthCubit>().currentUser;
      user ??= await CacheHelper.getUserData();
      final dismissed = await CacheHelper.isApprovedBannerDismissed();

      setState(() {
        _user = user;
        _approvedBannerDismissed = dismissed;
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = _user?.isProvider == true;
    final int status = _user?.status ?? 0;
    final bool isProfileComplete = _user?.isProfileComplete ?? false;

    final showCompleteProfileCta =
        isProvider && status == 0 && _selectedIndex == 0;
    final showWaitingApprovalCta =
        isProvider && status == 1 && _selectedIndex == 0;
    final showApprovedCta =
        isProvider &&
        status == 2 &&
        !_approvedBannerDismissed &&
        _selectedIndex == 0;
    final showRejectedCta = isProvider && status == 3;
    final showProviderDashboard =
        isProvider && status == 2 && _selectedIndex == 0;

    return Scaffold(
      floatingActionButton: _selectedIndex == 0
          ? AnimatedScale(
              scale: _isBarVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton(
                heroTag: "post_type_btn",
                backgroundColor: Color(AppColors.primaryColor),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => PostTypeSheet(user: _user),
                  );
                },
                child: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
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
      drawer: AppDrawer(user: _user),
      body: Column(
        children: [
          // --- Banners ---
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isBarVisible && showCompleteProfileCta ? null : 0,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(),
            child: _buildBanner(
              icon: Icons.info_outline,
              message: "بيانات حسابك كمقدم خدمة غير مكتملة",
              actionLabel: "إكمال",
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProviderRegisterPage(startFromSecondStep: true),
                  ),
                );
              },
            ),
          ),

          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isBarVisible && showWaitingApprovalCta ? null : 0,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(),
            child: _buildBanner(
              icon: Icons.access_time_filled_rounded,
              message: "تم إرسال بياناتك وهي الآن قيد المراجعة",
            ),
          ),

          // ← Banner الموافقة الجديد
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isBarVisible && showApprovedCta ? null : 0,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(),
            child: _buildBanner(
              icon: Icons.check_circle_outline,
              message: "🎉 تهانينا! تم قبولك كمقدم خدمة",
              color: Colors.green.shade50,
              borderColor: Colors.green.shade200,
              iconColor: Colors.green,
              onDismiss: () async {
                await CacheHelper.dismissApprovedBanner();
                setState(() => _approvedBannerDismissed = true);
              },
            ),
          ),

          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isBarVisible && showRejectedCta ? null : 0,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(),
            child: _buildBanner(
              icon: Icons.cancel_outlined,
              message: "تم رفض طلبك، يرجى التواصل مع الدعم",
              color: Colors.red.shade50,
              borderColor: Colors.red.shade200,
              iconColor: Colors.redAccent,
            ),
          ),

          // --- Nav Bar ---
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isBarVisible ? 80 : 0,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: ButtonsHomeBar(
                user: _user,
                selectedIndex: _selectedIndex,
                onTap: (index) {
                  if (_selectedIndex == index && index == 0) {
                    _scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  } else {
                    setState(() => _selectedIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ),

          // --- Pages ---
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
              children: [
                CommunityPage(scrollController: _scrollController),
                QuickRequestPage(),
                _user?.isProvider == true
                    ? ProviderDashboardPage()
                    : OffersPage(),
                NotificationsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss, // ← جديد
    Color? color,
    Color? borderColor,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color ?? const Color(0xFFF6F4FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? const Color(0xFFE4DCFF)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Color(AppColors.primaryColor)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            // ← زرار الإغلاق
            if (onDismiss != null)
              IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
