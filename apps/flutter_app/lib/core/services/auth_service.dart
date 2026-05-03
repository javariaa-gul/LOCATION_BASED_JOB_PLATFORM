// lib/core/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Emulator ke liye 10.0.2.2 use hota hai, physical device ke liye PC ka IP
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/auth'));
  final _storage = const FlutterSecureStorage();

  /// Register user with optional location for Seekers
  /// For Seekers: latitude and longitude are included
  /// For Posters: latitude and longitude are omitted
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      // Filter out null location values to ensure clean JSON
      final cleanData = Map<String, dynamic>.from(data);
      if (cleanData['latitude'] == null) cleanData.remove('latitude');
      if (cleanData['longitude'] == null) cleanData.remove('longitude');

      final response = await _dio.post('/register', data: cleanData);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Signup failed';
    }
  }

  // auth_service.dart ke andar add karein
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email, // Backend LoginDto expects email
          'password': password,
        },
      );

      // Token aur User ID dono save karein
      await _storage.write(key: 'jwt', value: response.data['access_token']);
      await _storage.write(key: 'user_id', value: response.data['user']['id']);

      return response.data;
    } on DioException catch (e) {
      // Backend se jo message aye wahi display ho
      final errorMsg = e.response?.data['message'];
      throw (errorMsg is List)
          ? errorMsg.join(", ")
          : (errorMsg ?? 'Login failed');
    }
  }

  /// Update seeker's location on the backend
  /// Called periodically during app usage
  Future<void> updateLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    try {
      final token = await _storage.read(key: 'jwt');
      if (token == null) throw Exception('No JWT token found');

      await _dio.post(
        '/location/update/$userId',
        data: {'latitude': latitude, 'longitude': longitude},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Location update failed';
    }
  }

  /// Get nearby seekers for a posting location
  Future<List<String>> getNearbySeekersForPosting(
    double latitude,
    double longitude, {
    double radiusKm = 5,
  }) async {
    try {
      final response = await _dio.post(
        '/location/nearby',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
      );

      final seekerIds = List<String>.from(response.data['seekerIds'] ?? []);
      return seekerIds;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch nearby seekers';
    }
  }

  /// Deactivate seeker from real-time matching (on logout)
  Future<void> deactivateSeeker(String userId) async {
    try {
      final token = await _storage.read(key: 'jwt');
      if (token == null) throw Exception('No JWT token found');

      await _dio.post(
        '/location/deactivate/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Deactivation failed';
    }
  }
}
