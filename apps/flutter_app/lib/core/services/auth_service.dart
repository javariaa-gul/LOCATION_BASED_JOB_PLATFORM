// lib/core/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Emulator ke liye 10.0.2.2 use hota hai, physical device ke liye PC ka IP
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/auth'));
  final _storage = const FlutterSecureStorage();

  Future<void> register(Map<String, dynamic> data) async {
    try {
      await _dio.post('/register', data: data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Signup failed';
    }
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
}
