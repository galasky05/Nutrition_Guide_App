import 'package:flutter/material.dart';
import '../models/food_model.dart';
import 'history_provider.dart'; // ⬅️ Tambahkan import ini

class MealPlannerProvider with ChangeNotifier {
  final List<Food> _selectedFoods = [];
  int _targetCalories = 2000; // Default value

  List<Food> get selectedFoods => _selectedFoods;

  int get totalCalories {
    return _selectedFoods.fold(0, (sum, food) => sum + food.calories);
  }

  int get targetCalories => _targetCalories;

  // Set target kalori dari HomeScreen
  void setTargetCalories(int calories) {
    _targetCalories = calories;
    notifyListeners();
  }

  // Menambah makanan
  void addFood(Food food) {
    _selectedFoods.add(food);
    notifyListeners();
  }

  // Menghapus makanan
  void removeFood(Food food) {
    _selectedFoods.remove(food);
    notifyListeners();
  }

  // Menghapus semua makanan
  void clearAll() {
    _selectedFoods.clear();
    notifyListeners();
  }

  // ⬇⬇⬇ TAMBAHKAN FUNGSI INI ⬇⬇⬇
  void saveToHistory(HistoryProvider historyProvider) {
    historyProvider.addHistory(foods: List<Food>.from(_selectedFoods));
  }
}
