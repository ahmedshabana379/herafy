import 'dart:io'; // مهم عشان ملفات الصور
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/components/app_button.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:image_picker/image_picker.dart'; // تأكد من وجودها في pubspec
import 'package:herafy/core/components/custom_text_field.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:herafy/features/auth/cubits/auth_cubit.dart';
import 'package:herafy/features/auth/cubits/auth_state.dart';
import 'package:herafy/features/auth/models/user_model.dart';
import 'package:herafy/core/components/text-field-label.dart';

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
  UserModel? _user;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await CacheHelper.getUserData();
      setState(() {
        _user = userData;
        _isLoadingUser = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

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

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
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
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        : (_user?.pictureUrl != null
                                  ? NetworkImage(_user!.pictureUrl!)
                                  : null)
                              as ImageProvider?,
                    child: _imageFile == null && _user?.pictureUrl == null
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
          Text(
            _user?.fullName ?? 'المستخدم',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
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
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            _oldPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Center(
                  child: Text('تم تغيير كلمة المرور بنجاح'),
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ChangePasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text(state.message)),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
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
              TextFieldLabel(title: "كلمة المرور الحالية"),
              CustomTextField(
                isPassword: true,
                hintText: 'كلمة المرور الحالية',
                icon: Icons.lock_outline,
                controller: _oldPasswordController,
                validator: (v) =>
                    v!.isEmpty ? 'يرجى إدخال كلمة المرور القديمة' : null,
              ),
              const SizedBox(height: 16),
              TextFieldLabel(title: "كلمة المرور الجديدة"),
              CustomTextField(
                isPassword: true,
                hintText: 'كلمة المرور الجديدة',
                icon: Icons.lock_open,
                controller: _newPasswordController,
                validator: (v) =>
                    v!.length < 6 ? 'كلمة المرور ضعيفة جداً' : null,
              ),
              const SizedBox(height: 16),
              TextFieldLabel(title: "تأكيد كلمة المرور"),
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
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return AppButton(
                    onPressed: _changePassword,
                    isButtonEnabled: state is! ChangePasswordLoading,
                    text: 'حفظ كلمة المرور الجديدة',
                    buttonText: "",
                    isLoading: state is ChangePasswordLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
