import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  void _listenToUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataSubscription = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists) setState(() { userData = doc.data(); loading = false; });
      });
    }
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }

  String activityToIndo(String lvl) {
    switch (lvl) {
      case "Sedentary": return "Tidak Aktif";
      case "Light": return "Ringan (1-3x/minggu)";
      case "Moderate": return "Sedang (3-5x/minggu)";
      case "Active": return "Tinggi (6-7x/minggu)";
      case "Very Active": return "Sangat Aktif";
      default: return lvl;
    }
  }

  double calculateBMI() => userData!['weight'] / ((userData!['height'] / 100) * (userData!['height'] / 100));

  String getBMIStatus(double bmi) {
    if (bmi < 18.5) return "Kurang";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Berlebih";
    return "Obesitas";
  }

  Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Color(0xFF6E9B6A);
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _card(Widget child) => Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Color(0xFF3E6A49).withOpacity(0.08), blurRadius: 10, offset: Offset(0, 4))],
    ),
    child: child,
  );

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(backgroundColor: Color(0xFFDCEFD8), body: Center(child: CircularProgressIndicator(color: Color(0xFF6E9B6A))));

    double bmi = calculateBMI();
    String bmiStatus = getBMIStatus(bmi);
    Color bmiColor = getBMIColor(bmi);

    return Scaffold(
      backgroundColor: Color(0xFFDCEFD8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 4))]),
                      child: CircleAvatar(radius: 48, backgroundColor: Colors.white.withOpacity(0.3), child: Text(userData!['name'][0].toUpperCase(), style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                    SizedBox(height: 14),
                    Text(userData!['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                    SizedBox(height: 4),
                    Text(userData!['email'], style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BMI Card
                    _card(Column(
                      children: [
                        Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: bmiColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.monitor_heart, color: bmiColor, size: 22)), SizedBox(width: 12), Text("Indeks Massa Tubuh (BMI)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49)))]),
                        SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                          Column(children: [Text("${bmi.toStringAsFixed(1)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: bmiColor)), SizedBox(height: 4), Text("BMI", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500))]),
                          Container(height: 50, width: 1.5, color: Colors.grey[300]),
                          Column(children: [Text(bmiStatus, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bmiColor)), SizedBox(height: 4), Text("Status", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500))]),
                        ]),
                      ],
                    )),

                    Padding(padding: EdgeInsets.only(left: 4, bottom: 12), child: Text("Informasi Pribadi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49)))),

                    // Data Fisik
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Icon(Icons.accessibility_new, color: Color(0xFF6E9B6A), size: 20), SizedBox(width: 8), Text("Data Fisik", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49)))]),
                        SizedBox(height: 16),
                        Row(children: [Expanded(child: _infoTile(Icons.cake_outlined, "${userData!['age']}", "Umur (tahun)")), SizedBox(width: 12), Expanded(child: _infoTile(Icons.wc_outlined, userData!['gender'] == "Male" || userData!['gender'] == "L" ? "Laki-laki" : "Perempuan", "Gender"))]),
                        SizedBox(height: 12),
                        Row(children: [Expanded(child: _infoTile(Icons.height_outlined, "${userData!['height']}", "Tinggi (cm)")), SizedBox(width: 12), Expanded(child: _infoTile(Icons.monitor_weight_outlined, "${userData!['weight']}", "Berat (kg)"))]),
                      ],
                    )),

                    // Aktivitas
                    _card(Row(children: [Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.fitness_center, color: Color(0xFF6E9B6A), size: 24)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Tingkat Aktivitas Fisik", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)), SizedBox(height: 4), Text(activityToIndo(userData!['activityLevel']), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49)))]))])),

                    // Riwayat
                    _card(InkWell(
                      onTap: () => Navigator.pushNamed(context, '/history'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Row(children: [Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.history, color: Color(0xFF6E9B6A), size: 24)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Riwayat Konsumsi", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))), SizedBox(height: 2), Text("Lihat histori makanan Anda", style: TextStyle(fontSize: 12, color: Colors.grey[600]))])), Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6E9B6A))])),
                    )),

                    SizedBox(height: 8),

                    // Buttons
                    Row(children: [
                      Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6E9B6A), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen())), icon: Icon(Icons.edit, size: 18), label: Text("Edit Profil", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))),
                      SizedBox(width: 12),
                      Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2), onPressed: logout, icon: Icon(Icons.logout, size: 18), label: Text("Logout", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))),
                    ]),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) => Container(
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    decoration: BoxDecoration(color: Color(0xFFF5F9F4), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF6E9B6A).withOpacity(0.1), width: 1)),
    child: Column(children: [Icon(icon, size: 26, color: Color(0xFF6E9B6A)), SizedBox(height: 8), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))), SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center)]),
  );
}