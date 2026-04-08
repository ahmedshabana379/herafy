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
  Future<void> getPosts({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(GetPostsLoading());
    }
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.getRecentPosts, // استخدمت الـ Constant اللي عندك
      );
      final dynamic payload = response.data;
      List rawList = [];
      if (payload is List) {
        rawList = payload;
      } else if (payload is Map<String, dynamic>) {
        final nested =
            payload['data'] ??
            payload['items'] ??
            payload['posts'] ??
            payload['result'];
        if (nested is List) rawList = nested;
      }

      posts = rawList.map((e) => PostModel.fromJson(e)).toList();

      emit(GetPostsSuccess());
    } catch (error) {
      emit(GetPostsError(error.toString()));
    }
  }

  // 2. إضافة منشور (مع دعم الصور)
  Future<void> createPost({
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

      // تحديث واجهة المستخدم فوراً (Optimistic Update)
      final tempPost = PostModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: trimmedTitle,
        description: trimmedDescription,
        // إفراغ الصورة مؤقتاً لتجنب أخطاء رفع المسار المحلي في Image.network
        images: [],
      );
      posts.insert(0, tempPost);
      emit(GetPostsSuccess());

      await DioHelper.postRequest(
        endPoint: AppEndPoints.addPost,
        data: formData,
      );

      emit(CreatePostSuccess());
      getPosts(isRefresh: true); // تحديث القائمة بعد الإضافة بدون شاشة تحميل
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
  void getComments(int postId, {bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(GetCommentsLoading());
    }
    try {
      final response = await DioHelper.getRequest(
        endPoint:
            "${AppEndPoints.getPostComments}$postId", // دمج الـ ID في الـ URL
      );
      final dynamic payload = response.data;
      List rawList = [];
      if (payload is List) {
        rawList = payload;
      } else if (payload is Map<String, dynamic>) {
        final nested =
            payload['data'] ??
            payload['items'] ??
            payload['comments'] ??
            payload['result'];
        if (nested is List) rawList = nested;
      }

      comments = rawList.map((e) => CommentModel.fromJson(e)).toList();

      emit(GetCommentsSuccess());
    } catch (error) {
      emit(GetCommentsError(error.toString()));
    }
  }

  // 4. إضافة تعليق
  void addComment({required int postId, required String content}) async {
    emit(AddCommentLoading());
    try {
      final text = content.trim();
      if (text.isEmpty) {
        emit(AddCommentError("Comment cannot be empty"));
        return;
      }
      // تحديث واجهة المستخدم فوراً (Optimistic Update)
      final tempComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        postId: postId,
        content: text,
        userName: "أنا", // اسم مبدئي
      );
      comments.add(tempComment);
      emit(GetCommentsSuccess());

      await DioHelper.postRequest(
        endPoint: AppEndPoints.addComment,
        data: {"postId": postId, "content": text},
      );

      getComments(
        postId,
        isRefresh: true,
      ); // تحديث التعليقات من السيرفر بدون شاشة تحميل
      emit(AddCommentSuccess());
    } catch (error) {
      emit(AddCommentError(error.toString()));
    }
  }

  // React على بوست
void reactToPost({required int postId, required int reactionType}) async {
  emit(ReactToPostLoading());
  try {
    await DioHelper.putRequest(
      endPoint: "${AppEndPoints.reactToPost}$postId",
      queryParameters: {"ReactionType": reactionType},
    );
    emit(ReactToPostSuccess());
    getPosts(isRefresh: true);
  } on DioException catch (error) {
    final data = error.response?.data;
    String message = "Failed to react to post";
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    }
    emit(ReactToPostError(message));
  } catch (error) {
    emit(ReactToPostError("Failed to react to post"));
  }
}

// React على كومنت
void reactToComment({required int commentId, required int reactionType}) async {
  emit(ReactToCommentLoading());
  try {
    await DioHelper.putRequest(
      endPoint: "${AppEndPoints.reactToComment}$commentId",
      queryParameters: {"ReactionType": reactionType},
    );
    emit(ReactToCommentSuccess());
  } on DioException catch (error) {
    final data = error.response?.data;
    String message = "Failed to react to comment";
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    }
    emit(ReactToCommentError(message));
  } catch (error) {
    emit(ReactToCommentError("Failed to react to comment"));
  }
}
}
