import 'dart:io'; // مهم عشان ملفات الصور
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // تأكد من وجودها في pubspec
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});
  static const routeName = "EditAccount";

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _imageFile; // تغيير من String لـ File
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ميثود فتح الاستوديو (زي رفع البطاقة)
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // لتقليل مساحة الصورة
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // هنا هتربط الـ API لاحقاً
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ التغييرات بنجاح'),
          backgroundColor: Color(AppColors.primaryColor),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // خلفية فاتحة تظهر الكروت
      appBar: AppBar(
        title: const Text(
          'تعديل الحساب',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(AppColors.primaryColor),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildPasswordForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Color(AppColors.primaryColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Color(AppColors.cardsColor),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? Icon(
                            Icons.person_outline,
                            size: 50,
                            color: Color(AppColors.primaryColor),
                          )
                        : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Color(AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'أحمد شبانة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Color(AppColors.primaryColor),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تغيير كلمة المرور',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              isPassword: true,
              hintText: 'كلمة المرور الحالية',
              icon: Icons.lock_outline,
              controller: _oldPasswordController,
              validator: (v) => v!.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              isPassword: true,
              hintText: 'كلمة المرور الجديدة',
              icon: Icons.lock_open,
              controller: _newPasswordController,
              validator: (v) => v!.length < 6 ? 'كلمة المرور ضعيفة' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              isPassword: true,
              hintText: 'تأكيد كلمة المرور',
              icon: Icons.lock,
              controller: _confirmPasswordController,
              validator: (v) => v != _newPasswordController.text
                  ? 'كلمات المرور غير متطابقة'
                  : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primaryColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'حفظ التغييرات الجديدة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
