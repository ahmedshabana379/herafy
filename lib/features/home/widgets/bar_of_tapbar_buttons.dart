import 'package:flutter/material.dart';
import 'package:herafy/features/auth/models/user_model.dart';
import 'package:herafy/features/home/widgets/tapbar_button.dart';

class ButtonsHomeBar extends StatelessWidget {
  const ButtonsHomeBar({
    super.key,
    required this.selectedIndex,
    required this.onTap, this.user,
  });

  final int selectedIndex;
  final Function(int) onTap;
  final UserModel? user;
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
        user?.isProvider == true ?
          HomeIcon(
            text: " طلبات العملاء",
            icon: Icons.dashboard,
            isSelected: selectedIndex == 2,
            onTap: () => onTap(2),
          ):
        HomeIcon(
          text: "العروض",
          icon: Icons.price_change,
          isSelected: selectedIndex == 2,
          onTap: () => onTap(2),
        ),
        HomeIcon(
          text: "الإشعارات",
          icon: Icons.notifications,
          isSelected: selectedIndex == 3,
          onTap: () => onTap(3),
        ),
      ],
    );
  }
}