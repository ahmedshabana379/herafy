import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/auth/models/user_model.dart';
import 'package:herafy/features/home/cubits/cubit/notifications_cubit_cubit.dart';
import 'package:herafy/features/home/cubits/cubit/notifications_cubit_state.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_cubit.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_state.dart';
import 'package:herafy/features/home/widgets/tapbar_button.dart';

class ButtonsHomeBar extends StatelessWidget {
  const ButtonsHomeBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.user,
  });

  final int selectedIndex;
  final Function(int) onTap;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    // بنستخدم BlocBuilder الأول لطلبات الخدمات
    return BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
      builder: (context, serviceState) {
        final serviceCubit = context.read<ServiceRequestCubit>();
        
        final inProgressCount = user?.isProvider == true
            ? serviceCubit.providerAssignedRequests
                  .where((r) => r.requestStatus == 2)
                  .length
            : 0;

        // بنستخدم BlocBuilder الثاني للإشعارات
        return BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, notificationState) {
            final notificationCubit = context.read<NotificationCubit>();
            
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
                user?.isProvider == true
                    ? HomeIcon(
                        text: "طلبات العملاء",
                        icon: Icons.dashboard,
                        isSelected: selectedIndex == 2,
                        onTap: () => onTap(2),
                        badgeCount: selectedIndex == 2 ? 0 : inProgressCount,
                      )
                    : HomeIcon(
                        text: "العروض",
                        icon: Icons.price_change,
                        isSelected: selectedIndex == 2,
                        onTap: () => onTap(2),
                      ),
                HomeIcon(
                  text: "الإشعارات",
                  icon: Icons.notifications,
                  isSelected: selectedIndex == 3,
                  onTap: () {
                    // أول ما يضغط بنصفر العداد من الـ Cubit
                    context.read<NotificationCubit>().markAsRead();
                    onTap(3);
                  },
                  // العداد بيقرأ مباشرة من الـ NotificationCubit
                  badgeCount: selectedIndex == 3 ? 0 : notificationCubit.unreadCount,
                ),
              ],
            );
          },
        );
      },
    );
  }
}