import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_food_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/meal_planner_screen.dart';


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final screens = [
    HomeScreen(),
    SearchFoodScreen(),
    ProfileScreen(),
    MealPlannerScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[500],
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Search"),

          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
