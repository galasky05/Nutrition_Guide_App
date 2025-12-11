import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/meal_planner_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;
  bool loading = true;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
  }

  void _listenToUserData() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    
    // Listen ke perubahan data user secara real-time
    _userDataSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          loading = false;
        });

        // Update target kalori ke provider setiap ada perubahan
        if (userData != null) {
          final calories = calculateCalories().toInt();
          if (mounted) {
            Provider.of<MealPlannerProvider>(context, listen: false)
                .setTargetCalories(calories);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFDCEFD8),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6E9B6A),
          ),
        ),
      );
    }

    final name = userData!["name"];
    final calories = calculateCalories().toInt();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6E9B6A),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.eco, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              "Halo, $name",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFDCEFD8),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6E9B6A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3E6A49).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.local_fire_department, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Target Kalori Harian",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$calories kcal",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Row(
              children: const [
                Icon(Icons.restaurant, color: Color(0xFF3E6A49), size: 22),
                SizedBox(width: 8),
                Text(
                  "Rekomendasi Makanan Sehat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E6A49),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _FoodCard(title: "Salad Sayur", calories: 150),
                  _FoodCard(title: "Oatmeal", calories: 300),
                  _FoodCard(title: "Ayam Rebus", calories: 250),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Row(
              children: const [
                Icon(Icons.apps, color: Color(0xFF3E6A49), size: 22),
                SizedBox(width: 8),
                Text(
                  "Menu Cepat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E6A49),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _MenuButton(
                    icon: Icons.search,
                    title: "Search Food",
                    onTap: () => Navigator.pushNamed(context, "/search"),
                  ),
                  _MenuButton(
                    icon: Icons.calculate,
                    title: "Calculator",
                    onTap: () => Navigator.pushNamed(context, "/calorie"),
                  ),
                  _MenuButton(
                    icon: Icons.restaurant_menu,
                    title: "Meal Planner",
                    onTap: () => Navigator.pushNamed(context, "/mealPlanner"),
                  ),
                  _MenuButton(
                    icon: Icons.history,
                    title: "History",
                    onTap: () {},
                  ),
                  _MenuButton(
                    icon: Icons.person,
                    title: "Profile",
                    onTap: () {},
                  ),
                ],
              ),
            )
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
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3E6A49).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E6A49),
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.local_fire_department, size: 14, color: Color(0xFF6E9B6A)),
              const SizedBox(width: 4),
              Text(
                "$calories kcal",
                style: const TextStyle(
                  color: Color(0xFF6E9B6A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuButton({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF3E6A49).withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF6E9B6A)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E6A49),
              ),
            ),
          ],
        ),
      ),
    );
  }
}