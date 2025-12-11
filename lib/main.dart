import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/search_food_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/history_screen.dart';
import 'widgets/empty_screen.dart';


import 'main_navigation.dart';

import 'providers/meal_planner_provider.dart';
import 'providers/history_provider.dart';    

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(                     // <<< Ubah jadi MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => MealPlannerProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()), // <<< WAJIB
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) => const SplashScreen(),
          "/login": (context) => LoginScreen(),
          "/register": (context) => RegisterScreen(),
          "/main": (context) => const MainNavigation(),

          "/foodSearch": (context) => const SearchFoodScreen(),
          "/mealPlanner": (context) => const MealPlannerScreen(),
          "/history": (context) => const HistoryScreen(),
          "/historyDetail": (context) => const EmptyScreen(), 


        },
      ),
    );
  }
}
