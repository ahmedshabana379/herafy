import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/home/screens/PagesView/offers_and_quick_request_for_client/widgets/map_picker_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';

class QuickRequestPage extends StatefulWidget {
  const QuickRequestPage({super.key, this.scrollController});
  final ScrollController? scrollController;

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
  String? selectedService;
  String _searchQuery = '';
  
  // Location variables (يحددها المستخدم من الخريطة)
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedAddress = '';
  
  // Images
  List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Price validation
  String? _priceErrorMessage;
  int? _minPrice;

  // Services list with min prices
  final Map<String, int> _serviceMinPrices = {
    "سباك": 150,
    "كهربائي": 200,
    "نجار": 250,
    "نقاش": 300,
    "فني تكييف": 350,
    "بناء": 400,
    "فني سيراميك": 200,
    "حداد": 250,
    "فني جبس": 300,
    "فني ألمونيوم": 200,
    "مقاول": 500,
    "فني صرف": 150,
  };

  final List<Color> _cardColors = [
    const Color(0xFF6C63FF),
    const Color(0xFF3ECFCF),
    const Color(0xFFFF6584),
    const Color(0xFFFFAA5A),
    const Color(0xFF43C59E),
    const Color(0xFF5B8DEF),
    const Color(0xFFFF7EB3),
    const Color(0xFF9B59B6),
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
  void initState() {
    super.initState();
    _budgetController.addListener(_validatePrice);
  }

  @override
  void dispose() {
    _descController.dispose();
    _budgetController.dispose();
    _searchController.dispose();
    _budgetController.removeListener(_validatePrice);
    super.dispose();
  }

  // Toggle service selection (select/deselect)
  void _onServiceSelected(String serviceName) {
    setState(() {
      if (selectedService == serviceName) {
        selectedService = null;
        _minPrice = null;
      } else {
        selectedService = serviceName;
        _minPrice = _serviceMinPrices[serviceName];
      }
    });
    _validatePrice();
  }

  // AI Price Validation
  void _validatePrice() {
    final String priceText = _budgetController.text;
    if (priceText.isEmpty) {
      setState(() {
        _priceErrorMessage = null;
      });
      return;
    }

    final int? price = int.tryParse(priceText);
    if (price == null) {
      setState(() {
        _priceErrorMessage = "من فضلك أدخل رقم صحيح";
      });
      return;
    }

    if (selectedService != null && _serviceMinPrices.containsKey(selectedService)) {
      _minPrice = _serviceMinPrices[selectedService!];
      if (price < _minPrice!) {
        setState(() {
          _priceErrorMessage = "الحد الأدنى لخدمة ${selectedService!} هو $_minPrice ج.م";
        });
      } else {
        setState(() {
          _priceErrorMessage = null;
        });
      }
    } else {
      setState(() {
        _priceErrorMessage = null;
      });
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLatitude: _selectedLatitude ?? 30.0444,
          initialLongitude: _selectedLongitude ?? 31.2357,
          useCurrentLocation: true, // يسمح باستخدام الموقع الحالي
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _selectedAddress = result['address'];
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك اختر نوع الخدمة")),
      );
      return false;
    }
    
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك اكتب وصف للمشكلة")),
      );
      return false;
    }
    
    if (_budgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك ادخل الميزانية")),
      );
      return false;
    }
    
    if (_priceErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_priceErrorMessage!)),
      );
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

  void _submitRequest() {
    if (!_validateForm()) return;
    
    print("=== طلب جديد ===");
    print("الخدمة: $selectedService");
    print("الوصف: ${_descController.text}");
    print("الميزانية: ${_budgetController.text}");
    print("الموقع: $_selectedAddress");
    print("الإحداثيات: $_selectedLatitude, $_selectedLongitude");
    print("عدد الصور: ${_selectedImages.length}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم إرسال الطلب بنجاح"),
        backgroundColor: Colors.green,
      ),
    );
    
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
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(AppColors.primaryColor),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            "*",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
        if (!isRequired) ...[
          const SizedBox(width: 4),
          Text(
            "(اختياري)",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ],
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
            _buildSectionTitle("اختر نوع الخدمة", isRequired: true),
            const SizedBox(height: 12),
            _buildServicesGrid(),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildSectionTitle("وصف المشكلة", isRequired: true),
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
    );
  }

  Widget _buildServicesGrid() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "مفيش خدمة بالاسم ده",
            style: TextStyle(color: Color(AppColors.secondaryColor)),
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_filteredServices.length, (index) {
        final service = _filteredServices[index];
        final color = _cardColors[index % _cardColors.length];
        final isSelected = selectedService == service["name"];

        return GestureDetector(
          onTap: () => _onServiceSelected(service["name"]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
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
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, size: 14, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      }),
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
              const SizedBox(width: 4),
              Text(
                "*",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
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
                          _selectedAddress.isNotEmpty ? _selectedAddress : "اضغط لتحديد موقعك على الخريطة",
                          style: TextStyle(
                            color: _selectedAddress.isNotEmpty ? Colors.black : Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedLatitude != null)
                          Text(
                            "${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}",
                            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
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
        Expanded(
          flex: 3,
          child: _buildImagesSection(),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildBudgetField(),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image_outlined, size: 18, color: Color(AppColors.primaryColor)),
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
                        Icon(Icons.add_photo_alternate_outlined, 
                          size: 28, color: Colors.grey[400]),
                        const SizedBox(height: 2),
                        Text(
                          "إضافة",
                          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
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
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
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
            Icon(Icons.attach_money, size: 18, color: Color(AppColors.primaryColor)),
            const SizedBox(width: 6),
            Text(
              "الميزانية",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(AppColors.primaryColor),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "*",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
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
        if (selectedService != null && _minPrice != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 10, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  "الحد الأدنى: $_minPrice ج.م",
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                ),
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
          disabledBackgroundColor: Color(AppColors.primaryColor).withOpacity(0.4),
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
}