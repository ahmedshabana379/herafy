import 'package:flutter/material.dart';
import 'package:herafy/features/home/widgets/tapbar_button.dart';

class ButtonsHomeBar extends StatelessWidget {
  const ButtonsHomeBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        HomeIcon(text: "المجتمع", icon: Icons.home, onTap: () {}),
        HomeIcon(text: "طلب خدمة", icon: Icons.bolt, onTap: () {}),
        HomeIcon(
          text: "العروض المقدمه",
          icon: Icons.price_change,
          onTap: () {},
        ),
        HomeIcon(text: "محادثاتك", icon: Icons.chat, onTap: () {}),
      ],
    );
  }
}
