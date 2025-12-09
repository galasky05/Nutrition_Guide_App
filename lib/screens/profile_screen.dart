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
  List<Map<String, dynamic>> recentHistory = [];
  bool loading = true;
  StreamSubscription? _userDataSubscription;
  StreamSubscription? _historySubscription;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  void _listenToUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Listen ke perubahan data user secara real-time
      _userDataSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>?;
            loading = false;
          });
        }
      });

      // Listen ke perubahan history secara real-time
      _historySubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('consumption_history')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          recentHistory = snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList();
        });
      });
    }
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    _historySubscription?.cancel();
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

  double calculateBMI() {
    double height = userData!['height'] / 100;
    return userData!['weight'] / (height * height);
  }

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

  Widget _buildCard(Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: child,
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    double bmi = calculateBMI();
    String bmiStatus = getBMIStatus(bmi);
    Color bmiColor = getBMIColor(bmi);

    return Scaffold(
      backgroundColor: Color(0xFFDCEFD8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Gradient
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(userData!['name'][0].toUpperCase(), style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10),
                    Text(userData!['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(userData!['email'], style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // BMI Card
                    _buildCard(Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(color: bmiColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.monitor_heart, color: bmiColor, size: 18),
                            ),
                            SizedBox(width: 8),
                            Text("Indeks Massa Tubuh", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [Text("${bmi.toStringAsFixed(1)}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: bmiColor)), Text("BMI", style: TextStyle(fontSize: 11, color: Colors.grey[600]))]),
                            Container(height: 40, width: 1, color: Colors.grey[300]),
                            Column(children: [Text(bmiStatus, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: bmiColor)), Text("Status", style: TextStyle(fontSize: 11, color: Colors.grey[600]))]),
                          ],
                        ),
                      ],
                    )),

                    // Info Fisik
                    _buildCard(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.accessibility_new, color: Color(0xFF6E9B6A), size: 18)),
                            SizedBox(width: 8),
                            Text("Data Fisik", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _infoTile(Icons.cake, "${userData!['age']} tahun", "Umur")),
                            SizedBox(width: 8),
                            Expanded(child: _infoTile(Icons.wc, userData!['gender'] == "L" ? "Laki-laki" : "Perempuan", "Gender")),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _infoTile(Icons.height, "${userData!['height']} cm", "Tinggi")),
                            SizedBox(width: 8),
                            Expanded(child: _infoTile(Icons.monitor_weight, "${userData!['weight']} kg", "Berat")),
                          ],
                        ),
                      ],
                    )),

                    // Aktivitas
                    _buildCard(Row(
                      children: [
                        Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.fitness_center, color: Color(0xFF6E9B6A), size: 20)),
                        SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Tingkat Aktivitas", style: TextStyle(fontSize: 11, color: Colors.grey[600])), Text(activityToIndo(userData!['activityLevel']), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3E6A49)))])),
                      ],
                    )),

                    // Riwayat Konsumsi
                    _buildCard(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.history, color: Color(0xFF6E9B6A), size: 18)), SizedBox(width: 8), Text("Riwayat Konsumsi", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49)))]),
                            TextButton(onPressed: () {}, child: Text("Lihat Semua", style: TextStyle(fontSize: 11, color: Color(0xFF6E9B6A)))),
                          ],
                        ),
                        recentHistory.isEmpty ? Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("Belum ada riwayat", style: TextStyle(color: Colors.grey, fontSize: 12)))) : Column(children: recentHistory.map((item) => _historyItem(item)).toList()),
                      ],
                    )),

                    // Buttons
                    Row(
                      children: [
                        Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6E9B6A), padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfileScreen()),
                        );
                        }, icon: Icon(Icons.edit, size: 16), label: Text("Edit Profil", style: TextStyle(fontSize: 13)))),
                        SizedBox(width: 10),
                        Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: logout, icon: Icon(Icons.logout, size: 16), label: Text("Logout", style: TextStyle(fontSize: 13)))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Color(0xFFF5F9F4), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [Icon(icon, size: 20, color: Color(0xFF6E9B6A)), SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600]))]),
    );
  }

  Widget _historyItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Color(0xFFF5F9F4), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.restaurant, size: 16, color: Color(0xFF6E9B6A))),
          SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['foodName'] ?? "Makanan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), Text("${item['calories'] ?? 0} kal • ${item['protein'] ?? 0}g protein", style: TextStyle(fontSize: 10, color: Colors.grey[600]))])),
          Text(item['date'] ?? "Hari ini", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}