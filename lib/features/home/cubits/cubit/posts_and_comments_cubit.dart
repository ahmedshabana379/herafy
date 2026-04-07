import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/networks/dio_helpers.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/features/home/cubits/cubit/posts_and_comments_state.dart';
import 'package:herafy/features/home/models/comment_model.dart';
import 'package:herafy/features/home/models/post_models.dart'; // تأكد من المسار

class SocialCubit extends Cubit<SocialState> {
  SocialCubit() : super(SocialInitial());

  static SocialCubit get(context) => BlocProvider.of(context);

  List<PostModel> posts = [];
  List<CommentModel> comments = [];

  // 1. جلب المنشورات
  void getPosts() async {
    emit(GetPostsLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.getRecentPosts, // استخدمت الـ Constant اللي عندك
      );

      // الباك أند غالباً بيرجع ليستا جوه حقل اسمه data أو بشكل مباشر
      // لو الليستا راجعة مباشر:
      posts = (response.data as List)
          .map((e) => PostModel.fromJson(e))
          .toList();

      emit(GetPostsSuccess());
    } catch (error) {
      emit(GetPostsError(error.toString()));
    }
  }

  // 2. إضافة منشور (مع دعم الصور)
  void createPost({
    required String title,
    required String description,
    List<File>? images,
  }) async {
    emit(CreatePostLoading());
    try {
      final trimmedTitle = title.trim();
      final trimmedDescription = description.trim();
      final selectedImages = images ?? <File>[];

      if (trimmedTitle.isEmpty) {
        emit(CreatePostError("Title is required"));
        return;
      }

      if (selectedImages.length > 3) {
        emit(CreatePostError("You can upload up to 3 images only"));
        return;
      }

      List<MultipartFile> multipartImages = [];
      for (var image in selectedImages) {
        String fileName = image.path.split('/').last;
        multipartImages.add(
          await MultipartFile.fromFile(image.path, filename: fileName),
        );
      }

      // تجهيز الـ FormData حسب طلب الـ API عندك
      final Map<String, dynamic> formMap = {"Title": trimmedTitle};
      if (trimmedDescription.isNotEmpty) {
        formMap["Description"] = trimmedDescription;
      }
      if (multipartImages.isNotEmpty) {
        formMap["Images"] = multipartImages;
      }
      FormData formData = FormData.fromMap(formMap);

      await DioHelper.postRequest(
        endPoint: AppEndPoints.addPost,
        data: formData,
      );

      getPosts(); // تحديث القائمة بعد الإضافة
      emit(CreatePostSuccess());
    } on DioException catch (error) {
      final data = error.response?.data;
      String message = "Failed to create post";
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }
      emit(CreatePostError(message));
    } catch (error) {
      emit(CreatePostError("Failed to create post"));
    }
  }

  // 3. جلب تعليقات منشور معين
  void getComments(int postId) async {
    emit(GetCommentsLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint:
            "${AppEndPoints.getPostComments}$postId", // دمج الـ ID في الـ URL
      );

      comments = (response.data as List)
          .map((e) => CommentModel.fromJson(e))
          .toList();

      emit(GetCommentsSuccess());
    } catch (error) {
      emit(GetCommentsError(error.toString()));
    }
  }

  // 4. إضافة تعليق
  void addComment({required int postId, required String content}) async {
    emit(AddCommentLoading());
    try {
      await DioHelper.postRequest(
        endPoint: AppEndPoints.addComment,
        data: {"postId": postId, "content": content},
      );

      getComments(postId); // تحديث التعليقات فوراً
      emit(AddCommentSuccess());
    } catch (error) {
      emit(AddCommentError(error.toString()));
    }
  }
}
