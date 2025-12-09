import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String gender = "L";
  String activityLevel = "Sedentary";
  bool loading = false;
  bool obscurePassword = true;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': gender,
        'height': int.parse(heightController.text.trim()),
        'weight': int.parse(weightController.text.trim()),
        'activityLevel': activityLevel,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil! Silakan login.'), backgroundColor: const Color(0xFF6E9B6A)),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red[700]),
      );
    }

    setState(() => loading = false);
  }

  Widget _buildCard(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure && obscurePassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6E9B6A), fontSize: 12),
        prefixIcon: Icon(icon, color: Color(0xFF6E9B6A), size: 18),
        suffixIcon: obscure ? IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Color(0xFF6E9B6A), size: 18),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ) : null,
        filled: true,
        fillColor: const Color(0xFFF5F9F4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6E9B6A), width: 2)),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEFD8),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header dengan gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_add_alt_1, size: 44, color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text("Daftar Akun Baru", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text("Mulai perjalanan sehat Anda", style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Card Informasi Akun
                      _buildCard(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.account_circle, color: Color(0xFF6E9B6A), size: 18),
                              ),
                              SizedBox(width: 8),
                              Text("Informasi Akun", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))),
                            ],
                          ),
                          SizedBox(height: 12),
                          _buildTextField(nameController, 'Nama Lengkap', Icons.person_outline, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                          SizedBox(height: 10),
                          _buildTextField(emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.contains('@') ? null : 'Email tidak valid'),
                          SizedBox(height: 10),
                          _buildTextField(passwordController, 'Kata Sandi', Icons.lock_outline, obscure: true, validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null),
                        ],
                      )),

                      // Card Informasi Fisik
                      _buildCard(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.accessibility_new, color: Color(0xFF6E9B6A), size: 18),
                              ),
                              SizedBox(width: 8),
                              Text("Informasi Fisik", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(ageController, 'Umur', Icons.cake_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Wajib diisi" : null)),
                              SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField(
                                  value: gender,
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    labelStyle: const TextStyle(color: Color(0xFF6E9B6A), fontSize: 12),
                                    prefixIcon: Icon(Icons.wc, color: Color(0xFF6E9B6A), size: 18),
                                    filled: true,
                                    fillColor: const Color(0xFFF5F9F4),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  ),
                                  items: [
                                    DropdownMenuItem(value: "L", child: Text("Laki-laki", style: TextStyle(fontSize: 12))),
                                    DropdownMenuItem(value: "P", child: Text("Perempuan", style: TextStyle(fontSize: 12))),
                                  ],
                                  onChanged: (v) => setState(() => gender = v.toString()),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(heightController, 'Tinggi (cm)', Icons.height, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Wajib diisi" : null)),
                              SizedBox(width: 10),
                              Expanded(child: _buildTextField(weightController, 'Berat (kg)', Icons.monitor_weight_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Wajib diisi" : null)),
                            ],
                          ),
                        ],
                      )),

                      // Card Aktivitas
                      _buildCard(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Icon(Icons.fitness_center, color: Color(0xFF6E9B6A), size: 18),
                              ),
                              SizedBox(width: 8),
                              Text("Tingkat Aktivitas", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))),
                            ],
                          ),
                          SizedBox(height: 12),
                          DropdownButtonFormField(
                            value: activityLevel,
                            decoration: InputDecoration(
                              labelText: 'Pilih Aktivitas',
                              labelStyle: const TextStyle(color: Color(0xFF6E9B6A), fontSize: 12),
                              prefixIcon: Icon(Icons.directions_run, color: Color(0xFF6E9B6A), size: 18),
                              filled: true,
                              fillColor: const Color(0xFFF5F9F4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                            ),
                            items: [
                              DropdownMenuItem(value: "Sedentary", child: Text("Tidak Aktif", style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: "Light", child: Text("Ringan (1-3x/minggu)", style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: "Moderate", child: Text("Sedang (3-5x/minggu)", style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: "Active", child: Text("Tinggi (6-7x/minggu)", style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: "Very Active", child: Text("Sangat Aktif (2x/hari)", style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (v) => setState(() => activityLevel = v.toString()),
                          ),
                        ],
                      )),

                      // Button Daftar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E9B6A),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: Color(0xFF6E9B6A).withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: loading ? null : registerUser,
                          child: loading
                              ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 20),
                                    SizedBox(width: 8),
                                    Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Link Login
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text.rich(
                          TextSpan(
                            text: "Sudah punya akun? ",
                            style: TextStyle(color: Color(0xFF3E6A49), fontSize: 13),
                            children: [TextSpan(text: "Masuk di sini", style: TextStyle(color: Color(0xFF6E9B6A), fontWeight: FontWeight.bold, decoration: TextDecoration.underline))],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}