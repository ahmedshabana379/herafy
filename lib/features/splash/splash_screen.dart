// import 'package:flutter/material.dart';
// import 'package:herafy/core/networks/cache_helper.dart';
// import 'package:herafy/features/auth/screens/login.dart';
// import 'package:herafy/features/home/screens/home_main.dart';
// import 'package:herafy/features/screens/complete_data.dart';




// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     // Future.delayed(Duration(seconds: 6), () async {
//     //   CacheHelper.getToken().then((value) {
//     //     if (value != null && value.isNotEmpty) {
//     //       Navigator.pushReplacement(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (context) => HomePage(user: ,),
//     //           ));
//     //     } else {
//     //       Navigator.pushReplacement(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (context) => LoginPage(),
//     //           ));
//     //     }
//     //   });
//     // });
//   Future.delayed(const Duration(seconds: 2), () async {
//       final token = await CacheHelper.getToken();
//       final status = await CacheHelper.getStatus();
//       final isProvider = await CacheHelper.getRole();
//       if (token != null && token.isNotEmpty  ) {

//         if (  status != 0) {
//           Navigator.pushReplacementNamed(
//             context,
//             HomePage.routeName,
//           );
//         } 
        

//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginPage()),
//         );
//       }});
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(child: Text("hello")),
//     );
//   }}
