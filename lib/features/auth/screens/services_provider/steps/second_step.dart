import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
  File? _profileImage;
  File? _idCardImage;
  File? _criminalRecordImage;
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _locationGranted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegionModel? selectedRegion;
  GovernorateModel? selectedGovernorate;

  static const int _stepOneRequiredFields = 5;
  static const int _stepTwoRequiredFields = 8;
  double? _lat;
  double? _lng;
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        SnackBarHelper.showErrorSnackBar(
          context,
          'الرجاء تفعيل الموقع من إعدادات الجهاز',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationGranted = true;
      });

      SnackBarHelper.showSuccessSnackBar(context, 'تم تحديد موقعك بنجاح ✓');
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        context,
        'فشل تحديد الموقع، حاول مرة أخرى',
      );
    }
  }

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
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillGovernorate();
    });
  }

  void _prefillGovernorate() {
    final user = context.read<AuthCubit>().currentUser;
    if (user?.governorateId != null) {
      final cubit = context.read<AuthCubit>();
    }
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
              keyboardType: TextInputType.number,
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
              keyboardType: TextInputType.text,
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
            const SizedBox(height: 10),
            TextFieldLabel(title: "موقعك الحالي"),
            GestureDetector(
              onTap: _getCurrentLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _locationGranted
                      ? const Color(AppColors.primaryColor).withOpacity(0.08)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _locationGranted
                        ? const Color(AppColors.primaryColor)
                        : Colors.grey[300]!,
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _locationGranted
                          ? Icons.location_on
                          : Icons.location_on_outlined,
                      color: _locationGranted
                          ? const Color(AppColors.primaryColor)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _locationGranted
                          ? 'تم تحديد موقعك بنجاح'
                          : 'اضغط لتحديد موقعك',
                      style: TextStyle(
                        color: _locationGranted
                            ? const Color(AppColors.primaryColor)
                            : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_locationGranted)
                      const Icon(
                        Icons.check_circle,
                        color: Color(AppColors.primaryColor),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: buildRequiredImageTile(
                    title: "الهوية",
                    file: _idCardImage,
                    onTap: () =>
                        _pickImage(onSelected: (file) => _idCardImage = file),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildRequiredImageTile(
                    title: "الصورة الشخصية",
                    file: _profileImage,
                    onTap: () =>
                        _pickImage(onSelected: (file) => _profileImage = file),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildRequiredImageTile(
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
                    if (_locationGranted == false) {
                      SnackBarHelper.showErrorSnackBar(
                        context,
                        'الرجاء تحديد موقعك أولاً',
                      );
                      return;
                    }
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
                          latitude: _lat ?? 0.0,
                          longitude: _lng ?? 0.0,
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
}

Widget buildRequiredImageTile({
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



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:herafy/core/components/app_button.dart';
// import 'package:herafy/core/components/custom_text_field.dart';
// import 'package:herafy/core/components/snack_bar_helper.dart';
// import 'package:herafy/core/components/text-field-label.dart';
// import 'package:herafy/core/resourses/app_colors.dart';
// import 'package:herafy/core/services/image_validation_service.dart';
// import 'package:herafy/features/auth/cubits/auth_cubit.dart';
// import 'package:herafy/features/auth/cubits/auth_state.dart';
// import 'package:herafy/features/auth/models/gov_and_regions_model.dart';
// import 'package:herafy/features/auth/models/services_model.dart';
// import 'package:herafy/features/auth/screens/waiting_approve_page.dart';
// import 'package:image_picker/image_picker.dart';

// class SecondRegisterationStep extends StatefulWidget {
//   const SecondRegisterationStep({
//     required this.onProgressChanged,
//     super.key,
//     this.onBack,
//   });

//   final VoidCallback? onBack;
//   final Function(double) onProgressChanged;

//   @override
//   State<SecondRegisterationStep> createState() =>
//       _SecondRegisterationStepState();
// }

// class _SecondRegisterationStepState extends State<SecondRegisterationStep> {
//   String? selectedSubCategory;
//   String? selectedMainCategory;
//   File? _profileImage;
//   File? _idCardImage;
//   File? _criminalRecordImage;
//   final TextEditingController _rangeController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   RegionModel? selectedRegion;
//   GovernorateModel? selectedGovernorate;
//   bool _isValidating = false;

//   static const int _stepOneRequiredFields = 5;
//   static const int _stepTwoRequiredFields = 8;

//   void _calculateProgress() {
//     int stepTwoFilledRequired = 0;
//     if (selectedMainCategory != null) stepTwoFilledRequired++;
//     if (selectedGovernorate != null) stepTwoFilledRequired++;
//     if (selectedRegion != null) stepTwoFilledRequired++;
//     if (_rangeController.text.isNotEmpty) stepTwoFilledRequired++;
//     if (_addressController.text.isNotEmpty) stepTwoFilledRequired++;
//     if (_idCardImage != null) stepTwoFilledRequired++;
//     if (_profileImage != null) stepTwoFilledRequired++;
//     if (_criminalRecordImage != null) stepTwoFilledRequired++;

//     final totalRequired = _stepOneRequiredFields + _stepTwoRequiredFields;
//     final completedRequired = _stepOneRequiredFields + stepTwoFilledRequired;
//     widget.onProgressChanged(completedRequired / totalRequired);
//   }

//   Future<void> _pickImage({
//     required ValueSetter<File> onSelected,
//     required DocumentType documentType,
//     required String fieldName,
//     String? firstName,
//     String? lastName,
//     String? birthDate,
//   }) async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;

//     final file = File(image.path);

//     setState(() => _isValidating = true);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const SizedBox(
//                 width: 18,
//                 height: 18,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text("جاري التحقق من $fieldName..."),
//             ],
//           ),
//           duration: const Duration(seconds: 15),
//           backgroundColor: const Color(AppColors.primaryColor),
//         ),
//       );
//     }

//     final result = await ImageValidationService.validateDocument(
//       imageFile: file,
//       documentType: documentType,
//       firstName: firstName,
//       lastName: lastName,
//       birthDate: birthDate,
//     );

//     if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     setState(() => _isValidating = false);

//     if (!result.isValid) {
//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             title: const Row(
//               children: [
//                 Icon(Icons.error_outline, color: Colors.redAccent),
//                 SizedBox(width: 8),
//                 Text(
//                   "صورة غير صالحة",
//                   style: TextStyle(
//                     color: Colors.redAccent,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             content: Text(
//               result.rejectionReason ?? "الصورة غير واضحة أو غير مناسبة",
//               style: const TextStyle(fontSize: 15),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   "حسناً",
//                   style: TextStyle(
//                     color: Color(AppColors.primaryColor),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//       return;
//     }

//     setState(() => onSelected(file));
//     _calculateProgress();
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("✅ تم قبول الصورة بنجاح"),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     context.read<AuthCubit>().getGovernatesData();
//     context.read<AuthCubit>().getServicesData();
//     _rangeController.addListener(_calculateProgress);
//     _addressController.addListener(_calculateProgress);
//   }

//   @override
//   void dispose() {
//     _rangeController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cubitUser = context.read<AuthCubit>().currentUser;

//     return SingleChildScrollView(
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFieldLabel(title: "اختر المهنة الرئيسية"),
//             BlocBuilder<AuthCubit, AuthState>(
//               buildWhen: (previous, current) =>
//                   current is GetServicesSuccess ||
//                   current is GetServicesLoading,
//               builder: (context, state) {
//                 var cubit = context.read<AuthCubit>();
//                 if (state is GetServicesLoading) {
//                   return const LinearProgressIndicator();
//                 }
//                 return DropdownButtonFormField<ServiceModel>(
//                   initialValue:
//                       cubit.services.any((s) => s.name == selectedMainCategory)
//                       ? cubit.services.firstWhere(
//                           (s) => s.name == selectedMainCategory,
//                         )
//                       : null,
//                   validator: (value) =>
//                       value == null ? 'الرجاء اختيار المهنة الرئيسية' : null,
//                   items: cubit.services
//                       .map(
//                         (service) => DropdownMenuItem<ServiceModel>(
//                           value: service,
//                           child: Text(service.name ?? ""),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedMainCategory = value?.name;
//                       selectedSubCategory = null;
//                     });
//                     cubit.providerCategory = value?.id.toString();
//                     _calculateProgress();
//                   },
//                   hint: const Text("اختر من القائمة"),
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.work_outline),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 10),
//             TextFieldLabel(title: "المهنة الفرعية (إختياري)"),
//             BlocBuilder<AuthCubit, AuthState>(
//               buildWhen: (previous, current) =>
//                   current is GetServicesSuccess ||
//                   current is GetServicesLoading,
//               builder: (context, state) {
//                 var cubit = context.read<AuthCubit>();
//                 return DropdownButtonFormField<ServiceModel>(
//                   initialValue:
//                       cubit.services.any((s) => s.name == selectedSubCategory)
//                       ? cubit.services.firstWhere(
//                           (s) => s.name == selectedSubCategory,
//                         )
//                       : null,
//                   items: cubit.services
//                       .where((service) => service.name != selectedMainCategory)
//                       .map(
//                         (service) => DropdownMenuItem<ServiceModel>(
//                           value: service,
//                           child: Text(service.name ?? ""),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() => selectedSubCategory = value?.name);
//                     cubit.providerSubCategory = value?.id.toString();
//                   },
//                   hint: const Text("اختر من القائمة"),
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.work_outline),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 12),
//             TextFieldLabel(title: "المحافظة"),
//             BlocBuilder<AuthCubit, AuthState>(
//               buildWhen: (previous, current) =>
//                   current is GetRegionsSuccess ||
//                   current is GetRegionsLoading ||
//                   current is GetRegionsError,
//               builder: (context, state) {
//                 var cubit = context.read<AuthCubit>();
//                 if (state is GetRegionsLoading) {
//                   return const LinearProgressIndicator();
//                 }
//                 return DropdownButtonFormField<GovernorateModel>(
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.location_city_outlined),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   hint: const Text("اختر المحافظة"),
//                   items: cubit.governorates
//                       .map(
//                         (gov) => DropdownMenuItem<GovernorateModel>(
//                           value: gov,
//                           child: Text(gov.name ?? ""),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (selectedGov) {
//                     setState(() {
//                       selectedGovernorate = selectedGov;
//                       selectedRegion = null;
//                     });
//                     cubit.onGovernateSelectedState(selectedGov!);
//                     _calculateProgress();
//                   },
//                 );
//               },
//             ),
//             const SizedBox(height: 10),
//             TextFieldLabel(title: "المنطقة"),
//             BlocBuilder<AuthCubit, AuthState>(
//               buildWhen: (previous, current) =>
//                   current is GovernorateSelectedState ||
//                   current is GetRegionsSuccess,
//               builder: (context, state) {
//                 var cubit = context.read<AuthCubit>();
//                 if (selectedRegion != null &&
//                     !cubit.filteredRegions.contains(selectedRegion)) {
//                   selectedRegion = null;
//                 }
//                 return DropdownButtonFormField<RegionModel>(
//                   initialValue: selectedRegion,
//                   decoration: InputDecoration(
//                     prefixIcon: const Icon(Icons.pin_drop_outlined),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   hint: const Text("اختر المنطقة"),
//                   items: cubit.filteredRegions
//                       .map(
//                         (region) => DropdownMenuItem(
//                           value: region,
//                           child: Text(region.name ?? ""),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (val) {
//                     setState(() => selectedRegion = val);
//                     _calculateProgress();
//                     cubit.providerRegionId = val!.id.toString();
//                   },
//                 );
//               },
//             ),
//             const SizedBox(height: 10),
//             TextFieldLabel(title: "نطاق العمل (كم)"),
//             CustomTextField(
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'الرجاء إدخال نطاق العمل';
//                 }
//                 if (double.tryParse(value) == null) {
//                   return 'الرجاء إدخال رقم صالح';
//                 }
//                 return null;
//               },
//               isPassword: false,
//               hintText: "10 كيلومتر",
//               icon: Icons.map_outlined,
//               controller: _rangeController,
//             ),
//             const SizedBox(height: 10),
//             TextFieldLabel(title: "العنوان التفصيلي"),
//             CustomTextField(
//               keyboardType: TextInputType.text,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'الرجاء إدخال العنوان التفصيلي';
//                 }
//                 return null;
//               },
//               isPassword: false,
//               hintText: "أدخل عنوانك بالتفصيل",
//               icon: Icons.home_outlined,
//               controller: _addressController,
//             ),
//             const SizedBox(height: 12),

//             // إشعار التحقق
//             if (_isValidating)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: const Color(AppColors.primaryColor).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Row(
//                   children: [
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                     SizedBox(width: 10),
//                     Text("جاري التحقق من الصورة بالذكاء الاصطناعي..."),
//                   ],
//                 ),
//               ),

//             // Row(
//             //   children: [
//             //     Expanded(
//             //       child: _buildRequiredImageTile(
//             //         title: "الهوية",
//             //         file: _idCardImage,
//             //         onTap: _isValidating
//             //             ? () {}
//             //             : () => _pickImage(
//             //                 onSelected: (file) => _idCardImage = file,
//             //                 documentType: DocumentType.nationalId,
//             //                 fieldName: "الهوية",
//             //                 firstName: cubitUser?.firstName,
//             //                 lastName: cubitUser?.lastName,
//             //                 birthDate: cubitUser?.birthDate,
//             //               ),
//             //       ),
//             //     ),
//             //     const SizedBox(width: 8),
//             //     Expanded(
//             //       child: _buildRequiredImageTile(
//             //         title: "الصورة الشخصية",
//             //         file: _profileImage,
//             //         onTap: _isValidating
//             //             ? () {}
//             //             : () => _pickImage(
//             //                 onSelected: (file) => _profileImage = file,
//             //                 documentType: DocumentType.personalPhoto,
//             //                 fieldName: "الصورة الشخصية",
//             //               ),
//             //       ),
//             //     ),
//             //     const SizedBox(width: 8),
//             //     Expanded(
//             //       child: _buildRequiredImageTile(
//             //         title: "الفيش الجنائي",
//             //         file: _criminalRecordImage,
//             //         onTap: _isValidating
//             //             ? () {}
//             //             : () => _pickImage(
//             //                 onSelected: (file) => _criminalRecordImage = file,
//             //                 documentType: DocumentType.criminalRecord,
//             //                 fieldName: "الفيش الجنائي",
//             //               ),
//             //       ),
//             //     ),
//             //   ],
//             // ),


//             const SizedBox(height: 30),
//             BlocConsumer<AuthCubit, AuthState>(
//               builder: (context, state) {
//                 final isLoading = state is ProviderRegisterLoading;
//                 return AppButton(
//                   buttonText: "... جاري الإرسال للمراجعة",
//                   isLoading: isLoading,
//                   isButtonEnabled: !isLoading && !_isValidating,
//                   text: "إرسال للمراجعة",
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       if (_idCardImage == null ||
//                           _profileImage == null ||
//                           _criminalRecordImage == null) {
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             title: const Row(
//                               children: [
//                                 Icon(
//                                   Icons.warning_amber_rounded,
//                                   color: Colors.redAccent,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   "تنبيه",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.redAccent,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             content: const Text(
//                               'الرجاء تحميل كل الصور المطلوبة لإكمال التسجيل',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: const Text(
//                                   "حسناً",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(AppColors.primaryColor),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                         return;
//                       }

//                       final cubit = context.read<AuthCubit>();
//                       if (selectedGovernorate != null &&
//                           selectedRegion != null) {
//                         cubit.completeProviderRegistration(
//                           governorateId: selectedGovernorate!.id.toString(),
//                           regionId: selectedRegion!.id.toString(),
//                           workRange: _rangeController.text.trim(),
//                           address: _addressController.text.trim(),
//                           serviceIds: [
//                             if (cubit.providerCategory != null)
//                               int.parse(cubit.providerCategory!),
//                             if (cubit.providerSubCategory != null)
//                               int.parse(cubit.providerSubCategory!),
//                           ],
//                           idCardImage: _idCardImage!,
//                           profileImage: _profileImage!,
//                           criminalRecordImage: _criminalRecordImage!,
//                         );
//                       } else {
//                         SnackBarHelper.showErrorSnackBar(
//                           context,
//                           "الرجاء اختيار المحافظة والمنطقة",
//                         );
//                       }
//                     }
//                   },
//                 );
//               },
//               listener: (context, state) {
//                 if (state is ProviderRegisterSuccess) {
//                   Navigator.pushNamed(context, WaitingApprovePage.routeName);
//                   SnackBarHelper.showSuccessSnackBar(
//                     context,
//                     'تم إرسال بياناتك للمراجعة، سنقوم بالتواصل معك قريباً',
//                   );
//                 }
//                 if (state is ProviderRegisterError) {
//                   SnackBarHelper.showErrorSnackBar(context, state.message);
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRequiredImageTile({
//     required String title,
//     required File? file,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 130,
//         decoration: BoxDecoration(
//           color: _isValidating ? Colors.grey[50] : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: file != null
//                 ? const Color(AppColors.primaryColor)
//                 : Colors.grey[300]!,
//             width: 1.4,
//           ),
//         ),
//         child: file == null
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.add_a_photo_outlined,
//                     size: 28,
//                     color: _isValidating
//                         ? Colors.grey
//                         : const Color(AppColors.primaryColor),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     title,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: _isValidating ? Colors.grey : Colors.black,
//                     ),
//                   ),
//                 ],
//               )
//             : Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.file(
//                       file,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                   ),
//                   // علامة صح على الصورة المقبولة
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check,
//                         size: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
