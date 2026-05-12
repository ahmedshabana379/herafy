import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/models/services_model.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_cubit.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/map_picker_screen.dart';
import 'package:image_picker/image_picker.dart';

class QuickRequestPage extends StatefulWidget {
  const QuickRequestPage({super.key, this.scrollController});
  final ScrollController? scrollController;
  static const String routeName = "/quick_request_page";
  @override
  State<QuickRequestPage> createState() => _QuickRequestPageState();
}

class _QuickRequestPageState extends State<QuickRequestPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Controllers
  final TextEditingController _descController = TextEditingController();
  // final TextEditingController _budgetController = TextEditingController(); // DELETED: Removed budget controller
  final TextEditingController _searchController = TextEditingController();

  // Variables
  ServiceModel? selectedService;
  String _searchQuery = '';

  // Location variables
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedAddress = '';

  // Images
  List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Price validation
  // String? _priceErrorMessage; // DELETED: Removed price error message
  // int? _minPrice; // DELETED: Removed min price variable

  @override
  void initState() {
    super.initState();
    // _budgetController.addListener(_validatePrice); // DELETED: Removed price validation listener
    // ✅ جلب الخدمات عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().getServicesData();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    // _budgetController.dispose(); // DELETED: Removed budget controller disposal
    _searchController.dispose();
    // _budgetController.removeListener(_validatePrice); // DELETED: Removed price validation listener removal
    super.dispose();
  }

  // void _validatePrice() { // DELETED: Removed entire price validation method
  //   final String priceText = _budgetController.text;
  //   if (priceText.isEmpty) {
  //     setState(() {
  //       _priceErrorMessage = null;
  //     });
  //     return;
  //   }

  //   final int? price = int.tryParse(priceText);
  //   if (price == null) {
  //     setState(() {
  //       _priceErrorMessage = "من فضلك أدخل رقم صحيح";
  //     });
  //     return;
  //   }

  //   if (selectedService != null && selectedService!.minPrice != null) {
  //     _minPrice = selectedService!.minPrice;
  //     if (price < _minPrice!) {
  //       setState(() {
  //         _priceErrorMessage = "الحد الأدنى لخدمة ${selectedService!.name} هو $_minPrice ج.م";
  //       });
  //     } else {
  //       setState(() {
  //         _priceErrorMessage = null;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _priceErrorMessage = null;
  //     });
  //   }
  // }

  Future<void> _openMapPicker() async {
    print(
      "📍 فتح الخريطة - الإحداثيات الحالية: $_selectedLatitude, $_selectedLongitude",
    );
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLatitude: _selectedLatitude ?? 30.0444,
          initialLongitude: _selectedLongitude ?? 31.2357,
          useCurrentLocation: true,
        ),
      ),
    );
    print("📍 النتيجة من الخريطة: $result");

    if (result != null && mounted) {
      print("📍 Latitude من النتيجة: ${result['latitude']}");
      print("📍 Longitude من النتيجة: ${result['longitude']}");
      print("📍 Address من النتيجة: ${result['address']}");

      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _selectedAddress = result['address'];
      });
      print("📍 بعد setState - _selectedLatitude: $_selectedLatitude");
      print("📍 بعد setState - _selectedLongitude: $_selectedLongitude");
    } else {
      print("⚠️ النتيجة null أو المود unh mounted");
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 5) {
          _selectedImages = _selectedImages.take(5).toList();
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  bool _validateForm() {
    if (selectedService == null) {
      SnackBarHelper.showWarningSnackBar(context, "من فضلك اختر نوع الخدمة");
      return false;
    }

    if (_descController.text.trim().isEmpty) {
      SnackBarHelper.showWarningSnackBar(context, "من فضلك اكتب وصف للمشكلة");
      return false;
    }

    // DELETED: Removed budget validation block
    // if (_budgetController.text.trim().isEmpty) {
    //   SnackBarHelper.showWarningSnackBar(context, "من فضلك ادخل الميزانية");
    //   return false;
    // }

    // if (_priceErrorMessage != null) {
    //   SnackBarHelper.showWarningSnackBar(context, _priceErrorMessage!);
    //   return false;
    // }

    if (_selectedLatitude == null || _selectedLongitude == null) {
      SnackBarHelper.showWarningSnackBar(context, "من فضلك حدد موقعك على الخريطة");
      return false;
    }

    return true;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(AppColors.primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildSectionTitle("اختر نوع الخدمة"),
            const SizedBox(height: 12),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  current is GetServicesSuccess ||
                  current is GetServicesLoading ||
                  current is GetServicesError,
              builder: (context, state) {
                var cubit = context.read<AuthCubit>();

                if (state is GetServicesLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is GetServicesError) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          "حدث خطأ: ${state.message}",
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextButton(
                          onPressed: () => cubit.getServicesData(),
                          child: const Text("إعادة المحاولة"),
                        ),
                      ],
                    ),
                  );
                }

                if (cubit.services.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("لا توجد خدمات متاحة حالياً"),
                    ),
                  );
                }

                final filteredServices = _searchQuery.isEmpty
                    ? cubit.services
                    : cubit.services
                        .where((s) => (s.name ?? '')
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                // لو الخدمة المختارة فيلترت من النتائج، صفِّر
                if (selectedService != null &&
                    !filteredServices.contains(selectedService)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() => selectedService = null);
                  });
                }

                return DropdownButtonFormField<ServiceModel>(
                  value: selectedService,
                  isExpanded: true,
                  validator: (value) =>
                      value == null ? 'الرجاء اختيار المهنة الرئيسية' : null,
                  items: filteredServices
                      .map(
                        (service) => DropdownMenuItem<ServiceModel>(
                          value: service,
                          child: Text(
                            service.name ?? "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedService = value;
                      cubit.providerCategory = value?.id.toString();
                    });
                    // _validatePrice(); // DELETED: Removed price validation call
                  },
                  hint: const Text("اختر من القائمة"),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.work_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildSectionTitle("وصف المشكلة"),
            const SizedBox(height: 12),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            // _buildImagesAndBudgetSection(), // DELETED: Removed old combined section
            _buildImagesSectionFullWidth(), // NEW: Added full-width images section
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: "ابحث عن خدمة...",
        prefixIcon: Icon(Icons.search, color: Color(AppColors.primaryColor)),
        filled: true,
        fillColor: Color(AppColors.cardsColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(AppColors.cardsColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Color(AppColors.primaryColor)),
              const SizedBox(width: 8),
              Text(
                "موقعك",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _openMapPicker,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAddress.isNotEmpty
                              ? _selectedAddress
                              : "اضغط لتحديد موقعك على الخريطة",
                          style: TextStyle(
                            color: _selectedAddress.isNotEmpty
                                ? Colors.black
                                : Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedLatitude != null)
                          Text(
                            "${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
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
    );
  }

  // DELETED: Removed _buildImagesAndBudgetSection (was Row with two children)
  // Widget _buildImagesAndBudgetSection() { ... }

  // DELETED: Removed _buildBudgetField entirely
  // Widget _buildBudgetField() { ... }

  // NEW: Modified images section to take full width
  Widget _buildImagesSectionFullWidth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image_outlined,
              size: 18,
              color: Color(AppColors.primaryColor),
            ),
            const SizedBox(width: 6),
            Text(
              "صور المشكلة",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(AppColors.primaryColor),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "(اختياري)",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.normal,
              ),
            ),
            const Spacer(),
            Text(
              "${_selectedImages.length}/5",
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100, // Slightly increased height for better visibility
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100, // Slightly wider for better touch target
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(AppColors.cardsColor),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "إضافة",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedService == null ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppColors.primaryColor),
          disabledBackgroundColor: Color(
            AppColors.primaryColor,
          ).withOpacity(0.4),
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
    );
  }

  void _submitRequest() async {
    if (!_validateForm()) return;

    // ✅ إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // تحويل الصور إلى مسارات
      List<String> imagePaths = _selectedImages.map((img) => img.path).toList();

      // DELETED: Removed budget from the request creation
      // استدعاء الـ Cubit لإنشاء الطلب
      await context.read<ServiceRequestCubit>().createServiceRequest(
        description: _descController.text.trim(),
        serviceId: selectedService!.id!,
        // budget: double.parse(_budgetController.text.trim()), // DELETED: Removed budget parameter
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        locationAddress: _selectedAddress,
        imagePaths: imagePaths.isNotEmpty ? imagePaths : null, budget: 0,
      );

      // إغلاق مؤشر التحميل
      if (mounted) Navigator.pop(context);

      // عرض رسالة نجاح
      if (mounted) {
        SnackBarHelper.showSuccessSnackBar(context, "تم إرسال الطلب بنجاح");
      }

      // ✅ تنظيف النموذج
      setState(() {
        selectedService = null;
        _descController.clear();
        // _budgetController.clear(); // DELETED: Removed budget controller clear
        _selectedImages.clear();
        _selectedAddress = '';
        _selectedLatitude = null;
        _selectedLongitude = null;
        // _priceErrorMessage = null; // DELETED: Removed price error message reset
      });

      // ✅ الانتظار ثانيتين
      await Future.delayed(const Duration(seconds: 2));

      // ✅ الرجوع للـ Home (الـ TabBar)
      if (mounted) {
        // لو كنت داخل الـ QuickRequestPage في TabBar، استخدم هذه الطريقة
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (mounted) Navigator.pop(context);

      // عرض رسالة خطأ
      if (mounted) {
        SnackBarHelper.showErrorSnackBar(context, "فشل إرسال الطلب: ${e.toString()}");
      }
    }
  }
}