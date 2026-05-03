// lib/features/auth/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/core/services/auth_service.dart';
import 'package:flutter_app/core/services/location_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _locationPermissionGranted = false;
  Position? _currentPosition;

  // Form Fields
  String email = '';
  String password = '';
  String fullName = '';
  String city = '';
  String area = '';
  String initialRole = 'CLIENT';

  // UI Design System
  final Color primaryBlue = const Color(0xFF5AC8E8);
  final Color darkBlue = const Color(0xFF0D47A1);
  final Color pureBlack = const Color(0xFF000000);
  final Color offWhite = const Color(0xFFF2F2F2);
  final Color lightGray = const Color(0xFFE8E8E8);
  final Color accentGreen = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await LocationService.checkLocationPermission();
      setState(() {
        // FIX: 'granted' does not exist in LocationPermission enum
        _locationPermissionGranted =
            (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse);
      });
    } catch (e) {
      debugPrint('Error checking location permission: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    if (!mounted) return;

    if (initialRole != 'SEEKER') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is only required for Seekers'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showLocationPermissionDialog();
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // FIX: withOpacity is deprecated
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  // FIX: withOpacity is deprecated
                  color: primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: primaryBlue, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Location Kyon Zaruri Hai?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: pureBlack,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '📍 Apke location se nearby jobs match karenge\n'
                '🔒 Apka address kabhi share nahi hoga\n'
                '⚡ Real-time notifications paoge',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _getLocation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Permission Dain',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightGray,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Baad Mein',
                    style: TextStyle(
                      color: pureBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _locationPermissionGranted = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Location captured successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Could not get location. Check permissions.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (initialRole == 'SEEKER' && _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seekers ko location mandatory hai'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final signupData = {
        "email": email,
        "password": password,
        "fullName": fullName,
        "city": city,
        "area": area,
        "initialRole": initialRole,
        if (_currentPosition != null) "latitude": _currentPosition!.latitude,
        if (_currentPosition != null) "longitude": _currentPosition!.longitude,
      };

      await _authService.register(signupData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Account banaya jayega! Ab login karein'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
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
                top: 40,
                bottom: 30,
                left: 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Banain',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Apka Hunar ke saath shuru karein',
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
                  children: [
                    _buildField(
                      "Pura Naam",
                      Icons.person_outline,
                      (v) => fullName = v,
                      (v) => v!.isEmpty ? 'Naam zaroori hai' : null,
                    ),
                    const SizedBox(height: 18),

                    _buildField(
                      "Email Address",
                      Icons.email_outlined,
                      (v) => email = v,
                      (v) => !v!.contains('@') ? 'Sahi email likhin' : null,
                    ),
                    const SizedBox(height: 18),

                    _buildField(
                      "Password",
                      Icons.lock_outline,
                      (v) => password = v,
                      (v) => v!.length < 8 ? 'Kam se kam 8 characters' : null,
                      isPass: true,
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "Sheher",
                            Icons.location_city,
                            (v) => city = v,
                            (v) => v!.isEmpty ? 'Sheher?' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            "Ilaka",
                            Icons.map_outlined,
                            (v) => area = v,
                            (v) => v!.isEmpty ? 'Ilaka?' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: lightGray),
                        borderRadius: BorderRadius.circular(12),
                        color: offWhite,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Main kya karna chahta hoon?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // FIX: Invalid constants removed and radio logic updated
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: initialRole == 'POSTER'
                                    ? primaryBlue
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: initialRole == 'POSTER'
                                  ? primaryBlue.withValues(alpha: 0.08)
                                  : Colors.white,
                            ),
                            child: RadioListTile<String>(
                              title: const Text('💼 Kaam dain (Poster)'),
                              subtitle: const Text('Fast-track signup'),
                              value: "POSTER",
                              groupValue: initialRole,
                              onChanged: (v) =>
                                  setState(() => initialRole = v!),
                              activeColor: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: initialRole == 'SEEKER'
                                    ? primaryBlue
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: initialRole == 'SEEKER'
                                  ? primaryBlue.withValues(alpha: 0.08)
                                  : Colors.white,
                            ),
                            child: RadioListTile<String>(
                              title: const Text(
                                '🎯 Kaam talash karain (Seeker)',
                              ),
                              subtitle: const Text('Location zaroori hai'),
                              value: "SEEKER",
                              groupValue: initialRole,
                              onChanged: (v) {
                                setState(() => initialRole = v!);
                                if (v == 'SEEKER' &&
                                    !_locationPermissionGranted) {
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    _requestLocationPermission,
                                  );
                                }
                              },
                              activeColor: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (initialRole == 'SEEKER')
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // FIX: withOpacity is deprecated
                          color: _currentPosition != null
                              ? accentGreen.withValues(alpha: 0.08)
                              : Colors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _currentPosition != null
                                ? accentGreen
                                : Colors.orange,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentPosition != null
                                  ? Icons.check_circle
                                  : Icons.location_off,
                              color: _currentPosition != null
                                  ? accentGreen
                                  : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _currentPosition != null
                                    ? '✅ Location captured'
                                    : '⚠️ Location required to continue',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _currentPosition != null
                                      ? accentGreen
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),
                    _buildButton('ACCOUNT BANAIN', _handleSignup),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: RichText(
                          text: TextSpan(
                            text: 'Pehle se account hai? ',
                            style: const TextStyle(color: Color(0xFF666666)),
                            children: [
                              TextSpan(
                                text: 'Login karain',
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
