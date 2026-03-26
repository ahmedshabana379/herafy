import 'package:flutter/material.dart';
import 'package:herafy/features/home/widgets/bar_of_tapbar_buttons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const routeName = "Home";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.05;
    return Scaffold(
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(children: [SizedBox(height: 10), ButtonsHomeBar()]),
      ),
    );
  }
}
