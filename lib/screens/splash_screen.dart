import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Tampilkan splash selama 3 detik, lalu pindah ke login
    Future.microtask(() {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFDCEFD8),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 140, color: Color(0xFF6E9B6A)),
            SizedBox(height: 20),
            Text(
              "NUTRITION GUIDE APP",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E6A49),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
