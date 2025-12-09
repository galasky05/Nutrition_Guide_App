import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Jika berhasil, pindah ke halaman utama
      Navigator.pushReplacementNamed(context, "/main");

    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";

      // Error code terbaru dari Firebase Auth
      if (e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        message = "Email atau password salah";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid";
      } else if (e.code == 'user-disabled') {
        message = "Akun ini telah dinonaktifkan";
      } else if (e.code == 'too-many-requests') {
        message = "Terlalu banyak percobaan. Coba lagi nanti";
      } else if (e.code == 'user-not-found') {
        message = "Email tidak ditemukan";
      } else if (e.code == 'wrong-password') {
        message = "Password salah";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: const Color(0xFF3E6A49)),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEFD8), // sama dengan splash screen
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ICON - konsisten dengan splash
              const Icon(
                Icons.eco,
                color: Color(0xFF6E9B6A),
                size: 100,
              ),

              const SizedBox(height: 24),

              // TITLE
              const Text(
                "NUTRITION GUIDE APP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E6A49),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // SUBTITLE
              const Text(
                "Selamat Datang Kembali!",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6E9B6A),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 48),

              // EMAIL FIELD
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6E9B6A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6E9B6A), width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD FIELD
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: "Kata Sandi",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6E9B6A)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF6E9B6A),
                    ),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6E9B6A), width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),

              const SizedBox(height: 32),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E9B6A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: loading ? null : login,
                  child: loading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text("MASUK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),

              const SizedBox(height: 24),

              // DAFTAR
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/register"),
                child: RichText(
                  text: const TextSpan(
                    text: "Belum punya akun? ",
                    style: TextStyle(color: Color(0xFF3E6A49), fontSize: 15),
                    children: [
                      TextSpan(
                        text: "Daftar Sekarang",
                        style: TextStyle(color: Color(0xFF6E9B6A), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // DIVIDER
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("ATAU", style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                  Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
                ],
              ),

              const SizedBox(height: 32),

              // GOOGLE LOGIN BUTTON
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6E9B6A), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.g_mobiledata, size: 32, color: Color(0xFF6E9B6A)),
                    SizedBox(width: 8),
                    Text("Masuk dengan Google", style: TextStyle(color: Color(0xFF3E6A49), fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}