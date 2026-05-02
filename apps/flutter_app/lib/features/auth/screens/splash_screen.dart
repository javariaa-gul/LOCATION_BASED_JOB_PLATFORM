// screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 180, height: 180, 
                  errorBuilder: (c, e, s) => const Icon(Icons.handyman, size: 100)),
                const SizedBox(height: 24),
                const Text('APKA HUNAR', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black)),
                const SizedBox(height: 12),
                const Text('"Hunar Mand Awam, Khushhaal Pakistan"', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF666666))),
                const SizedBox(height: 40),
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5AC8E8))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}