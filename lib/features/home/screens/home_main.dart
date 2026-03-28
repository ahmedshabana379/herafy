import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/screens/PagesView/community_page1.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection.name == 'reverse') {
        if (_isBarVisible) setState(() => _isBarVisible = false);
      } else {
        if (!_isBarVisible) setState(() => _isBarVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: Drawer(),
      body: Column(
        children: [
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
                Center(child: Text("العروض")),
                Center(child: Text("المحادثات")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
