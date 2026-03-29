import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class QuickRequestPage extends StatefulWidget {
  const QuickRequestPage({super.key, this.scrollController});
  final ScrollController? scrollController;

  @override
  State<QuickRequestPage> createState() => _QuickRequestPageState();
}

class _QuickRequestPageState extends State<QuickRequestPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  String? selectedService;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // الألوان المختلفة للكروت
  final List<Color> _cardColors = [
    Color(0xFF6C63FF),
    Color(0xFF3ECFCF),
    Color(0xFFFF6584),
    Color(0xFFFFAA5A),
    Color(0xFF43C59E),
    Color(0xFF5B8DEF),
    Color(0xFFFF7EB3),
    Color(0xFF9B59B6),
  ];

  final List<Map<String, dynamic>> _services = [
    {"name": "سباك", "icon": Icons.water_drop_outlined},
    {"name": "كهربائي", "icon": Icons.electric_bolt_outlined},
    {"name": "نجار", "icon": Icons.carpenter},
    {"name": "نقاش", "icon": Icons.format_paint_outlined},
    {"name": "فني تكييف", "icon": Icons.ac_unit_outlined},
    {"name": "بناء", "icon": Icons.foundation_outlined},
    {"name": "فني سيراميك", "icon": Icons.grid_4x4_outlined},
    {"name": "حداد", "icon": Icons.hardware_outlined},
    {"name": "فني جبس", "icon": Icons.square_outlined},
    {"name": "فني ألمونيوم", "icon": Icons.window_outlined},
    {"name": "مقاول", "icon": Icons.construction_outlined},
    {"name": "فني صرف", "icon": Icons.plumbing_outlined},
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services
        .where((s) => s["name"].toString().contains(_searchQuery))
        .toList();
  }

  @override
  void dispose() {
    _descController.dispose();
    _budgetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // السيرش بار
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "ابحث عن خدمة...",
              prefixIcon: Icon(
                Icons.search,
                color: Color(AppColors.primaryColor),
              ),
              filled: true,
              fillColor: Color(AppColors.cardsColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // عنوان الخدمات
          Text(
            "اختر نوع الخدمة",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 12),

          // كروت الخدمات
          _filteredServices.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "مفيش خدمة بالاسم ده",
                      style: TextStyle(color: Color(AppColors.secondaryColor)),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_filteredServices.length, (index) {
                    final service = _filteredServices[index];
                    final color = _cardColors[index % _cardColors.length];
                    final isSelected = selectedService == service["name"];

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedService = service["name"]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              service["icon"] as IconData,
                              size: 18,
                              color: isSelected ? Colors.white : color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              service["name"],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // وصف المشكلة والميزانية
          Text(
            "تفاصيل الطلب",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 12),

          // الوصف والميزانية في Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // وصف المشكلة
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "اوصف مشكلتك بالتفصيل...",
                    filled: true,
                    fillColor: Color(AppColors.cardsColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // الميزانية
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // ارقام بس
                  ],
                  decoration: InputDecoration(
                    hintText: "الميزانية",
                    suffixText: "ج.م",
                    filled: true,
                    fillColor: Color(AppColors.cardsColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // زرار الإرسال
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedService == null ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primaryColor),
                disabledBackgroundColor: Color(
                  AppColors.primaryColor,
                ).withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                selectedService == null ? "اختر خدمة أولاً" : "إرسال الطلب",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
