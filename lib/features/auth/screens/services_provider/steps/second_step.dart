import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/components/snack_bar_helper.dart';
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
  File? _profileImage;
  File? _criminalRecordImage;
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegionModel? selectedRegion;
  GovernorateModel? selectedGovernorate;

  static const int _stepOneRequiredFields = 5;
  static const int _stepTwoRequiredFields = 8;

  void _calculateProgress() {
    int stepTwoFilledRequired = 0;

    if (selectedMainCategory != null) stepTwoFilledRequired++;
    if (selectedGovernorate != null) stepTwoFilledRequired++;
    if (selectedRegion != null) stepTwoFilledRequired++;
    if (_rangeController.text.isNotEmpty) stepTwoFilledRequired++;
    if (_addressController.text.isNotEmpty) stepTwoFilledRequired++;
    if (_idCardImage != null) stepTwoFilledRequired++;
    if (_profileImage != null) stepTwoFilledRequired++;
    if (_criminalRecordImage != null) stepTwoFilledRequired++;

    final totalRequired = _stepOneRequiredFields + _stepTwoRequiredFields;
    final completedRequired = _stepOneRequiredFields + stepTwoFilledRequired;
    widget.onProgressChanged(completedRequired / totalRequired);
  }

  Future<void> _pickImage({required ValueSetter<File> onSelected}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => onSelected(File(image.path)));
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
                    // Optional field should not affect progress.
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildRequiredImageTile(
                    title: "الهوية",
                    file: _idCardImage,
                    onTap: () =>
                        _pickImage(onSelected: (file) => _idCardImage = file),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRequiredImageTile(
                    title: "الصورة الشخصية",
                    file: _profileImage,
                    onTap: () =>
                        _pickImage(onSelected: (file) => _profileImage = file),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRequiredImageTile(
                    title: "الفيش الجنائي",
                    file: _criminalRecordImage,
                    onTap: () => _pickImage(
                      onSelected: (file) => _criminalRecordImage = file,
                    ),
                  ),
                ),
              ],
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
                      if (_idCardImage == null ||
                          _profileImage == null ||
                          _criminalRecordImage == null) {
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
                              'الرجاء تحميل كل الصور المطلوبة لإكمال التسجيل',
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

                      // استدعاء completeProviderRegistration()
                      if (selectedGovernorate != null &&
                          selectedRegion != null) {
                        cubit.completeProviderRegistration(
                          governorateId: selectedGovernorate!.id.toString(),
                          regionId: selectedRegion!.id.toString(),
                          workRange: _rangeController.text.trim(),
                          address: _addressController.text.trim(),
                          serviceIds: [
                            if (cubit.providerCategory != null)
                              int.parse(cubit.providerCategory!),
                            if (cubit.providerSubCategory != null)
                              int.parse(cubit.providerSubCategory!),
                          ],
                          idCardImage: _idCardImage!,
                          profileImage: _profileImage!,
                          criminalRecordImage: _criminalRecordImage!,
                        );
                      } else {
                        SnackBarHelper.showErrorSnackBar(
                          context,
                          "الرجاء اختيار المحافظة والمنطقة",
                        );
                      }
                    }
                  },
                );
              },
              listener: (context, state) {
                if (state is ProviderRegisterSuccess) {
                  Navigator.pushNamed(context, WaitingApprovePage.routeName);
                  SnackBarHelper.showSuccessSnackBar(
                    context,
                    'تم إرسال بياناتك للمراجعة، سنقوم بالتواصل معك قريباً',
                  );
                }
                if (state is ProviderRegisterError) {
                  SnackBarHelper.showErrorSnackBar(context, state.message);
                }
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredImageTile({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null
                ? const Color(AppColors.primaryColor)
                : Colors.grey[300]!,
            width: 1.4,
          ),
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    size: 28,
                    color: Color(AppColors.primaryColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ),
    );
  }
}
