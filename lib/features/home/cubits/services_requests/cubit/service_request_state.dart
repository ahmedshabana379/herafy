import 'package:herafy/features/home/models/service_request_model.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';

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

// Get Provider Available Service Requests
class GetProviderAvailableRequestsLoading extends ServiceRequestState {}

class GetProviderAvailableRequestsSuccess extends ServiceRequestState {
  final List<ServiceRequestModel> requests;
  GetProviderAvailableRequestsSuccess(this.requests);
}

class GetProviderAvailableRequestsError extends ServiceRequestState {
  final String error;
  GetProviderAvailableRequestsError(this.error);
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