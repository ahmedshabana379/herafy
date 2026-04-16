import 'package:herafy/features/home/models/live_location_model.dart';
import 'package:herafy/features/home/models/review_model.dart';
import 'package:herafy/features/home/models/service_request_model.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/models/request_model.dart';

// Service Requests States
abstract class ServiceRequestState {}

class ServiceRequestInitial extends ServiceRequestState {}

// Create Service Request
class CreateServiceRequestLoading extends ServiceRequestState {}

class CreateServiceRequestSuccess extends ServiceRequestState {
  final ServiceRequestModel serviceRequest;
  CreateServiceRequestSuccess(this.serviceRequest);
}

class CreateServiceRequestError extends ServiceRequestState {
  final String error;
  CreateServiceRequestError(this.error);
}

// Get Client Service Requests
class GetClientServiceRequestsLoading extends ServiceRequestState {}

class GetClientServiceRequestsSuccess extends ServiceRequestState {
  final List<ServiceRequestModel> requests;
  GetClientServiceRequestsSuccess(this.requests);
}

class GetClientServiceRequestsError extends ServiceRequestState {
  final String error;
  GetClientServiceRequestsError(this.error);
}

class GetProviderAvailableRequestsLoading extends ServiceRequestState {}

class GetProviderAvailableRequestsSuccess extends ServiceRequestState {
  final List<ServiceRequestModelProvider> requests;
  GetProviderAvailableRequestsSuccess(this.requests);
}

class GetProviderAvailableRequestsError extends ServiceRequestState {
  final String message;
  GetProviderAvailableRequestsError(this.message);
}

// Get Provider Assigned Service Requests
class GetProviderAssignedRequestsLoading extends ServiceRequestState {}

class GetProviderAssignedRequestsSuccess extends ServiceRequestState {
  final List<ServiceRequestModel> requests;
  GetProviderAssignedRequestsSuccess(this.requests);
}

class GetProviderAssignedRequestsError extends ServiceRequestState {
  final String error;
  GetProviderAssignedRequestsError(this.error);
}

// Assign Service Request (Client)
class AssignServiceRequestLoading extends ServiceRequestState {}

class AssignServiceRequestSuccess extends ServiceRequestState {
  final ServiceRequestModel serviceRequest;
  AssignServiceRequestSuccess(this.serviceRequest);
}

class AssignServiceRequestError extends ServiceRequestState {
  final String error;
  AssignServiceRequestError(this.error);
}

// Accept Service Request (Provider)
class AcceptServiceRequestLoading extends ServiceRequestState {}

class AcceptServiceRequestSuccess extends ServiceRequestState {
  final ServiceRequestModel serviceRequest;
  AcceptServiceRequestSuccess(this.serviceRequest);
}

class AcceptServiceRequestError extends ServiceRequestState {
  final String error;
  AcceptServiceRequestError(this.error);
}

// Set Service Request Code (Client)
class SetServiceRequestCodeLoading extends ServiceRequestState {}

class SetServiceRequestCodeSuccess extends ServiceRequestState {}

class SetServiceRequestCodeError extends ServiceRequestState {
  final String error;
  SetServiceRequestCodeError(this.error);
}

// Request Offers States
class GetRequestOffersLoading extends ServiceRequestState {}

class GetRequestOffersSuccess extends ServiceRequestState {
  final List<RequestOfferModel> offers;
  GetRequestOffersSuccess(this.offers);
}

class GetRequestOffersError extends ServiceRequestState {
  final String error;
  GetRequestOffersError(this.error);
}

// Create Request Offer
class CreateRequestOfferLoading extends ServiceRequestState {}

class CreateRequestOfferSuccess extends ServiceRequestState {
  final RequestOfferModel offer;
  CreateRequestOfferSuccess(this.offer);
}

class CreateRequestOfferError extends ServiceRequestState {
  final String error;
  CreateRequestOfferError(this.error);
}

// Update Request Offer
class UpdateRequestOfferLoading extends ServiceRequestState {}

class UpdateRequestOfferSuccess extends ServiceRequestState {
  final RequestOfferModel offer;
  UpdateRequestOfferSuccess(this.offer);
}

class UpdateRequestOfferError extends ServiceRequestState {
  final String error;
  UpdateRequestOfferError(this.error);
}

// Delete Service Request
class DeleteServiceRequestLoading extends ServiceRequestState {}

class DeleteServiceRequestSuccess extends ServiceRequestState {}

class DeleteServiceRequestError extends ServiceRequestState {
  final String error;
  DeleteServiceRequestError(this.error);
}

// ============ Check Offer Status States ============

class CheckOfferStatusInitial extends ServiceRequestState {}

class CheckOfferStatusLoading extends ServiceRequestState {}

class CheckOfferStatusSuccess extends ServiceRequestState {
  final String status; // Pending, Accepted, Rejected
  CheckOfferStatusSuccess(this.status);
}

class CheckOfferStatusError extends ServiceRequestState {
  final String message;
  CheckOfferStatusError(this.message);
}

// ============ Offer Status Checked (للاستخدام داخل الـ Cubit) ============
class OfferStatusChecked extends ServiceRequestState {
  final String status;
  OfferStatusChecked(this.status);
}

// ============ Update Request Status States ============

class UpdateRequestStatusInitial extends ServiceRequestState {}

class UpdateRequestStatusLoading extends ServiceRequestState {}

class UpdateRequestStatusSuccess extends ServiceRequestState {}

class UpdateRequestStatusError extends ServiceRequestState {
  final String message;
  UpdateRequestStatusError(this.message);
}

// ============ Live Location States ============
class UpdateLiveLocationLoading extends ServiceRequestState {}
class UpdateLiveLocationSuccess extends ServiceRequestState {}
class UpdateLiveLocationError extends ServiceRequestState {
  final String message;
  UpdateLiveLocationError(this.message);
}

class GetLiveLocationLoading extends ServiceRequestState {}
class GetLiveLocationSuccess extends ServiceRequestState {
  final LiveLocationResponseModel location;
  GetLiveLocationSuccess(this.location);
}
class GetLiveLocationError extends ServiceRequestState {
  final String message;
  GetLiveLocationError(this.message);
}

// ============ Review States ============
class CreateReviewLoading extends ServiceRequestState {}
class CreateReviewSuccess extends ServiceRequestState {
  final ReviewResponseModel review;
  CreateReviewSuccess(this.review);
}
class CreateReviewError extends ServiceRequestState {
  final String message;
  CreateReviewError(this.message);
}