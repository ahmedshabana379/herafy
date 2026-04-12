import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:herafy/core/services/location_service.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.useCurrentLocation = false, // ✅ نضيفها هنا
  });

  final double initialLatitude;
  final double initialLongitude;
  final bool useCurrentLocation; // ✅ نضيفها هنا

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late GoogleMapController _mapController;
  late LatLng _selectedLocation;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _getAddressFromLatLng();

    // ✅ لو useCurrentLocation == true، نحاول نجيب الموقع الحالي
    if (widget.useCurrentLocation) {
      _getCurrentLocation();
    }
  }

  // ✅ دالة جديدة لجلب الموقع الحالي
  Future<void> _getCurrentLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (location != null && mounted) {
      setState(() {
        _selectedLocation = LatLng(location.latitude, location.longitude);
      });
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedLocation, zoom: 15),
        ),
      );
      await _getAddressFromLatLng();
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        setState(() {
          _selectedAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      print("Error getting address: $e");
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
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (latLng) {
                setState(() {
                  _selectedLocation = latLng;
                });
                _getAddressFromLatLng();
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedLocation,
                  draggable: true,
                  onDragEnd: (newPosition) {
                    setState(() {
                      _selectedLocation = newPosition;
                    });
                    _getAddressFromLatLng();
                  },
                  infoWindow: InfoWindow(title: _selectedAddress),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            // Center marker icon
            Center(
              child: Icon(Icons.location_pin, color: Colors.red, size: 48),
            ),
            // ✅ زر الموقع الحالي (اختياري)
            if (widget.useCurrentLocation)
              Positioned(
                bottom: 120,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _getCurrentLocation,
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
            // Bottom sheet with address
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
                    Text(
                      "الموقع المحدد",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress.isNotEmpty
                          ? _selectedAddress
                          : "جاري تحميل العنوان...",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'latitude': _selectedLocation.latitude,
                            'longitude': _selectedLocation.longitude,
                            'address': _selectedAddress,
                          });
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
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
