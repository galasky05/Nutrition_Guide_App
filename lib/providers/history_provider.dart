import 'package:flutter/material.dart';
import '../models/food_model.dart';

class HistoryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _history = [];

  List<Map<String, dynamic>> get history => _history;

  /// Tambah satu catatan history
  void addHistory({
    required List<Food> foods,
  }) {
    final int totalCalories = foods.fold(0, (sum, f) => sum + f.calories);

    _history.add({
      "date": DateTime.now(),
      "foods": List<Food>.from(foods),
      "totalCalories": totalCalories,
    });

    notifyListeners();
  }

  /// Hapus satu history berdasarkan index
  void deleteHistory(int index) {
    _history.removeAt(index);
    notifyListeners();
  }

  /// Kosongkan semua history
  void clearAll() {
    _history.clear();
    notifyListeners();
  }
}
