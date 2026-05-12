// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:herafy/core/networks/cache_helper.dart';
// import 'package:herafy/features/auth/cubits/auth_cubit.dart';
// import 'package:herafy/features/auth/screens/login.dart';
// import 'package:herafy/features/home/screens/home_main.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//  static const  String routeName = "SplashScreen";

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }


// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<int> _charIndexAnimation;

//   // كلمة "حِرَفِيّ" مع تشكيلها
//   final String _fullWord = "حِرَفِيّ";
//   final List<String> _characters = [];
//   String _displayedText = "";
//   bool _animationCompleted = false;

//   @override
//   void initState() {
//     super.initState();
//     _buildCharactersList();
//     _setupAnimation();
//     _checkAuthAndNavigate();
//   }

//   void _buildCharactersList() {
//     // "حِرَفِيّ" -> ['حِ', 'رَ', 'فِ', 'يّ']
//     _characters.addAll(['حِ', 'رَ', 'فِ', 'يّ']);
//   }

//   void _setupAnimation() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _charIndexAnimation = IntTween(begin: 0, end: _characters.length).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     _animationController.addListener(() {
//       setState(() {
//         int currentIndex = _charIndexAnimation.value;
//         if (currentIndex > _characters.length) {
//           currentIndex = _characters.length;
//         }
//         _displayedText = _characters.take(currentIndex).join('');

//         if (currentIndex == _characters.length && !_animationCompleted) {
//           setState(() {
//             _animationCompleted = true;
//           });
//         }
//       });
//     });

//     _animationController.forward();
//   }

//   Future<void> _checkAuthAndNavigate() async {
//     // انتظار انتهاء الأنيميشن (1.5 ثانية)
//     await Future.delayed(const Duration(milliseconds: 1800));

//     // جلب التوكن
//     final token = await CacheHelper.getToken();

//     if (mounted) {
//       if (token != null && token.isNotEmpty) {
//         // جلب بيانات المستخدم من السيرفر
//         await context.read<AuthCubit>().fetchUserProfile();

//         if (mounted) {
//           Navigator.pushReplacementNamed(context, HomePage.routeName);
//         }
//       } else {
//         if (mounted) {
//           Navigator.pushReplacementNamed(context, LoginPage.routeName);
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // الأنيميشن الرئيسي
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2b2854).withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: _buildAnimatedCharacters(),
//               ),
//             ),
//             const SizedBox(height: 40),

//             // مؤشر التحميل (يظهر بعد الأنيميشن)
//             if (_animationCompleted)
//               Column(
//                 children: [
//                   const CircularProgressIndicator(
//                     color: Color(0xFF2b2854),
//                     strokeWidth: 2,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "جاري تحميل بياناتك...",
//                     style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildAnimatedCharacters() {
//     List<Widget> widgets = [];

//     for (int i = 0; i < _characters.length; i++) {
//       final isVisible = i < _charIndexAnimation.value;

//       widgets.add(
//         AnimatedOpacity(
//           duration: Duration(milliseconds: 120 * (i + 1)),
//           opacity: isVisible ? 1.0 : 0.0,
//           child: AnimatedSlide(
//             duration: Duration(milliseconds: 150 * (i + 1)),
//             offset: isVisible ? Offset.zero : const Offset(0, 0.3),
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               child: Text(
//                 _characters[i],
//                 style: const TextStyle(
//                   fontSize: 44,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2b2854),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return widgets;
//   }
// }
