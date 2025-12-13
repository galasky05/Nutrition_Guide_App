import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userData = doc.data();
      loading = false;
    });
  }

  double calculateCalories() {
    if (userData == null) return 0;

    final age = userData!["age"];
    final height = userData!["height"];
    final weight = userData!["weight"];
    final gender = userData!["gender"];
    final activity = userData!["activityLevel"];

    double bmr = 0;
    if (gender == "Male") {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    Map<String, double> factor = {
      "Sedentary": 1.2,
      "Light": 1.375,
      "Moderate": 1.55,
      "Active": 1.725,
      "Very Active": 1.9
    };

    return bmr * (factor[activity] ?? 1.2);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFDCEFD8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6E9B6A))),
      );
    }

    final name = userData!["name"];
    final calories = calculateCalories().toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFDCEFD8),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Hero Header
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3E6A49).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Avatar
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                            ),
                            child: Icon(Icons.eco, color: Colors.white, size: 32),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Calorie Target Card
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange[300],
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Target Kalori Harian",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "$calories",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    letterSpacing: -1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    "kcal",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Section Title
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, color: Color(0xFF3E6A49), size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Rekomendasi Makanan Sehat",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E6A49),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Food Cards Horizontal Scroll
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _FoodCard(title: "Salad Sayur", calories: 150),
                        _FoodCard(title: "Oatmeal", calories: 300),
                        _FoodCard(title: "Ayam Rebus", calories: 250),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Quick Access
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Row(
                      children: [
                        Icon(Icons.dashboard, color: Color(0xFF3E6A49), size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Akses Cepat",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E6A49),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Access Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _QuickAccessCard(
                        icon: Icons.search,
                        title: "Cari Makanan",
                        gradient: [Color(0xFF6E9B6A), Color(0xFF5A8256)],
                        onTap: () => Navigator.pushNamed(context, "/search"),
                      ),
                      _QuickAccessCard(
                        icon: Icons.calculate,
                        title: "Kalkulator",
                        gradient: [Color(0xFF5A8256), Color(0xFF4A7246)],
                        onTap: () => Navigator.pushNamed(context, "/calorie"),
                      ),
                      _QuickAccessCard(
                        icon: Icons.history,
                        title: "Riwayat",
                        gradient: [Color(0xFF4A7246), Color(0xFF3E6A49)],
                        onTap: () => Navigator.pushNamed(context, "/history"),
                      ),
                      _QuickAccessCard(
                        icon: Icons.person,
                        title: "Profil",
                        gradient: [Color(0xFF3E6A49), Color(0xFF2D5236)],
                        onTap: () => Navigator.pushNamed(context, "/profile"),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String title;
  final int calories;

  const _FoodCard({required this.title, required this.calories});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF8FBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3E6A49).withOpacity(0.12),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF6E9B6A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.restaurant, color: Color(0xFF6E9B6A), size: 24),
            ),
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E6A49),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.local_fire_department, size: 16, color: Colors.orange[700]),
                SizedBox(width: 4),
                Text(
                  "$calories kcal",
                  style: TextStyle(
                    color: Color(0xFF6E9B6A),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: Colors.white),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}