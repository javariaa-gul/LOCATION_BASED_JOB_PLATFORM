// lib/core/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LocationService {
  // FIX 1: Naming convention change ki (distanceThreshold) aur type 'int' rakha taake 'distanceFilter' mein masla na ho
  static const int distanceThreshold = 500; // 500 meters

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission;
  }

  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        debugPrint('Location service is disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission is denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission is permanently denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  static StreamSubscription<Position> startPositionStream({
    Duration updateInterval = const Duration(minutes: 5),
    // FIX 2: Default value 'distanceThreshold' (int) use ki
    int distanceFilter = distanceThreshold,
    required Function(Position) onLocationUpdate,
    required Function(String)? onError,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter:
            distanceFilter, // Ab ye error nahi dega kyunke ye 'int' hai
        // Note: timeLimit yahan check karta hai agar signal na aaye,
        // real interval Android/iOS ki settings par depend karta hai.
      ),
    ).listen(
      (Position position) {
        debugPrint(
          'Position stream update: ${position.latitude}, ${position.longitude}',
        );
        onLocationUpdate(position);
      },
      onError: (error) {
        debugPrint('Position stream error: $error');
        if (onError != null) {
          onError(error.toString());
        }
      },
    );
  }

  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  static Map<String, double> formatLocationData(Position position) {
    return {'latitude': position.latitude, 'longitude': position.longitude};
  }

  static bool hasUserMovedSignificantly(
    Position? lastPosition,
    Position currentPosition,
  ) {
    if (lastPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      lastPosition.latitude,
      lastPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    // distance 'double' return karta hai, comparison theek rahega
    return distance > distanceThreshold;
  }
}
