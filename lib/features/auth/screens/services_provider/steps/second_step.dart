import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/components/section_header.dart';
import 'package:herafy/core/components/text-field-label.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/models/gov_and_regions_model.dart';
import 'package:herafy/features/auth/models/services_model.dart';
import 'package:herafy/features/auth/screens/waiting_approve_page.dart';
import 'package:image_picker/image_picker.dart';

class SecondRegisterationStep extends StatefulWidget {
  const SecondRegisterationStep({
    required this.onProgressChanged,
    super.key,
    this.onBack,
  });
  final VoidCallback? onBack;
  final Function(double) onProgressChanged;
  @override
  State<SecondRegisterationStep> createState() =>
      _SecondRegisterationStepState();
}

class _SecondRegisterationStepState extends State<SecondRegisterationStep> {
  String? selectedSubCategory;
  String? selectedMainCategory;
  File? _idCardImage;
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegionModel? selectedRegion;
  GovernorateModel? selectedGovernorate;

  void _calculateProgress() {
    int filled = 0;
    const int total = 10;

    filled += 4;

    if (selectedMainCategory != null) filled++;
    if (selectedGovernorate != null) filled++;
    if (selectedRegion != null) filled++;
    if (_rangeController.text.isNotEmpty) filled++;
    if (_addressController.text.isNotEmpty) filled++;
    if (_idCardImage != null) filled++;

    widget.onProgressChanged(filled / total);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _idCardImage = File(image.path);
      });
      _calculateProgress();
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getGovernatesData();
    context.read<AuthCubit>().getServicesData();
    _rangeController.addListener(_calculateProgress);
    _addressController.addListener(_calculateProgress);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            SectionHeader(icon: Icons.work_outline, title: "المهنة والموقع"),
            TextFieldLabel(title: "اختر المهنة الرئيسية"),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  current is GetServicesSuccess ||
                  current is GetServicesLoading,
              builder: (context, state) {
                var cubit = context.read<AuthCubit>();

                if (state is GetServicesLoading) {
                  return const LinearProgressIndicator();
                }

                return DropdownButtonFormField<ServiceModel>(
                  initialValue:
                      cubit.services.any((s) => s.name == selectedMainCategory)
                      ? cubit.services.firstWhere(
                          (s) => s.name == selectedMainCategory,
                        )
                      : null,
                  validator: (value) =>
                      value == null ? 'الرجاء اختيار المهنة الرئيسية' : null,
                  items: cubit.services
                      .map(
                        (service) => DropdownMenuItem<ServiceModel>(
                          value: service,
                          child: Text(service.name ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMainCategory = value?.name;
                      selectedSubCategory = null;
                    });
                    cubit.providerCategory = value?.id.toString();
                    _calculateProgress();
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
            SizedBox(height: 10),
            TextFieldLabel(title: "المهنة الفرعية (إختياري)"),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  current is GetServicesSuccess ||
                  current is GetServicesLoading,
              builder: (context, state) {
                var cubit = context.read<AuthCubit>();

                return DropdownButtonFormField<ServiceModel>(
                  initialValue:
                      cubit.services.any((s) => s.name == selectedSubCategory)
                      ? cubit.services.firstWhere(
                          (s) => s.name == selectedSubCategory,
                        )
                      : null,
                  items: cubit.services
                      .where((service) => service.name != selectedMainCategory)
                      .map(
                        (service) => DropdownMenuItem<ServiceModel>(
                          value: service,
                          child: Text(service.name ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubCategory = value?.name;
                    });
                    cubit.providerSubCategory = value?.id.toString();
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
            const Divider(height: 40),
            SectionHeader(
              icon: Icons.location_on_rounded,
              title: "الموقع ونطاق العمل",
            ),
            TextFieldLabel(title: "المحافظة"),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  current is GetRegionsSuccess ||
                  current is GetRegionsLoading ||
                  current is GetRegionsError,
              builder: (context, state) {
                var cubit = context.read<AuthCubit>();

                if (state is GetRegionsLoading) {
                  return LinearProgressIndicator();
                }

                return DropdownButtonFormField<GovernorateModel>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: Text("اختر المحافظة"),
                  items: cubit.governorates
                      .map(
                        (gov) => DropdownMenuItem<GovernorateModel>(
                          value: gov,
                          child: Text(gov.name ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (selectedGov) {
                    setState(() {
                      selectedGovernorate = selectedGov;
                      selectedRegion = null;
                    });
                    cubit.onGovernateSelectedState(selectedGov!);
                    _calculateProgress();
                  },
                );
              },
            ),

            const SizedBox(height: 10),
            TextFieldLabel(title: "المنطقة"),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  current is GovernorateSelectedState ||
                  current is GetRegionsSuccess,
              builder: (context, state) {
                var cubit = context.read<AuthCubit>();
                if (selectedRegion != null &&
                    !cubit.filteredRegions.contains(selectedRegion)) {
                  selectedRegion = null;
                }
                return DropdownButtonFormField<RegionModel>(
                  initialValue: selectedRegion,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: Text("اختر المنطقة"),
                  items: cubit.filteredRegions
                      .map(
                        (region) => DropdownMenuItem(
                          value: region,
                          child: Text(region.name ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedRegion = val;
                    });
                    _calculateProgress();
                    cubit.providerRegionId = val!.id.toString();
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            TextFieldLabel(title: "نطاق العمل (كم)"),
            CustomTextField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال نطاق العمل';
                }
                if (double.tryParse(value) == null) {
                  return 'الرجاء إدخال رقم صالح';
                }
                return null;
              },
              isPassword: false,
              hintText: " 10 كيلومتر  ",
              icon: Icons.map_outlined,
              controller: _rangeController,
            ),
            const SizedBox(height: 10),
            TextFieldLabel(title: "العنوان التفصيلي"),
            CustomTextField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال العنوان التفصيلي';
                }
                return null;
              },
              isPassword: false,
              hintText: "أدخل عنوانك بالتفصيل",
              icon: Icons.home_outlined,
              controller: _addressController,
            ),
            const Divider(height: 40),
            SectionHeader(
              icon: Icons.verified_user_rounded,
              title: "المستندات والتحقق",
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _idCardImage != null
                        ? Color(AppColors.primaryColor)
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: _idCardImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: Color(AppColors.primaryColor),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "اضغط لتحميل صورة بطاقة الهوية",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "(يرجى التأكد من وضوح البيانات)",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.file(
                              _idCardImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "تغيير الصورة",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 30),
            BlocConsumer<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is ProviderRegisterLoading;
                return AppButton(
                  buttonText: "... جاري الإرسال للمراجعة",
                  isLoading: isLoading,
                  isButtonEnabled: !isLoading,
                  text: " إرسال للمراجعة",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_idCardImage == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "تنبية",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'الرجاء تحميل صورة بطاقة الهوية لإكمال التسجيل',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "حسناً",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(AppColors.primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        return;
                      }

                      final cubit = context.read<AuthCubit>();
                      cubit.providerCategory = selectedMainCategory;
                      cubit.providerSubCategory = selectedSubCategory;
                      cubit.providerRange = _rangeController.text;
                      cubit.provideraddress = _addressController.text;
                      cubit.idCardImagePath = _idCardImage!.path;

                      context.read<AuthCubit>().providerRegister();
                    }
                  },
                );
              },
              listener: (context, state) {
                if (state is ProviderRegisterSuccess) {
                  Navigator.pushNamed(context, WaitingApprovePage.routeName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                        child: Text(
                          'تم إرسال بياناتك للمراجعة، سنقوم بالتواصل معك قريباً',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      backgroundColor: Color(AppColors.primaryColor),
                    ),
                  );
                }
                if (state is ProviderRegisterError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(child: Text(state.message)),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
