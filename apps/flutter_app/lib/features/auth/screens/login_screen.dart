// lib/features/auth/screens/login_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/auth_service.dart';
import 'package:flutter_app/core/services/location_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // FIX: Subscription ko yahan define kiya taake use cancel kiya ja sake
  StreamSubscription? _locationSubscription;

  bool _isLoading = false;
  bool _showPassword = false;

  String email = '';
  String password = '';

  final Color primaryBlue = const Color(0xFF5AC8E8);
  final Color darkBlue = const Color(0xFF0D47A1);
  final Color pureBlack = const Color(0xFF000000);
  final Color offWhite = const Color(0xFFF2F2F2);
  final Color lightGray = const Color(0xFFE8E8E8);

  @override
  void dispose() {
    // FIX: Memory leak se bachne ke liye subscription cancel karna zaruri hai
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(email, password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Apka Hunar mein welcome hain!'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && response['user']['role'] == 'SEEKER') {
            _startBackgroundLocationTracking();
          }
        });

        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startBackgroundLocationTracking() {
    // FIX: 'subscription' variable error fixed by assigning to class property
    _locationSubscription = LocationService.startPositionStream(
      updateInterval: const Duration(minutes: 5),
      distanceFilter: 500,
      onLocationUpdate: (position) async {
        try {
          // FIX: '_storage' direct access ki jagah service ka method use karein
          // Make sure to add 'getUserId' method in your AuthService
          final userId = await _authService.getUserId();

          if (userId != null) {
            await _authService.updateLocation(
              userId,
              position.latitude,
              position.longitude,
            );
            debugPrint(
              'Location updated: ${position.latitude}, ${position.longitude}',
            );
          }
        } catch (e) {
          debugPrint('Background location update error: $e');
        }
      },
      onError: (error) {
        debugPrint('Background location stream error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryBlue, darkBlue],
                ),
              ),
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 40,
                left: 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 70,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.handyman_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Khush Amdeed',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Apke kaam ke liye sahi log dhundne dein',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: pureBlack,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildField(
                      "Email Address",
                      Icons.email_outlined,
                      (v) => email = v,
                      (v) {
                        if (v == null || v.isEmpty) return 'Email zaruri hai';
                        if (!v.contains('@')) return 'Sahi email likhin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      "Password",
                      Icons.lock_outline,
                      (v) => password = v,
                      (v) => (v == null || v.length < 8)
                          ? 'Kam se kam 8 characters'
                          : null,
                      isPass: true,
                    ),
                    const SizedBox(height: 28),

                    _buildButton('LOGIN', _handleLogin),

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: 'Account nahi hai? ',
                            // FIX: Color code updated to 8-digit hex
                            style: const TextStyle(color: Color(0xFF666666)),
                            children: [
                              TextSpan(
                                text: 'Banain',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black,
          ),
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
                      color: primaryBlue,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  )
                : null,
            filled: true,
            fillColor: offWhite,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
