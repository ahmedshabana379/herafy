import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:herafy/core/networks/dio_helpers.dart';
import 'package:herafy/core/networks/end_points.dart';
import 'package:herafy/features/home/cubits/services_requests/cubit/service_request_state.dart';
import 'package:herafy/features/home/models/live_location_model.dart';
import 'package:herafy/features/home/models/review_model.dart';
import 'package:herafy/features/home/models/service_request_model.dart';
import 'package:herafy/features/home/models/request_offer_model.dart';
import 'package:herafy/features/home/screens/PagesView/provider_dashboard/models/request_model.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  ServiceRequestCubit() : super(ServiceRequestInitial());

  List<ServiceRequestModel> clientRequests = [];
  List<ServiceRequestProviderModel> providerAvailableRequests = [];
  List<ServiceRequestModel> providerAssignedRequests = [];
  List<RequestOfferModel> requestOffers = [];
  List<RequestOfferModel> providerOffers = [];

  /// قائمة تجمع عروض كل طلبات العميل مرة واحدة
  List<RequestOfferModel> allClientOffers = [];

  // ── جلب عروض كل طلبات العميل ─────────────────────────────────────────────
  Future<void> loadAllClientRequestOffers() async {
    emit(GetRequestOffersLoading());
    try {
      // دايماً نجيب الطلبات أولاً عشان نضمن إن البيانات محدثة
      final requestsResponse = await DioHelper.getRequest(
        endPoint: AppEndPoints.clientGetHisServiceRequests,
      );
      if (requestsResponse.statusCode == 200 && requestsResponse.data is List) {
        clientRequests = (requestsResponse.data as List)
            .map((item) => ServiceRequestModel.fromJson(item))
            .toList();
      }

      final requestsWithOffers = clientRequests
          .where(
            (r) =>
                r.requestStatus == 0 ||
                r.requestStatus == 1 ||
                r.requestStatus == 2 ||
                r.requestStatus == 3,
          )
          .toList();

      if (requestsWithOffers.isEmpty) {
        allClientOffers = [];
        emit(GetRequestOffersSuccess([]));
        return;
      }

      final futures = requestsWithOffers.map((req) async {
        try {
          final res = await DioHelper.getRequest(
            endPoint: '${AppEndPoints.clientGetServiceRequestOffers}${req.id}',
          );
          if (res.statusCode == 200) {
            final raw = res.data is Map ? res.data['data'] : res.data;
            if (raw is List) {
              return raw.map((item) {
                final map = Map<String, dynamic>.from(item);
                map['serviceRequestId'] ??= req.id;
                map['status'] ??= req.requestStatus == 0
                    ? 'pending'
                    : 'accepted';
                return RequestOfferModel.fromJson(map);
              }).toList();
            }
          }
        } catch (_) {}
        return <RequestOfferModel>[];
      });

      final results = await Future.wait(futures);
      allClientOffers = results.expand((list) => list).toList();
      requestOffers = allClientOffers;
      emit(GetRequestOffersSuccess(allClientOffers));
    } on DioException catch (e) {
      emit(GetRequestOffersError(e.message ?? 'حدث خطأ في الاتصال'));
    } catch (e) {
      emit(GetRequestOffersError(e.toString()));
    }
  }

  // 1. Create Service Request (Client)
  Future<void> createServiceRequest({
    required String description,
    required int serviceId,
    required double? budget,
    required double latitude,
    required double longitude,
    String? locationAddress,
    List<String>? imagePaths,
  }) async {
    emit(CreateServiceRequestLoading());
    try {
      // ✅ تعديل البيانات لتتناسب مع شكل الـ API المتوقع
      Map<String, dynamic> requestData = {
        'description': description,
        'serviceId': serviceId,
        'budget': budget, // دا الـ budget اللي هيتحول لـ finalPrice بعد التعيين
        'latitude': latitude,
        'longitude': longitude,
      };

      // ✅ إضافة locationAddress لو موجود
      if (locationAddress != null && locationAddress.isNotEmpty) {
        requestData['locationAddress'] = locationAddress;
      }

      FormData formData = FormData.fromMap(requestData);

      // إضافة الصور إن وجدت
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (int i = 0; i < imagePaths.length; i++) {
          formData.files.add(
            MapEntry(
              'Images',
              await MultipartFile.fromFile(
                imagePaths[i],
                filename:
                    'request_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
              ),
            ),
          );
        }
      }

      final response = await DioHelper.postRequest(
        endPoint: AppEndPoints.clientCreateServiceRequest,
        data: formData,
        contentType: FormData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final request = ServiceRequestModel.fromJson(response.data);
        emit(CreateServiceRequestSuccess(request));

        // ✅ عرض رسالة نجاح
        return Future.value();
      } else {
        emit(CreateServiceRequestError('فشل إنشاء الطلب'));
      }
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ??
          e.response?.data['title'] ??
          'حدث خطأ في الاتصال';
      emit(CreateServiceRequestError(errorMessage));
      rethrow;
    } catch (e) {
      emit(CreateServiceRequestError(e.toString()));
      rethrow;
    }
  }

  // 2. Get Client Service Requests
  Future<void> getClientServiceRequests() async {
    emit(GetClientServiceRequestsLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.clientGetHisServiceRequests,
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
        endPoint: AppEndPoints.providerGetAvailableRequests,
        query: {'pageIndex': 1, 'pageSize': 100},
      );

      print(
        "Provider Available Requests Response: ${response.data}",
      ); // ✅ للتأكد

      if (response.statusCode == 200) {
        List<ServiceRequestProviderModel> requests = [];

        // ✅ الـ Response جاي في data
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          requests = (data as List)
              .map((item) => ServiceRequestProviderModel.fromJson(item))
              .toList();
        }

        providerAvailableRequests = requests; // ✅ لازم تغير نوع المتغير
        print("عدد الطلبات المتاحة: ${requests.length}"); // ✅ للتأكد
        emit(GetProviderAvailableRequestsSuccess(requests));
      } else {
        emit(GetProviderAvailableRequestsError('فشل جلب الطلبات'));
      }
    } on DioException catch (e) {
      print("Error: ${e.response?.data}");
      emit(
        GetProviderAvailableRequestsError(e.message ?? 'حدث خطأ في الاتصال'),
      );
    } catch (e) {
      emit(GetProviderAvailableRequestsError(e.toString()));
    }
  }

  // 4. Get Provider Assigned Service Requests
  Future<void> getProviderAssignedRequests() async {
    emit(GetProviderAssignedRequestsLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: AppEndPoints.providerGetAssignedRequests,
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
        endPoint:
            '${AppEndPoints.clientAssignServiceRequestToProvider}/$requestId',
        data: {},
        queryParameters: {'providerId': providerId},
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
        endPoint: '${AppEndPoints.providerAcceptServiceRequest}/$requestId',
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
        endPoint: '${AppEndPoints.providerCreateOffer}$serviceRequestId',
        data: {'Price': price, 'Message': message},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final offer = RequestOfferModel.fromJson(response.data);
        emit(CreateRequestOfferSuccess(offer));
        await getProviderOffers();
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

  // 8. Get Request Offers By Service Request (التعديل هنا)
  Future<void> getRequestOffers(int serviceRequestId) async {
    emit(GetRequestOffersLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint:
            '${AppEndPoints.clientGetServiceRequestOffers}$serviceRequestId',
      );

      if (response.statusCode == 200) {
        List<RequestOfferModel> offers = [];

        // التعديل الجوهري: فحص مكان الداتا بالظبط
        final rawData = response.data is Map
            ? response.data['data']
            : response.data;

        if (rawData is List) {
          offers = rawData
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

  Future<void> getProviderOffers() async {
  emit(GetRequestOffersLoading());
  try {
    final response = await DioHelper.getRequest(
      endPoint: AppEndPoints.providerGetHisOffers,
    );

    if (response.statusCode == 200) {
      List<RequestOfferModel> offers = [];
      if (response.data is List) {
        offers = (response.data as List).map((item) {
          final map = Map<String, dynamic>.from(item);
          map['status'] ??= 'pending'; // ✅ inject
          return RequestOfferModel.fromJson(map);
        }).toList();
      }
      providerOffers = offers;
      emit(GetRequestOffersSuccess(offers));
    } else {
      emit(GetRequestOffersError('فشل جلب عروضك'));
    }
  } on DioException catch (e) {
    emit(GetRequestOffersError(e.message ?? 'حدث خطأ في الاتصال'));
  } catch (e) {
    emit(GetRequestOffersError(e.toString()));
  }
}

  // في service_request_cubit.dart

  // ============ Live Location Methods ============

  // تحديث الموقع الحي (للفني)
  Future<void> updateLiveLocation({
    required double latitude,
    required double longitude,
  }) async {
    emit(UpdateLiveLocationLoading());
    try {
      final body = UpdateLiveLocationRequestModel(
        latitude: latitude,
        longitude: longitude,
      );

      final response = await DioHelper.putRequest(
        endPoint: AppEndPoints.updateLiveLocation,
        data: body.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(UpdateLiveLocationSuccess());
        print("✅ تم تحديث الموقع الحي بنجاح");
      } else {
        emit(UpdateLiveLocationError('فشل تحديث الموقع'));
      }
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'حدث خطأ في الاتصال';
      emit(UpdateLiveLocationError(errorMessage));
    } catch (e) {
      emit(UpdateLiveLocationError(e.toString()));
    }
  }

  // جلب الموقع الحي لمستخدم معين (للكلاينت يتتبع الفني)
  Future<void> getLiveLocation(int userId) async {
    emit(GetLiveLocationLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: '${AppEndPoints.getLiveLocation}$userId',
      );

      if (response.statusCode == 200) {
        final location = LiveLocationResponseModel.fromJson(response.data);
        emit(GetLiveLocationSuccess(location));
      } else {
        emit(GetLiveLocationError('فشل جلب الموقع'));
      }
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'حدث خطأ في الاتصال';
      emit(GetLiveLocationError(errorMessage));
    } catch (e) {
      emit(GetLiveLocationError(e.toString()));
    }
  }

  // بدء التحديث التلقائي للموقع (للفني)
  Timer? _locationUpdateTimer;

  void startLiveLocationUpdates({
    required double initialLatitude,
    required double initialLongitude,
  }) {
    // إيقاف أي Timer قديم
    stopLiveLocationUpdates();

    // تحديث الموقع فوراً
    updateLiveLocation(latitude: initialLatitude, longitude: initialLongitude);

    // تحديث الموقع كل 10 ثواني
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        await updateLiveLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (_) {}
    });
  }

  void stopLiveLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  // ============ Review Methods ============

  // إنشاء تقييم
  Future<void> createReview({
    required int serviceRequestId,
    required double rating,
    required String message,
  }) async {
    emit(CreateReviewLoading());
    try {
      final body = CreateReviewRequestModel(
        serviceRequestId: serviceRequestId,
        rating: rating,
        message: message,
      );

      final response = await DioHelper.postRequest(
        endPoint: AppEndPoints.createReview,
        data: body.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final review = ReviewResponseModel.fromJson(response.data);
        emit(CreateReviewSuccess(review));
        print("✅ تم إنشاء التقييم بنجاح");
      } else {
        emit(CreateReviewError('فشل إنشاء التقييم'));
      }
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ?? 'حدث خطأ في الاتصال';
      emit(CreateReviewError(errorMessage));
    } catch (e) {
      emit(CreateReviewError(e.toString()));
    }
  }

  // ============ Complete Service Request (Client) ============
  Future<void> completeServiceRequest(int requestId) async {
    emit(CompleteServiceRequestLoading());
    try {
      final response = await DioHelper.putRequest(
        endPoint: '${AppEndPoints.clientSetServiceRequestCompleted}$requestId',
        data: {},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(CompleteServiceRequestSuccess());
        await getClientServiceRequests();
      } else {
        emit(CompleteServiceRequestError('فشل إكمال الطلب'));
      }
    } on DioException catch (e) {
      emit(
        CompleteServiceRequestError(
          e.response?.data['message'] ?? 'حدث خطأ في الاتصال',
        ),
      );
    } catch (e) {
      emit(CompleteServiceRequestError(e.toString()));
    }
  }

  // ============ Cancel Service Request (Client) ============
  Future<void> cancelServiceRequest(int requestId) async {
    emit(CancelServiceRequestLoading());
    try {
      final response = await DioHelper.putRequest(
        endPoint: '${AppEndPoints.clientSetServiceRequestCanceled}$requestId',
        data: {},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(CancelServiceRequestSuccess());
        await getClientServiceRequests();
      } else {
        emit(CancelServiceRequestError('فشل إلغاء الطلب'));
      }
    } on DioException catch (e) {
      emit(
        CancelServiceRequestError(
          e.response?.data['message'] ?? 'حدث خطأ في الاتصال',
        ),
      );
    } catch (e) {
      emit(CancelServiceRequestError(e.toString()));
    }
  }

  // ============ Get Service Request By ID ============
  Future<void> getServiceRequestById(int requestId) async {
    emit(GetServiceRequestByIdLoading());
    try {
      final response = await DioHelper.getRequest(
        endPoint: '${AppEndPoints.getServiceRequestById}$requestId',
      );
      if (response.statusCode == 200) {
        final request = ServiceRequestModel.fromJson(response.data);
        emit(GetServiceRequestByIdSuccess(request));
      } else {
        emit(GetServiceRequestByIdError('فشل جلب الطلب'));
      }
    } on DioException catch (e) {
      emit(
        GetServiceRequestByIdError(
          e.response?.data['message'] ?? 'حدث خطأ في الاتصال',
        ),
      );
    } catch (e) {
      emit(GetServiceRequestByIdError(e.toString()));
    }
  }

  /// نفس الدالة لكن بدون emit(Loading) — للاستخدام في التحديث الدوري (polling)
  /// حتى لا يُعاد بناء الـ UI من الصفر كل 10 ثواني
  Future<void> pollServiceRequestStatus(int requestId) async {
    try {
      final response = await DioHelper.getRequest(
        endPoint: '${AppEndPoints.getServiceRequestById}$requestId',
      );
      if (response.statusCode == 200) {
        final request = ServiceRequestModel.fromJson(response.data);
        emit(GetServiceRequestByIdSuccess(request));
      }
    } catch (_) {
      // خطأ صامت — مش بنوقف التطبيق
    }
  }

  // تنظيف عند الخروج
  @override
  Future<void> close() {
    stopLiveLocationUpdates();
    return super.close();
  }
  // 4.1 Get Provider All Service Requests (جلب كل الطلبات بما فيها المنتهية)
Future<void> getProviderAllRequests() async {
  emit(GetProviderAssignedRequestsLoading());
  try {
    final response = await DioHelper.getRequest(
      endPoint: AppEndPoints.providerGetAssignedRequests,
    );

    if (response.statusCode == 200) {
      List<ServiceRequestModel> requests = [];
      if (response.data is List) {
        requests = (response.data as List)
            .map((item) => ServiceRequestModel.fromJson(item))
            .toList();
      }
      
      // ✅ خزن كل الطلبات كما هي (1,2,3)
      providerAssignedRequests = requests;
      
      // ✅ اطبع تفاصيل للتصحيح
      print("========== Provider All Requests ==========");
      print("Total requests: ${requests.length}");
      for (var r in requests) {
        print("Request ${r.id}: status=${r.requestStatus}, price=${r.finalPrice}");
      }
      print("===========================================");
      
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

  // 9. Update Request Offer
  // Future<void> updateRequestOffer({
  //   required int offerId,
  //   required double price,
  //   required String message,
  // }) async {
  //   emit(UpdateRequestOfferLoading());
  //   try {
  //     final response = await DioHelper.putRequest(
  //       endPoint: '${AppEndPoints.providerUpdateOffer}/$offerId',
  //       data: {
  //         'Price': price,
  //         'Message': message,
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final offer = RequestOfferModel.fromJson(response.data);
  //       emit(UpdateRequestOfferSuccess(offer));
  //       // تحديث العروض في القائمة
  //       final index = requestOffers.indexWhere((o) => o.id == offerId);
  //       if (index != -1) {
  //         requestOffers[index] = offer;
  //       }
  //     } else {
  //       emit(UpdateRequestOfferError('فشل تحديث العرض'));
  //     }
  //   } on DioException catch (e) {
  //     emit(UpdateRequestOfferError(e.response?.data['message'] ?? 'حدث خطأ'));
  //   } catch (e) {
  //     emit(UpdateRequestOfferError(e.toString()));
  //   }
  // }

  // 10. Delete Service Request
  // Future<void> deleteServiceRequest(int requestId) async {
  //   emit(DeleteServiceRequestLoading());
  //   try {
  //     final response = await DioHelper.deleteRequest(
  //       endPoint: '${AppEndPoints.deleteServiceRequest}/$requestId',
  //     );

  //     if (response.statusCode == 200) {
  //       emit(DeleteServiceRequestSuccess());
  //       // إزالة الطلب من القوائم المحلية
  //       clientRequests.removeWhere((r) => r.id == requestId);
  //       providerAvailableRequests.removeWhere((r) => r.id == requestId);
  //       providerAssignedRequests.removeWhere((r) => r.id == requestId);
  //     } else {
  //       emit(DeleteServiceRequestError('فشل حذف الطلب'));
  //     }
  //   } on DioException catch (e) {
  //     emit(DeleteServiceRequestError(e.response?.data['message'] ?? 'حدث خطأ'));
  //   } catch (e) {
  //     emit(DeleteServiceRequestError(e.toString()));
  //   }
  // }

  // // مساعد: تنظيف البيانات
  // void clearData() {
  //   clientRequests.clear();
  //   providerAvailableRequests.clear();
  //   providerAssignedRequests.clear();
  //   requestOffers.clear();
  // }

  // Provider يتابع حالة العرض بتاعه
  //  Future<void> checkOfferStatus(int serviceRequestId) async {
  //   emit(CheckOfferStatusLoading());
  //   try {
  //     final response = await DioHelper.getRequest(
  //       endPoint: '${AppEndPoints.clientGetServiceRequestOffers}/$serviceRequestId',
  //     );

  //     if (response.statusCode == 200) {
  //       List<RequestOfferModel> offers = [];
  //       if (response.data is List) {
  //         offers = (response.data as List)
  //             .map((item) => RequestOfferModel.fromJson(item))
  //             .toList();
  //       }

  //       final myOffer = offers.firstWhereOrNull(
  //         (offer) => offer.providerId == _getCurrentProviderId(),
  //       );

  //       if (myOffer != null) {
  //         emit(CheckOfferStatusSuccess(myOffer.status));
  //       } else {
  //         emit(CheckOfferStatusError("لا يوجد عرض لك"));
  //       }
  //     } else {
  //       emit(CheckOfferStatusError('فشل جلب العروض'));
  //     }
  //   } catch (e) {
  //     emit(CheckOfferStatusError(e.toString()));
  //   }
  // }
  // ✅ نسخة silent للـ polling - بدون emit(Loading)
Future<void> getProviderOffersSilent() async {
  try {
    final response = await DioHelper.getRequest(
      endPoint: AppEndPoints.providerGetHisOffers,
    );
    if (response.statusCode == 200) {
      List<RequestOfferModel> newOffers = [];
      if (response.data is List) {
        newOffers = (response.data as List).map((item) {
          final map = Map<String, dynamic>.from(item);
          map['status'] ??= 'pending';
          return RequestOfferModel.fromJson(map);
        }).toList();
      }

      // ✅ هنا بنكشف لو في عرض اتقبل جديد
      for (final newOffer in newOffers) {
        final oldOffer = providerOffers.firstWhere(
          (o) => o.serviceRequestId == newOffer.serviceRequestId,
          orElse: () => RequestOfferModel(
            id: 0, serviceRequestId: 0, providerId: 0,
            price: 0, message: '', status: '', createdAt: DateTime.now(),
          ),
        );
        // لو الأوفر ده كان pending وبقى accepted → ابعت notification
        if ((oldOffer.status == 'pending' || oldOffer.id == 0) &&
            newOffer.status == 'accepted') {
          emit(OfferAcceptedNotification(
            serviceRequestId: newOffer.serviceRequestId ?? 0,
            price: newOffer.price,
          ));
        }
      }

      providerOffers = newOffers;
      emit(ProviderDataRefreshed());
    }
  } catch (_) {}
}

// ✅ نسخة silent لجلب الطلبات كمان
Future<void> getProviderAllRequestsSilent() async {
  try {
    final response = await DioHelper.getRequest(
      endPoint: AppEndPoints.providerGetAssignedRequests,
    );
    if (response.statusCode == 200 && response.data is List) {
      providerAssignedRequests = (response.data as List)
          .map((item) => ServiceRequestModel.fromJson(item))
          .toList();
    }
  } catch (_) {}
}

Future<void> getProviderAvailableRequestsSilent() async {
  try {
    final response = await DioHelper.getRequest(
      endPoint: AppEndPoints.providerGetAvailableRequests,
      query: {'pageIndex': 1, 'pageSize': 100},
    );
    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      if (data is List) {
        providerAvailableRequests = (data as List)
            .map((item) => ServiceRequestProviderModel.fromJson(item))
            .toList();
      }
    }
  } catch (_) {}
}

// ✅ الـ refresh الكامل الصامت
Future<void> refreshProviderDashboardSilent() async {
  await getProviderAvailableRequestsSilent();
  await getProviderAllRequestsSilent();
  await getProviderOffersSilent(); // ده بيعمل emit في الآخر
}
}
