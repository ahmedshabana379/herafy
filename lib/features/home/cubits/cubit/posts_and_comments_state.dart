abstract class SocialState {}

class SocialInitial extends SocialState {}

// --- Posts States ---
class GetPostsLoading extends SocialState {}
class GetPostsSuccess extends SocialState {}
class GetPostsError extends SocialState {
  final String error;
  GetPostsError(this.error);
}

class CreatePostLoading extends SocialState {}
class CreatePostSuccess extends SocialState {}
class CreatePostError extends SocialState {
  final String error;
  CreatePostError(this.error);
}

// --- Comments States ---
class GetCommentsLoading extends SocialState {}
class GetCommentsSuccess extends SocialState {}
class GetCommentsError extends SocialState {
  final String error;
  GetCommentsError(this.error);
}

class AddCommentLoading extends SocialState {}
class AddCommentSuccess extends SocialState {}
class AddCommentError extends SocialState {
  final String error;
  AddCommentError(this.error);
}

// أضف دول في posts_and_comments_state.dart
class ReactToPostLoading extends SocialState {}
class ReactToPostSuccess extends SocialState {}
class ReactToPostError extends SocialState {
  final String error;
  ReactToPostError(this.error);
}

class ReactToCommentLoading extends SocialState {}
class ReactToCommentSuccess extends SocialState {}
class ReactToCommentError extends SocialState {
  final String error;
  ReactToCommentError(this.error);
}