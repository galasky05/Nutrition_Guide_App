import 'package:flutter/material.dart';
import '../models/food_model.dart';

class MealPlannerProvider with ChangeNotifier {
  final List<Food> _selectedFoods = [];
  int _targetCalories = 2000; // Default value

  List<Food> get selectedFoods => _selectedFoods;

  int get totalCalories {
    return _selectedFoods.fold(0, (sum, food) => sum + food.calories);
  }

  int get targetCalories => _targetCalories;

  // Method untuk set target kalori dari HomeScreen
  void setTargetCalories(int calories) {
    _targetCalories = calories;
    notifyListeners();
  }

  void addFood(Food food) {
    _selectedFoods.add(food);
    notifyListeners();
  }

  void removeFood(Food food) {
    _selectedFoods.remove(food);
    notifyListeners();
  }

  void clearAll() {
    _selectedFoods.clear();
    notifyListeners();
  }
}