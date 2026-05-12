import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/models/gov_and_regions_model.dart';
import 'package:herafy/features/auth/screens/services_provider/provider_register_page.dart';
import 'package:herafy/features/home/screens/home_main.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/snack_bar_helper.dart';
import '../../../../core/resourses/app_colors.dart';

class CompleteDataScreen extends StatefulWidget {
  const CompleteDataScreen({super.key});
  static const routeName = "CompleteData";

  @override
  State<CompleteDataScreen> createState() => _CompleteDataScreenState();
}

class _CompleteDataScreenState extends State<CompleteDataScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  DateTime? _selectedDate;
  String _selectedGender = "ذكر";

  // المتغيرات اللي هتاخد الداتا من الـ API
  GovernorateModel? selectedGovernorate;
  RegionModel? selectedRegion;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? "");
    _lastNameController = TextEditingController(text: user?.lastName ?? "");
    _phoneController = TextEditingController(text: user?.phoneNumber ?? "");
    if (user != null && user.status != 0 && user.isProfileComplete == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, HomePage.routeName);
      });
      return;
    }
    context.read<AuthCubit>().getGovernatesData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            "المعلومات الشخصية",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is UpdateProfileSuccess) {
              SnackBarHelper.showSuccessSnackBar(
                context,
                "تم حفظ البيانات بنجاح",
              );

              final user = context.read<AuthCubit>().currentUser;

              if (user?.isProvider == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProviderRegisterPage(startFromSecondStep: true),
                  ),
                );
              } else {
                Navigator.pushReplacementNamed(context, HomePage.routeName);
              }
            } else if (state is UpdateProfileError) {
              SnackBarHelper.showErrorSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            var cubit = context.read<AuthCubit>();

            // لوجيك الـ Fetch: بنعمل Match للمحافظة والمنطقة بتوع اليوزر الحالي
            if (selectedGovernorate == null && cubit.governorates.isNotEmpty) {
              selectedGovernorate = cubit.governorates.firstWhereOrNull(
                (gov) => gov.id == cubit.currentUser?.governorateId,
              );
              if (selectedGovernorate != null) {
                cubit.onGovernateSelectedState(selectedGovernorate!);
                selectedRegion = cubit.filteredRegions.firstWhereOrNull(
                  (reg) => reg.id == cubit.currentUser?.regionId,
                );
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileImageSection(cubit),
                    const SizedBox(height: 30),
                    _buildNameFields(),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: "الجنس",
                      hint: "اختر الجنس",
                      value: _selectedGender,
                      items: ["ذكر", "أنثى"],
                      onChanged: (val) =>
                          setState(() => _selectedGender = val!),
                    ),
                    const SizedBox(height: 20),
                    _buildDatePickerField(),
                    const SizedBox(height: 20),

                    // صف المحافظة والمدينة بالداتا الحقيقية
                    Row(
                      children: [
                        Expanded(child: _buildRealRegionDropdown(cubit)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildRealGovDropdown(cubit)),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildPhoneField(),
                    const SizedBox(height: 40),

                    // الـ AppButton بتاعك باللوجيك المطلوب
                    Center(
                      child: AppButton(
                        text: "إرسال البيانات",
                        buttonText: "جاري إرسال البيانات...",
                        isLoading: state is UpdateProfileLoading,
                        isButtonEnabled: true,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            cubit.updateUserProfile(
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              gender: _selectedGender == "ذكر" ? 0 : 1,
                              governorateId: selectedGovernorate?.id ?? 0,
                              regionId: selectedRegion?.id ?? 0,
                              profileImage: _profileImage,
                              birthDate: _selectedDate,
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Widgets مساعدة ---

  Widget _buildProfileImageSection(AuthCubit cubit) {
    return Center(
      child: Column(
        children: [
          const Text(
            "صورة الملف الشخصي",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[100],
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (cubit.currentUser?.pictureUrl != null
                              ? NetworkImage(cubit.currentUser!.pictureUrl!)
                              : null)
                          as ImageProvider?,
                child:
                    _profileImage == null &&
                        cubit.currentUser?.pictureUrl == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(AppColors.primaryColor),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "يفضل استخدام صورة مربعة بحجم 400x400 بكسل على الأقل",
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRealGovDropdown(AuthCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "المحافظة",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<GovernorateModel>(
              value: selectedGovernorate,
              hint: const Text("اختر المحافظة", style: TextStyle(fontSize: 14)),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              items: cubit.governorates
                  .map(
                    (gov) => DropdownMenuItem(
                      value: gov,
                      child: Text(
                        gov.name ?? "",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedGovernorate = val;
                  selectedRegion = null;
                });
                cubit.onGovernateSelectedState(val!);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealRegionDropdown(AuthCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "المدينة",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RegionModel>(
              value: selectedRegion,
              hint: const Text("اختر المدينة", style: TextStyle(fontSize: 14)),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              items: cubit.filteredRegions
                  .map(
                    (region) => DropdownMenuItem(
                      value: region,
                      child: Text(
                        region.name ?? "",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedRegion = val),
            ),
          ),
        ),
      ],
    );
  }

  // الـ Widgets الباقية بنفس ديزاينك بالظبط
  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: _CustomTextFormField(
            controller: _lastNameController,
            label: "اسم العائلة",
            hint: "أدخل اسم العائلة",
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _CustomTextFormField(
            controller: _firstNameController,
            label: "الاسم الأول",
            hint: "أدخل اسمك الأول",
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    String formattedDate = _selectedDate == null
        ? "اختر تاريخ الميلاد"
        : "${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "تاريخ الميلاد",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: _selectedDate == null
                        ? Colors.grey[400]
                        : Colors.black,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _CustomTextFormField(
      controller: _phoneController,
      label: "أرقام الهاتف",
      hint: "أدخل رقم الهاتف",
      keyboardType: TextInputType.phone,
      suffixIcon: Icon(Icons.phone_outlined, color: Colors.grey[400], size: 20),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
              items: items
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _CustomTextFormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(AppColors.primaryColor)),
            ),
          ),
        ),
      ],
    );
  }
}
