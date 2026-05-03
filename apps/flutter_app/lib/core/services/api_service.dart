// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // 1. Agar Android Emulator hai toh 'http://10.0.2.2:3000' use karein
      // Web ya iOS simulator ke liye 'http://localhost:3000' sahi hai
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Post Job API ---
  Future<Response> postJob(Map<String, dynamic> data) async {
    try {
      final String? token = await _storage.read(key: 'jwt');

      return await _dio.post(
        '/auth/jobs',
        data: data,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // --- Get All Jobs API (Reload ke liye) ---
  Future<Response> getAllJobs() async {
    try {
      final String? token = await _storage.read(key: 'jwt');

      return await _dio.get(
        '/auth/all-jobs',
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // --- Centralized Error Handling ---
  void _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      throw "Unauthorized: Please login again";
    } else if (e.response?.statusCode == 404) {
      throw "Endpoint not found: Check NestJS routes";
    } else if (e.response?.statusCode == 400) {
      throw "Bad Request: Check your data format (Enums/Fields)";
    }
    throw e.message ?? "Backend connection failed";
  }
}
