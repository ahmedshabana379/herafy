import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:herafy/core/networks/dio_helpers.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_state.dart';
import 'package:herafy/features/home/models/service_request_model.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  ServiceRequestCubit() : super(ServiceRequestInitial());

  List<ServiceRequestModel> clientRequests = [];
  List<ServiceRequestModel> providerAvailableRequests = [];
  List<ServiceRequestModel> providerAssignedRequests = [];
  List<RequestOfferModel> requestOffers = [];

  // 1. Create Service Request (Client)
  Future<void> createServiceRequest({
    required String description,
    required int serviceId,
    required double budget,
    required double latitude,
    required double longitude,
    String? locationAddress,
    List<String>? imagePaths,
  }) async {
    emit(CreateServiceRequestLoading());
    try {
      FormData formData = FormData.fromMap({
        'Description': description,
        'ServiceId': serviceId,
        'Budget': budget,
        'Latitude': latitude,
        'Longitude': longitude,
        if (locationAddress != null) 'LocationAddress': locationAddress,
      });

      // إضافة الصور إن وجدت
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (int i = 0; i < imagePaths.length; i++) {
          formData.files.add(
            MapEntry(
              'Images',
              await MultipartFile.fromFile(
                imagePaths[i],
                filename: 'request_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
              ),
            ),
          );
        }
      }

      final response = await DioHelper.postRequest(
        endPoint: AppEndPoints.createServiceRequest,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final request = ServiceRequestModel.fromJson(response.data);
        emit(CreateServiceRequestSuccess(request));
      } else {
        emit(CreateServiceRequestError('فشل إنشاء الطلب'));
      }
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'حدث خطأ في الاتصال';
      emit(CreateServiceRequestError(errorMessage));
    } catch (e) {
      emit(CreateServiceRequestError(e.toString()));
    }
  }

  // 2. Get Client Service Requests
  Future<void> getClientServiceRequests() async {
    emit(GetClientServiceRequestsLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.getClientServiceRequests,
      );

      if (response.statusCode == 200) {
        List<ServiceRequestModel> requests = [];
        if (response.data is List) {
          requests = (response.data as List)
              .map((item) => ServiceRequestModel.fromJson(item))
              .toList();
        }
        clientRequests = requests;
        emit(GetClientServiceRequestsSuccess(requests));
      } else {
        emit(GetClientServiceRequestsError('فشل جلب الطلبات'));
      }
    } on DioException catch (e) {
      emit(GetClientServiceRequestsError(e.message ?? 'حدث خطأ في الاتصال'));
    } catch (e) {
      emit(GetClientServiceRequestsError(e.toString()));
    }
  }

  // 3. Get Provider Available Service Requests
  Future<void> getProviderAvailableRequests() async {
    emit(GetProviderAvailableRequestsLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.getProviderAvailableRequests,
      );

      if (response.statusCode == 200) {
        List<ServiceRequestModel> requests = [];
        if (response.data is List) {
          requests = (response.data as List)
              .map((item) => ServiceRequestModel.fromJson(item))
              .toList();
        }
        providerAvailableRequests = requests;
        emit(GetProviderAvailableRequestsSuccess(requests));
      } else {
        emit(GetProviderAvailableRequestsError('فشل جلب الطلبات'));
      }
    } on DioException catch (e) {
      emit(GetProviderAvailableRequestsError(e.message ?? 'حدث خطأ في الاتصال'));
    } catch (e) {
      emit(GetProviderAvailableRequestsError(e.toString()));
    }
  }

  // 4. Get Provider Assigned Service Requests
  Future<void> getProviderAssignedRequests() async {
    emit(GetProviderAssignedRequestsLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.getProviderAssignedRequests,
      );

      if (response.statusCode == 200) {
        List<ServiceRequestModel> requests = [];
        if (response.data is List) {
          requests = (response.data as List)
              .map((item) => ServiceRequestModel.fromJson(item))
              .toList();
        }
        providerAssignedRequests = requests;
        emit(GetProviderAssignedRequestsSuccess(requests));
      } else {
        emit(GetProviderAssignedRequestsError('فشل جلب الطلبات'));
      }
    } on DioException catch (e) {
      emit(GetProviderAssignedRequestsError(e.message ?? 'حدث خطأ في الاتصال'));
    } catch (e) {
      emit(GetProviderAssignedRequestsError(e.toString()));
    }
  }

  // 5. Client Assign Service Request to Provider
  Future<void> assignServiceRequest({
    required int requestId,
    required int providerId,
  }) async {
    emit(AssignServiceRequestLoading());
    try {
      final response = await DioHelper.putRequest(
        endPoint: '${AppEndPoints.assignServiceRequest}/$requestId',
        data: {'ProviderId': providerId},
      );

      if (response.statusCode == 200) {
        final request = ServiceRequestModel.fromJson(response.data);
        emit(AssignServiceRequestSuccess(request));
        // تحديث القوائم المحلية
        await getClientServiceRequests();
      } else {
        emit(AssignServiceRequestError('فشل تعيين مقدم الخدمة'));
      }
    } on DioException catch (e) {
      emit(AssignServiceRequestError(e.response?.data['message'] ?? 'حدث خطأ'));
    } catch (e) {
      emit(AssignServiceRequestError(e.toString()));
    }
  }

  // 6. Provider Accept Service Request
  Future<void> acceptServiceRequest(int requestId) async {
    emit(AcceptServiceRequestLoading());
    try {
      final response = await DioHelper.putRequest(
        endPoint: '${AppEndPoints.acceptServiceRequest}/$requestId',
        data: {},
      );

      if (response.statusCode == 200) {
        final request = ServiceRequestModel.fromJson(response.data);
        emit(AcceptServiceRequestSuccess(request));
        // تحديث القوائم المحلية
        await getProviderAvailableRequests();
        await getProviderAssignedRequests();
      } else {
        emit(AcceptServiceRequestError('فشل قبول الطلب'));
      }
    } on DioException catch (e) {
      emit(AcceptServiceRequestError(e.response?.data['message'] ?? 'حدث خطأ'));
    } catch (e) {
      emit(AcceptServiceRequestError(e.toString()));
    }
  }

  // 7. Create Request Offer (Provider)
  Future<void> createRequestOffer({
    required int serviceRequestId,
    required double price,
    required String message,
  }) async {
    emit(CreateRequestOfferLoading());
    try {
      final response = await DioHelper.postRequest(
        endPoint: '${AppEndPoints.createRequestOffer}/$serviceRequestId',
        data: {
          'Price': price,
          'Message': message,
        },
      );

      if (response.statusCode == 200) {
        final offer = RequestOfferModel.fromJson(response.data);
        emit(CreateRequestOfferSuccess(offer));
        // جلب العروض مرة أخرى
        await getRequestOffers(serviceRequestId);
      } else {
        emit(CreateRequestOfferError('فشل إنشاء العرض'));
      }
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'حدث خطأ في الاتصال';
      emit(CreateRequestOfferError(errorMessage));
    } catch (e) {
      emit(CreateRequestOfferError(e.toString()));
    }
  }

  // 8. Get Request Offers By Service Request
  Future<void> getRequestOffers(int serviceRequestId) async {
    emit(GetRequestOffersLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: '${AppEndPoints.getRequestOffers}/$serviceRequestId',
      );

      if (response.statusCode == 200) {
        List<RequestOfferModel> offers = [];
        if (response.data is List) {
          offers = (response.data as List)
              .map((item) => RequestOfferModel.fromJson(item))
              .toList();
        }
        requestOffers = offers;
        emit(GetRequestOffersSuccess(offers));
      } else {
        emit(GetRequestOffersError('فشل جلب العروض'));
      }
    } on DioException catch (e) {
      emit(GetRequestOffersError(e.message ?? 'حدث خطأ في الاتصال'));
    } catch (e) {
      emit(GetRequestOffersError(e.toString()));
    }
  }

  // 9. Update Request Offer
  Future<void> updateRequestOffer({
    required int offerId,
    required double price,
    required String message,
  }) async {
    emit(UpdateRequestOfferLoading());
    try {
      final response = await DioHelper.putRequest(
        endPoint: '${AppEndPoints.updateRequestOffer}/$offerId',
        data: {
          'Price': price,
          'Message': message,
        },
      );

      if (response.statusCode == 200) {
        final offer = RequestOfferModel.fromJson(response.data);
        emit(UpdateRequestOfferSuccess(offer));
        // تحديث العروض في القائمة
        final index = requestOffers.indexWhere((o) => o.id == offerId);
        if (index != -1) {
          requestOffers[index] = offer;
        }
      } else {
        emit(UpdateRequestOfferError('فشل تحديث العرض'));
      }
    } on DioException catch (e) {
      emit(UpdateRequestOfferError(e.response?.data['message'] ?? 'حدث خطأ'));
    } catch (e) {
      emit(UpdateRequestOfferError(e.toString()));
    }
  }

  // 10. Delete Service Request
  Future<void> deleteServiceRequest(int requestId) async {
    emit(DeleteServiceRequestLoading());
    try {
      final response = await DioHelper.deleteRequest(
        endPoint: '${AppEndPoints.deleteServiceRequest}/$requestId',
      );

      if (response.statusCode == 200) {
        emit(DeleteServiceRequestSuccess());
        // إزالة الطلب من القوائم المحلية
        clientRequests.removeWhere((r) => r.id == requestId);
        providerAvailableRequests.removeWhere((r) => r.id == requestId);
        providerAssignedRequests.removeWhere((r) => r.id == requestId);
      } else {
        emit(DeleteServiceRequestError('فشل حذف الطلب'));
      }
    } on DioException catch (e) {
      emit(DeleteServiceRequestError(e.response?.data['message'] ?? 'حدث خطأ'));
    } catch (e) {
      emit(DeleteServiceRequestError(e.toString()));
    }
  }

  // مساعد: تنظيف البيانات
  void clearData() {
    clientRequests.clear();
    providerAvailableRequests.clear();
    providerAssignedRequests.clear();
    requestOffers.clear();
  }
}