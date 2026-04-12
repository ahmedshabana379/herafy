import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/networks/cache_helper.dart';
import 'package:herafy/core/networks/dio_helpers.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/features/home/cubits/posts_comments/posts_and_comments_state.dart';
import 'package:herafy/features/home/models/comment_model.dart';
import 'package:herafy/features/home/models/post_models.dart'; // تأكد من المسار

class SocialCubit extends Cubit<SocialState> {
  SocialCubit() : super(SocialInitial());

  static SocialCubit get(context) => BlocProvider.of(context);

  List<PostModel> posts = [];
  List<CommentModel> comments = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  // 1. جلب المنشورات
  Future<void> getPosts({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(GetPostsLoading());
      _currentPage = 1;
      _hasMore = true;
    }
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.getRecentPosts,
        query: {"pageIndex": _currentPage, "pageSize": 10},
      );

      final dynamic payload = response.data;
      List rawList = [];
      int totalCount = 0;

      if (payload is Map<String, dynamic>) {
        rawList = payload['data'] ?? [];
        totalCount = payload['count'] ?? 0;
      }

      final newPosts = rawList.map((e) => PostModel.fromJson(e)).toList();

      if (isRefresh) {
        posts = newPosts;
      } else {
        posts = newPosts;
      }

      _hasMore = posts.length < totalCount;

      emit(GetPostsSuccess());
    } catch (error) {
      emit(GetPostsError(error.toString()));
    }
  }

  Future<void> loadMorePosts() async {
    if (_isFetchingMore || !_hasMore) return;
    _isFetchingMore = true;
    emit(GetPostsLoadingMore());

    try {
      _currentPage++;
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.getRecentPosts,
        query: {"pageIndex": _currentPage, "pageSize": 10},
      );

      final dynamic payload = response.data;
      List rawList = [];
      int totalCount = 0;

      if (payload is Map<String, dynamic>) {
        rawList = payload['data'] ?? [];
        totalCount = payload['count'] ?? 0;
      }

      final newPosts = rawList.map((e) => PostModel.fromJson(e)).toList();
      posts.addAll(newPosts);
      _hasMore = posts.length < totalCount;

      emit(GetPostsSuccess());
    } catch (error) {
      _currentPage--;
      emit(GetPostsError(error.toString()));
    } finally {
      _isFetchingMore = false;
    }
  }

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

      emit(CreatePostSuccess());
      await getPosts(isRefresh: true);
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

  void getComments(int postId, {bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(GetCommentsLoading());
    }
    try {
      final response = await DioHelper.getRequest(
        endPoint: "${AppEndPoints.getPostComments}$postId",
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

      comments = rawList.map((e) {
        return CommentModel.fromJson(e);
      }).toList();
      emit(GetCommentsSuccess());
    } catch (error) {
      emit(GetCommentsError(error.toString()));
    }
  }

  void addComment({required int postId, required String content}) async {
    emit(AddCommentLoading());
    try {
      final text = content.trim();
      if (text.isEmpty) {
        emit(AddCommentError("Comment cannot be empty"));
        return;
      }

      final user = await CacheHelper.getUserData();
      String userName = user != null && user.fullName.trim().isNotEmpty
          ? user.fullName
          : "مستخدم";

      if (userName.trim().toLowerCase() == 'user') {
        userName = "مستخدم";
      }

      final tempComment = CommentModel(
        Message: text,
        id: DateTime.now().millisecondsSinceEpoch,
        postId: postId,
        userName: userName,
      );
      comments.add(tempComment);
      emit(GetCommentsSuccess());

      await DioHelper.postRequest(
        endPoint: AppEndPoints.addComment,
        data: {"postId": postId, "message": text},
      );
      getComments(postId, isRefresh: true);
      emit(AddCommentSuccess());
    } catch (error) {
      if (error is DioException) {
        final data = error.response?.data;
        String message = "Failed to add comment";
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else if (data is String && data.isNotEmpty) {
          message = data;
        }
        emit(AddCommentError(message));
      } else {
        emit(AddCommentError("Failed to add comment"));
      }
      emit(AddCommentError(error.toString()));
    }
  }

  // React على بوست
  void reactToPost({required int postId, required int reactionType}) async {
    emit(ReactToPostLoading());
    try {
      await DioHelper.putRequest(
        endPoint: "${AppEndPoints.reactToPost}$postId",
        queryParameters: {
          "reaction": reactionType,
        }, 
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

  void reactToComment({
    required int commentId,
    required int reactionType,
  }) async {
    emit(ReactToCommentLoading());
    try {
      await DioHelper.putRequest(
        endPoint: "${AppEndPoints.reactToComment}$commentId",
        queryParameters: {
          "reaction": reactionType,
        }, // ← reaction مش ReactionType
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

  Future<Map<int, int>> getPostReactions(int postId) async {
    try {
      final response = await DioHelper.getRequest(
        endPoint: "${AppEndPoints.getPostReactions}$postId",
      );
      final data = response.data;
      if (data is Map) {
        return data.map(
          (k, v) => MapEntry(int.tryParse(k.toString()) ?? 0, v as int),
        );
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}
