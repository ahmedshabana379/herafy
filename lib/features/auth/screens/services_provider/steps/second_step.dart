import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/components/section_header.dart';
import 'package:herafy/core/components/text-field-label.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/core/resourses/constants.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/screens/waiting_approve_page.dart';
import 'package:image_picker/image_picker.dart';

class SecondRegisterationStep extends StatefulWidget {
  const SecondRegisterationStep({super.key, this.onBack});
  final VoidCallback? onBack;
  @override
  State<SecondRegisterationStep> createState() =>
      _SecondRegisterationStepState();
}

class _SecondRegisterationStepState extends State<SecondRegisterationStep> {
  String? selectedSubCategory;
  String? selectedMainCategory;
  File? _idCardImage;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _idCardImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            BuildSectionHeader(Icons.work_outline, "المهنة والموقع"),
            TextFieldLabel(title: "اختر المهنة الرئيسية"),
            DropdownButtonFormField<String>(
              validator: (value) =>
                  value == null ? 'الرجاء اختيار المهنة الرئيسية' : null,
              items: herafyCategories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                selectedMainCategory = value;
                selectedSubCategory = null;
              }),
              initialValue: selectedMainCategory,
              hint: Text("اختر من القائمة"),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFieldLabel(title: "المهنة الفرعية (إختياري)"),
            DropdownButtonFormField<String>(
              items: herafyCategories
                  .where((category) => category != selectedMainCategory)
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                selectedSubCategory = value;
              }),
              initialValue: selectedSubCategory,
              hint: Text("اختر من القائمة"),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Divider(height: 40),
            BuildSectionHeader(Icons.location_on_rounded, "الموقع ونطاق العمل"),
            TextFieldLabel(title: "المدينة"),
            CustomTextField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المدينة';
                }
                return null;
              },
              isPassword: false,
              hintText: "أدخل مدينتك",
              icon: Icons.location_city_outlined,
              controller: _cityController,
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
            BuildSectionHeader(
              Icons.verified_user_rounded,
              "المستندات والتحقق",
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
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Center(child: Text('الرجاء تحميل صورة بطاقة الهوية')),
                        //     backgroundColor: Colors.redAccent,
                        //   ),
                        // );
                        return;
                      }

                      final cubit = context.read<AuthCubit>();
                      cubit.providerCategory = selectedMainCategory;
                      cubit.providerSubCategory = selectedSubCategory;
                      cubit.providerCity = _cityController.text;
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
                      backgroundColor: Colors.green,
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
