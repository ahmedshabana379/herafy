import 'dart:io';
import 'package:flutter/material.dart';
import 'package:herafy/core/resourses/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  static const routeName = "CreatePost";

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  String? postType; // "service" or "general"

  @override
  void initState() {
    super.initState();
    // بتاخد الـ argument من الـ navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postType = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 80, // ← بتضغط الصور علشان متاخدش space كتير
    );

    if (images.isNotEmpty) {
      setState(() {
        // بتضيف الصور الجديدة على القديمة مش بتبدلها
        _selectedImages.addAll(
          images.map((xFile) => File(xFile.path)).toList(),
        );
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          postType == "service" ? "نشر عرض خدمة" : "مشاركة عامة",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(AppColors.primaryColor),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(AppColors.primaryColor)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // زرار النشر
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: ElevatedButton(
              onPressed: _descController.text.isEmpty && _selectedImages.isEmpty
                  ? null
                  : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.primaryColor),
                disabledBackgroundColor:
                    Color(AppColors.primaryColor).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "نشر",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نوع البوست badge
            if (postType != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: postType == "service"
                      ? Color(AppColors.primaryColor).withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      postType == "service"
                          ? Icons.handyman_rounded
                          : Icons.public,
                      size: 14,
                      color: postType == "service"
                          ? Color(AppColors.primaryColor)
                          : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      postType == "service" ? "عرض خدمة" : "مشاركة عامة",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: postType == "service"
                            ? Color(AppColors.primaryColor)
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // حقل الوصف
            TextField(
              controller: _descController,
              maxLines: 5,
              maxLength: 500,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: postType == "service"
                    ? "اوصف الخدمة اللي بتقدمها..."
                    : "شارك تجربتك أو شغلك مع المجتمع...",
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 15),
                border: InputBorder.none,
                counterStyle:
                    TextStyle(color: Color(AppColors.secondaryColor)),
              ),
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),

            const Divider(),
            const SizedBox(height: 12),

            // الصور المختارة
            if (_selectedImages.isNotEmpty) ...[
              Text(
                "الصور المختارة (${_selectedImages.length})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // زرار حذف الصورة
                        Positioned(
                          top: 4,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
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
              const SizedBox(height: 16),
            ],

            // زرار إضافة صور
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color(AppColors.cardsColor),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(AppColors.primaryColor).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: Color(AppColors.primaryColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedImages.isEmpty
                          ? "أضف صور لمنشورك"
                          : "إضافة المزيد من الصور",
                      style: TextStyle(
                        color: Color(AppColors.primaryColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "يمكنك اختيار أكثر من صورة",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.secondaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}