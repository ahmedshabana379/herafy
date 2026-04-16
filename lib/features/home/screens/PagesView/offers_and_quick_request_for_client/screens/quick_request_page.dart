import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final TextEditingController _budgetController = TextEditingController();
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
  String? _priceErrorMessage;
  int? _minPrice;

  @override
  void initState() {
    super.initState();
    // _budgetController.addListener(_validatePrice);
    // ✅ جلب الخدمات عند تحميل الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().getServicesData();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _budgetController.dispose();
    _searchController.dispose();
    // _budgetController.removeListener(_validatePrice);
    super.dispose();
  }

  // void _validatePrice() {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("من فضلك اختر نوع الخدمة")));
      return false;
    }

    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("من فضلك اكتب وصف للمشكلة")));
      return false;
    }

    if (_budgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("من فضلك ادخل الميزانية")));
      return false;
    }

    if (_priceErrorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_priceErrorMessage!)));
      return false;
    }

    if (_selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك حدد موقعك على الخريطة")),
      );
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

                return DropdownButtonFormField<ServiceModel>(
                  value: selectedService,
                  isExpanded: true,
                  validator: (value) =>
                      value == null ? 'الرجاء اختيار المهنة الرئيسية' : null,
                  items: cubit.services
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
                    // _validatePrice();
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
            _buildImagesAndBudgetSection(),
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

  Widget _buildImagesAndBudgetSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildImagesSection()),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildBudgetField()),
      ],
    );
  }

  Widget _buildImagesSection() {
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
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(AppColors.cardsColor),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 28,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "إضافة",
                          style: TextStyle(
                            fontSize: 9,
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
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
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

  Widget _buildBudgetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_money,
              size: 18,
              color: Color(AppColors.primaryColor),
            ),
            const SizedBox(width: 6),
            Text(
              "الميزانية",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(AppColors.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: "المبلغ",
            suffixText: "ج.م",
            filled: true,
            fillColor: Color(AppColors.cardsColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorText: _priceErrorMessage,
            errorStyle: const TextStyle(fontSize: 10),
          ),
        ),
        // if (selectedService != null && selectedService!.minPrice != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 10, color: Colors.grey[500]),
              const SizedBox(width: 4),
              // Text(
              //   "الحد الأدنى: ${selectedService!.minPrice} ج.م",
              //   style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              // ),
            ],
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

      // استدعاء الـ Cubit لإنشاء الطلب
      await context.read<ServiceRequestCubit>().createServiceRequest(
        description: _descController.text.trim(),
        serviceId: selectedService!.id!,
        budget: double.parse(_budgetController.text.trim()),
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        locationAddress: _selectedAddress,
        imagePaths: imagePaths.isNotEmpty ? imagePaths : null,
      );

      // إغلاق مؤشر التحميل
      if (mounted) Navigator.pop(context);

      // عرض رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text("تم إرسال الطلب بنجاح")),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }

      // ✅ تنظيف النموذج
      setState(() {
        selectedService = null;
        _descController.clear();
        _budgetController.clear();
        _selectedImages.clear();
        _selectedAddress = '';
        _selectedLatitude = null;
        _selectedLongitude = null;
        _priceErrorMessage = null;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text("فشل إرسال الطلب: ${e.toString()}")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
