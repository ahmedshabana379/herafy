// lib/features/home/screens/PagesView/provider_dashboard/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestMapScreen extends StatelessWidget {
  const RequestMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.isProvider = true,  // true: بروفايدر يشوف موقع العميل, false: عميل يشوف موقع البروفايدر
    this.clientName,
    this.providerName,
  });

  final double latitude;
  final double longitude;
  final String locationName;
  final bool isProvider;
  final String? clientName;
  final String? providerName;

  @override
  Widget build(BuildContext context) {
    final title = isProvider 
        ? "موقع العميل: $locationName"
        : "موقع الحرفي في الطريق إليك";
    
    final markerTitle = isProvider 
        ? (clientName ?? "موقع العميل")
        : (providerName ?? "موقع الحرفي");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('request_location'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: markerTitle),
            icon: isProvider 
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)  // موقع العميل أزرق
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // موقع الحرفي أخضر
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}