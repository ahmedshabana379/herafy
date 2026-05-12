import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:herafy/core/components/snack_bar_helper.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.useCurrentLocation = false,
  });

  final double initialLatitude;
  final double initialLongitude;
  final bool useCurrentLocation;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _isGettingLocation = false;

  // ✅ للبحث عن الحرفيين القريبين
  // List<Map<String, dynamic>> _nearbyProviders = []; // DELETED: Removed nearby providers
  // bool _isLoadingProviders = false; // DELETED: Removed loading providers flag

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _getAddressFromLatLng();

    if (widget.useCurrentLocation) {
      _getCurrentLocation();
    }
  }

  // ✅ جلب الحرفيين القريبين بناءً على الحرفة
  // Future<void> _getNearbyProviders() async { // DELETED: Entire method removed
  //   setState(() {
  //     _isLoadingProviders = true;
  //   });
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         'https://your-api.com/api/providers/nearby?lat=${_selectedLocation.latitude}&lng=${_selectedLocation.longitude}&radius=5',
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       setState(() {
  //         _nearbyProviders = List<Map<String, dynamic>>.from(data['data']);
  //       });
  //     } else {
  //       setState(() {
  //         _nearbyProviders = [
  //           {
  //             'id': 1,
  //             'name': 'أبو العز سباك',
  //             'profession': 'سباك',
  //             'rating': 4.8,
  //             'distance': 1.2,
  //             'imageUrl': null,
  //           },
  //           {
  //             'id': 2,
  //             'name': 'محمد كهربائي',
  //             'profession': 'كهربائي',
  //             'rating': 4.5,
  //             'distance': 2.5,
  //             'imageUrl': null,
  //           },
  //           {
  //             'id': 3,
  //             'name': 'كريم نجار',
  //             'profession': 'نجار',
  //             'rating': 4.9,
  //             'distance': 3.0,
  //             'imageUrl': null,
  //           },
  //         ];
  //       });
  //     }
  //   } catch (e) {
  //     print("Error getting nearby providers: $e");
  //     setState(() {
  //       _nearbyProviders = [
  //         {
  //           'id': 1,
  //           'name': 'أبو العز سباك',
  //           'profession': 'سباك',
  //           'rating': 4.8,
  //           'distance': 1.2,
  //         },
  //         {
  //           'id': 2,
  //           'name': 'محمد كهربائي',
  //           'profession': 'كهربائي',
  //           'rating': 4.5,
  //           'distance': 2.5,
  //         },
  //       ];
  //     });
  //   } finally {
  //     setState(() {
  //       _isLoadingProviders = false;
  //     });
  //   }
  // }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final hasPermission = await PermissionHandler().getPermissionLocation();
      if (!hasPermission) {
        if (mounted) {
          SnackBarHelper.showWarningSnackBar(context, "يرجى تفعيل صلاحية الموقع أولاً");
        }
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // ✅ التحقق من تشغيل GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          SnackBarHelper.showWarningSnackBar(context, "يرجى تشغيل خدمة تحديد الموقع");
          await Geolocator.openLocationSettings();
        }
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // ✅ استخدام LocationAccuracy.low للسرعة، مع timeout أطول
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low, // ✅ low بدل high عشان أسرع
            timeLimit: const Duration(seconds: 30), // ✅ 30 ثانية بدل 15
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw ("الموقع لم يتم تحديده بعد");
            },
          );

      print("📍 Current Location: ${position.latitude}, ${position.longitude}");

      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });

        _mapController.move(_selectedLocation, 16);
        await _getAddressFromLatLng();

        // await _getNearbyProviders(); // DELETED: Removed call to get nearby providers

        if (mounted) {
          SnackBarHelper.showSuccessSnackBar(context, "تم تحديد موقعك الحالي");
        }
      }
    } catch (e) {
      print("Timeout getting location: $e");
      if (mounted) {
        SnackBarHelper.showWarningSnackBar(context, "تعذر تحديد الموقع، يرجى التأكد من تشغيل GPS والمحاولة مرة أخرى");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      print(
        "📍 Getting address for: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}",
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        print("📍 Place: ${place.toString()}");

        final addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).toList();

        String address = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : "${place.locality ?? ''} ${place.administrativeArea ?? ''}";

        if (address.isEmpty) {
          address = "الموقع المحدد على الخريطة";
        }

        setState(() {
          _selectedAddress = address;
        });

        print("📍 Final Address: $_selectedAddress");
      } else {
        setState(() {
          _selectedAddress =
              "الموقع المحدد (${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)})";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
      setState(() {
        _selectedAddress =
            "الموقع: ${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اختر موقعك"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isGettingLocation)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14,
              onTap: (tapPosition, latLng) {
                setState(() {
                  _selectedLocation = latLng;
                });
                _getAddressFromLatLng();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.herafy.app',
              ),

              // ✅ ماركر الموقع المختار
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ],
              ),

              // ✅ DELETED: Removed nearby providers markers layer section
              // if (_nearbyProviders.isNotEmpty)
              //   MarkerLayer(
              //     markers: _nearbyProviders.map((provider) {
              //       return Marker(
              //         point: LatLng(
              //           _selectedLocation.latitude +
              //               (provider['distance']! / 111) * 0.01,
              //           _selectedLocation.longitude +
              //               (provider['distance']! / 85) * 0.01,
              //         ),
              //         width: 60,
              //         height: 70,
              //         child: GestureDetector(
              //           onTap: () {
              //             showDialog(
              //               context: context,
              //               builder: (context) => AlertDialog(
              //                 title: Text(provider['name']),
              //                 content: Column(
              //                   mainAxisSize: MainAxisSize.min,
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Text("المهنة: ${provider['profession']}"),
              //                     const SizedBox(height: 8),
              //                     Text("التقييم: ${provider['rating']} ⭐"),
              //                     const SizedBox(height: 8),
              //                     Text("المسافة: ${provider['distance']} كم"),
              //                   ],
              //                 ),
              //                 actions: [
              //                   TextButton(
              //                     onPressed: () => Navigator.pop(context),
              //                     child: const Text("إغلاق"),
              //                   ),
              //                 ],
              //               ),
              //             );
              //           },
              //           child: Column(
              //             children: [
              //               Container(
              //                 padding: const EdgeInsets.all(4),
              //                 decoration: BoxDecoration(
              //                   color: Colors.white,
              //                   borderRadius: BorderRadius.circular(20),
              //                   boxShadow: [
              //                     BoxShadow(
              //                       color: Colors.black.withOpacity(0.2),
              //                       blurRadius: 4,
              //                     ),
              //                   ],
              //                 ),
              //                 child: Row(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: [
              //                     const Icon(
              //                       Icons.person,
              //                       color: Colors.blue,
              //                       size: 14,
              //                     ),
              //                     const SizedBox(width: 4),
              //                     Text(
              //                       provider['name'],
              //                       style: const TextStyle(
              //                         fontSize: 10,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               const Icon(
              //                 Icons.location_on,
              //                 color: Colors.blue,
              //                 size: 24,
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //   ),
            ],
          ),

          // ✅ نقطة المركز الثابتة
          IgnorePointer(
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 40),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 48,
                ),
              ),
            ),
          ),

          // ✅ زر الموقع الحالي
          Positioned(
            bottom: 160,
            right: 16,
            child: FloatingActionButton(
              heroTag: null,
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              child: _isGettingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: Color(0xFF6C63FF)),
            ),
          ),

          // ✅ DELETED: Removed search button for nearby providers
          // Positioned(
          //   bottom: 160,
          //   left: 16,
          //   child: FloatingActionButton(
          //     heroTag: null,
          //     mini: true,
          //     backgroundColor: Colors.white,
          //     onPressed: _isLoadingProviders ? null : _getNearbyProviders,
          //     child: _isLoadingProviders
          //         ? const SizedBox(
          //             width: 20,
          //             height: 20,
          //             child: CircularProgressIndicator(strokeWidth: 2),
          //           )
          //         : const Icon(Icons.search, color: Color(0xFF6C63FF)),
          //   ),
          // ),

          // ✅ الـ Bottom Sheet مع العنوان
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "الموقع المحدد",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress.isNotEmpty
                        ? _selectedAddress
                        : "اضغط على الخريطة أو استخدم زر الموقع الحالي",
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedAddress.isNotEmpty
                          ? Colors.black
                          : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ DELETED: Removed nearby providers count display
                  // if (_nearbyProviders.isNotEmpty)
                  //   Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       color: Colors.blue[50],
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.people, size: 16, color: Colors.blue[700]),
                  //         const SizedBox(width: 8),
                  //         Text(
                  //           "يوجد ${_nearbyProviders.length} حرفي بالقرب منك",
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //             color: Colors.blue[700],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),

                  // const SizedBox(height: 16), // DELETED: Removed extra spacing

                  // ✅ عرض الإحداثيات
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // ✅ في زر التأكيد
                      onPressed: () {
                        print("✅ تأكيد الموقع:");
                        print("   Latitude: ${_selectedLocation.latitude}");
                        print("   Longitude: ${_selectedLocation.longitude}");
                        print("   Address: $_selectedAddress");
                        print(
                          "   نوع latitude: ${_selectedLocation.latitude.runtimeType}",
                        );
                        print(
                          "   نوع longitude: ${_selectedLocation.longitude.runtimeType}",
                        );

                        // ✅ التأكد من أن القيم مش null
                        if (_selectedLocation.latitude != null &&
                            _selectedLocation.longitude != null) {
                          Navigator.pop(context, {
                            'latitude': _selectedLocation.latitude,
                            'longitude': _selectedLocation.longitude,
                            'address': _selectedAddress,
                          });
                        } else {
                          SnackBarHelper.showErrorSnackBar(context, "يرجى اختيار موقع أولاً");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "تأكيد الموقع",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

class PermissionHandler {
  static final PermissionHandler _instance = PermissionHandler._internal();

  PermissionHandler._internal();

  factory PermissionHandler() => _instance;

  Future<bool> getPermissionLocation() async {
    // التحقق من تشغيل خدمة الموقع
    bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    // التحقق من الصلاحيات
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}