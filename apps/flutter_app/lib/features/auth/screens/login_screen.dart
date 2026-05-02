import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// Apne project ka sahi package name yahan check kar len
import 'package:flutter_app/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // ApiService ki jagah humne AuthService use kiya hai jo NestJS se connect hai
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showPassword = false;

  // Backend LoginDto expects email, so we use email here
  String email = '';
  String password = '';

  // Sexy UI Colors
  final Color primaryBlue = const Color(0xFF5AC8E8);
  final Color pureBlack = const Color(0xFF000000);
  final Color offWhite = const Color(0xFFF2F2F2);

  void _startPeriodicLocationUpdate() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        debugPrint(
          "Location Update: ${position.latitude}, ${position.longitude}",
        );
      } catch (e) {
        debugPrint("Location update failed: $e");
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Capture Location (Forensic Simulation requirement)
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 2. Call NestJS Backend via AuthService
      // Backend expects { email, password }
      await _authService.login(email, password);

      if (mounted) {
        _startPeriodicLocationUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful! Welcome to Apka Hunar'),
            backgroundColor: Colors.green,
          ),
        );
        // Dashboard par bhej den
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    errorBuilder: (c, e, s) => Icon(
                      Icons.handyman_rounded,
                      size: 80,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: pureBlack,
                    ),
                  ),
                  const Text(
                    'Login to continue using APKA HUNAR',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Email Field (Backend compatibility)
                  _buildField(
                    "Email Address",
                    Icons.email_outlined,
                    (v) => email = v,
                    (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@'))
                        return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildField(
                    "Password",
                    Icons.lock_outline,
                    (v) => password = v,
                    (v) => (v == null || v.length < 8)
                        ? 'Password must be at least 8 characters'
                        : null,
                    isPass: true,
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  _buildButton('LOGIN', _handleLogin),

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text(
                      'Don\'t have an account? Sign Up',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    IconData icon,
    Function(String) onChange,
    String? Function(String?)? validator, {
    bool isPass = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isPass && !_showPassword,
          onChanged: onChange,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryBlue, size: 20),
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  )
                : null,
            filled: true,
            fillColor: offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: pureBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
