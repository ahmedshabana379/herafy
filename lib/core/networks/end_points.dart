class AppEndPoints {
  static const baseUrl = "https://iti-final-project.runasp.net/api/";
  static const login = "Account/login";
  static const register = "Account/register";
  static const regionsAndGavernates = "Governorate/GovernorateWithRegions";
  static const services = "Services/get-services";
  static const String logout = 'Account/logout';
  static const String changePassword = 'Account/change-password';
  static const String completeProviderProfile = 'Provider/complete-profile';
  static const String getRecentPosts = "Post/get-recent-posts";
  static const String addPost = "Post/add-post";
  static const String deletePost = "Post/delete-post/";
  static const String reactToPost = "PostReaction/react-to-post/";
  static const String getPostComments = "Comment/get-post-comments/";
  static const String addComment = "Comment/add-comment";
  static const String deleteComment = "Comment/delete-comment/";
  static const String reactToComment = "CommentReaction/react-to-comment/";
  static const String getPostReactions = "PostReaction/post-reactions/";
  static const String getCommentReactions =
      "CommentReaction/comment-reactions/";
  static const String updateProviderProfile =
      "Provider/update-provider-profile";
  static const String uploadDocument = "Document/upload-document";
  static const String updateClientProfile = "Client/update-client-profile";
  // ------------------------------
  // service requests endpoints
  static const String clientCreateServiceRequest =
      "ServiceRequest/create-service-request";
  static const String providerGetAvailableRequests =
      "ServiceRequest/available-requests";
  static const String providerCreateOffer = "RequestOffer/create-offer/";
  static const String providerGetHisOffers = "RequestOffer/my-offers";
  static const String clientGetServiceRequestOffers =
      "RequestOffer/get-request-offers/";
  static const String clientAssignServiceRequestToProvider =
      "ServiceRequest/assign/";
  static const String providerGetAssignedRequests =
      "ServiceRequest/my-assigned-requests";
  static const String providerAcceptServiceRequest = "ServiceRequest/start/";
  static const String getServiceRequestById =
      "ServiceRequest/get-request-byid/";
  static const String clientGetHisServiceRequests =
      "ServiceRequest/my-requests";
  static const String clientSetServiceRequestCompleted =
      "ServiceRequest/complete/";
  static const String clientSetServiceRequestCanceled =
      "ServiceRequest/cancel/";
 static const String getLiveLocation = "LiveLocation/get-live-location/";
 static const String updateLiveLocation = "LiveLocation/update-live-location";
static const String createReview = "Review/create-review";



  static const String geminiApiKey = "AIzaSyA0V6OpCvJQoNuH7l4GCMFqZIA_hVUFF6Q";
}
