class AppEndPoints {
  static const baseUrl = "https://iti-final-project.runasp.net/api/";
  static const login = "Account/login";
  static const register = "Account/register";
  static const regionsAndGavernates = "Governorate/GovernorateWithRegions";
  static const services = "Services/get-services";
  static const String logout = 'Account/logout';
  static const String changePassword = 'Account/change-password';
  static const String completeProviderProfile = 'Provider/complete-profile';
  // --- Posts Endpoints ---
  // لجلب أحدث المنشورات (بيدعم Pagination وفلتر بالبحث أو المكان)
  static const String getRecentPosts = "Post/get-recent-posts";

  // إضافة منشور جديد (محتاج Title و Description و Images)
  static const String addPost = "Post/add-post";

  // مسح منشور خاص بالمستخدم
  static const String deletePost = "Post/delete-post/"; // ضيف الـ ID في الآخر

  // التفاعل مع المنشور (Like/React)
  static const String reactToPost =
      "PostReaction/react-to-post/"; // ضيف الـ ID في الآخر

  // --- Comments Endpoints ---
  // عرض تعليقات منشور معين
  static const String getPostComments =
      "Comment/get-post-comments/"; // ضيف الـ ID في الآخر

  // إضافة تعليق جديد
  static const String addComment = "Comment/add-comment";

  // مسح تعليق
  static const String deleteComment =
      "Comment/delete-comment/"; // ضيف الـ ID في الآخر

  // التفاعل مع تعليق معين
  static const String reactToComment =
      "CommentReaction/react-to-comment/"; // ضيف الـ ID في الآخر

  static const String updateProviderProfile =
      "Provider/update-provider-profile";
  static const String uploadDocument = "Document/upload-document";
}
