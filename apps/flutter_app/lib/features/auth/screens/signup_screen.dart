import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/auth_service.dart';

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

  // Backend RegisterDto Fields
  String email = '';
  String password = '';
  String fullName = '';
  String city = '';
  String area = '';
  String initialRole = 'POSTER'; // Default role as per NestJS enum

  // UI Colors
  final Color primaryBlue = const Color(0xFF5AC8E8);
  final Color pureBlack = const Color(0xFF000000);
  final Color offWhite = const Color(0xFFF2F2F2);

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Backend expects these exact keys from RegisterDto
      final signupData = {
        "email": email,
        "password": password,
        "fullName": fullName,
        "city": city,
        "area": area,
        "initialRole": initialRole, // Must be 'POSTER' or 'SEEKER'
      };

      await _authService.register(signupData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created! Please Login'),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: pureBlack,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildField(
                    "Full Name",
                    Icons.person_outline,
                    (v) => fullName = v,
                    (v) => v!.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 15),

                  _buildField(
                    "Email Address",
                    Icons.email_outlined,
                    (v) => email = v,
                    (v) => !v!.contains('@') ? 'Invalid email' : null,
                  ),
                  const SizedBox(height: 15),

                  _buildField(
                    "Password",
                    Icons.lock_outline,
                    (v) => password = v,
                    (v) => v!.length < 8
                        ? 'Min 8 chars with Upper, Lower & Number'
                        : null,
                    isPass: true,
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          "City",
                          Icons.location_city,
                          (v) => city = v,
                          (v) => v!.isEmpty ? 'City?' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildField(
                          "Area",
                          Icons.map_outlined,
                          (v) => area = v,
                          (v) => v!.isEmpty ? 'Area?' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Role Selection (Backend Enum Compatibility)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "I want to:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Hire"),
                          value: "POSTER",
                          groupValue: initialRole,
                          onChanged: (v) => setState(() => initialRole = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Work"),
                          value: "SEEKER",
                          groupValue: initialRole,
                          onChanged: (v) => setState(() => initialRole = v!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  _buildButton('SIGN UP', _handleSignup),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // UI Helpers (Same as Login for consistency)
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
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryBlue, size: 20),
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
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
            ? const CircularProgressIndicator(color: Colors.white)
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
