import 'package:flutter/material.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/models/user_model.dart';
import 'package:herafy/features/auth/screens/services_provider/provider_register_page.dart';
import 'package:herafy/features/home/screens/PagesView/community_page1.dart';
import 'package:herafy/features/home/screens/PagesView/drawers/client_drawer.dart';
import 'package:herafy/features/home/screens/PagesView/offers_page.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/pages/provider_dashboard_page.dart';
import 'package:herafy/features/home/screens/PagesView/quick_request_page.dart';
import 'package:herafy/features/home/widgets/bar_of_tapbar_buttons.dart';
import 'package:herafy/features/home/widgets/post_type_sheet.dart';

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
  UserModel? _user;
  bool _isProviderProfileCompleted = false;
  bool _isProviderPendingCompletion = false;

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
      final userData = await CacheHelper.getUserData();
      final profileCompleted = await CacheHelper.isProviderProfileCompleted();
      final providerPendingCompletion =
          await CacheHelper.isProviderPendingCompletion();
      final providerStep1Draft = await CacheHelper.getProviderStep1Data();
      final hasMatchingProviderDraft =
          providerStep1Draft != null &&
          userData?.email != null &&
          providerStep1Draft['email']?.toString().toLowerCase() ==
              userData!.email!.toLowerCase();
      setState(() {
        _user = userData;
        _isProviderProfileCompleted = profileCompleted;
        _isProviderPendingCompletion =
            providerPendingCompletion || hasMatchingProviderDraft;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
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
    final isProfileComplete =
        (_user?.isProfileComplete ?? false) || _isProviderProfileCompleted;
    final isProviderApproved = _user?.isAuthenticated == true;
    final showProviderDashboard =
        isProvider && isProfileComplete && isProviderApproved;
    final showCompleteProfileCta =
        (isProvider && !isProfileComplete) || _isProviderPendingCompletion;
    final showWaitingApprovalCta =
        isProvider && isProfileComplete && !isProviderApproved;

    // الهوم العادي للعميل
    return Scaffold(
      floatingActionButton: _selectedIndex == 0
          ? AnimatedScale(
              scale: _isBarVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton(
                backgroundColor: Color(AppColors.primaryColor),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => PostTypeSheet(),
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
      drawer: ClientDrawer(),
      body: Column(
        children: [
          if (showCompleteProfileCta || showWaitingApprovalCta)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F4FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4DCFF)),
                ),
                child: Row(
                  children: [
                    Icon(
                      showCompleteProfileCta
                          ? Icons.info_outline
                          : Icons.access_time_filled_rounded,
                      color: Color(AppColors.primaryColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        showCompleteProfileCta
                            ? "بيانات حسابك كمقدم خدمة غير مكتملة"
                            : "تم إرسال بياناتك وهي الآن قيد المراجعة",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (showCompleteProfileCta)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProviderRegisterPage(
                                startFromSecondStep: true,
                              ),
                            ),
                          );
                        },
                        child: const Text("إكمال"),
                      ),
                  ],
                ),
              ),
            ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isBarVisible ? 80 : 0,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: ButtonsHomeBar(
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

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
              children: [
                CommunityPage(scrollController: _scrollController),
                QuickRequestPage(),
                OffersPage(),
                showProviderDashboard
                    ? ProviderDashboardPage()
                    : const Center(
                        child: Text(
                          "الخدمة غير متاحة الآن",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
