import 'package:flutter/material.dart';
import 'package:herafy/core/components/info_card_for_waiting_page.dart';
import 'package:herafy/core/components/stepper.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class WaitingApprovePage extends StatelessWidget {
  static const String routeName = 'WaitingApprove';

  const WaitingApprovePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(AppColors.primaryColor);
    const textColor = Color(AppColors.secondaryColor);
    const cardBgColor = Color(AppColors.cardsColor);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,

        title: const Text(
          "حالة الطلب",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                    ),
                    CircleAvatar(radius: 50, backgroundColor: Colors.white),
                    const Icon(
                      Icons.assignment_ind_outlined,
                      size: 50,
                      color: primaryColor,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.access_time_filled_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "طلبك قيد المراجعة",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "نحن نراجع بياناتك الأن لضمان معايير الجودة العالية وتأمين حسابك.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              const CustomHorizontalStepper(),
              const SizedBox(height: 40),

              const InfoCard(
                icon: Icons.access_time_rounded,
                title: "وقت المراجعة",
                description: "يستغرق عادةً 24 ساعة عمل من وقت التقديم.",
              ),
              const SizedBox(height: 15),
              const InfoCard(
                icon: Icons.verified_user_outlined,
                title: "أمن البيانات",
                description: "بياناتك مشفرة ومحمية وفق أعلى المعايير التقنية.",
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.support_agent_outlined,
                    color: primaryColor,
                  ),
                  label: const Text(
                    "التحدث مع الدعم",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardBgColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "رقم المرجع: REQ-99281#",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
