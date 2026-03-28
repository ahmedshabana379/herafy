import 'package:flutter/material.dart';
import 'package:herafy/features/home/widgets/tapbar_button.dart';

class ButtonsHomeBar extends StatelessWidget {
  const ButtonsHomeBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
    
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        HomeIcon(
          text: "المجتمع",
          icon: Icons.home,
          isSelected: selectedIndex == 0,
          onTap: () => onTap(0),
        ),
        HomeIcon(
          text: "طلب خدمة",
          icon: Icons.bolt,
          isSelected: selectedIndex == 1,
          onTap: () => onTap(1),
        ),
        HomeIcon(
          text: "العروض",
          icon: Icons.price_change,
          isSelected: selectedIndex == 2,
          onTap: () => onTap(2),
        ),
        HomeIcon(
          text: "محادثاتك",
          icon: Icons.chat,
          isSelected: selectedIndex == 3,
          onTap: () => onTap(3),
        ),
      ],
    );
  }
}