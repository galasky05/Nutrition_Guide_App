import 'package:flutter/material.dart';
import '../models/food_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final List<Food> foods;
  final int totalCalories;
  final DateTime date;

  const HistoryDetailScreen({super.key, required this.foods, required this.totalCalories, required this.date});

  String _getRelativeDate() {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Hari ini";
    if (diff == 1) return "Kemarin";
    if (diff < 7) return "$diff hari lalu";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final totalProtein = foods.fold<double>(0, (sum, f) => sum + f.protein);
    final totalCarbs = foods.fold<double>(0, (sum, f) => sum + f.carbs);
    final totalFat = foods.fold<double>(0, (sum, f) => sum + f.fat);

    return Scaffold(
      backgroundColor: Color(0xFFDCEFD8),
      appBar: AppBar(
        backgroundColor: Color(0xFF6E9B6A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Detail Riwayat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text("${_getRelativeDate()} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}", style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Color(0xFF3E6A49).withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, size: 40, color: Colors.orange[300]),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$totalCalories", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                        Text("kalori", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _summaryItem(Icons.fitness_center, "${totalProtein.toStringAsFixed(1)}g", "Protein"),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                    _summaryItem(Icons.grain, "${totalCarbs.toStringAsFixed(1)}g", "Karbo"),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                    _summaryItem(Icons.water_drop, "${totalFat.toStringAsFixed(1)}g", "Lemak"),
                  ],
                ),
              ],
            ),
          ),

          // Header List
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(children: [Icon(Icons.restaurant_menu, color: Color(0xFF3E6A49), size: 22), SizedBox(width: 8), Text("Daftar Makanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))), Spacer(), Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text("${foods.length} item", style: TextStyle(fontSize: 12, color: Color(0xFF3E6A49), fontWeight: FontWeight.w600)))]),
          ),

          // Food List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final f = foods[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, Color(0xFFF8FBF7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Color(0xFF3E6A49).withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Color(0xFF6E9B6A).withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))]),
                              child: Icon(Icons.restaurant, color: Colors.white, size: 22),
                            ),
                            SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(f.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49)), maxLines: 2, overflow: TextOverflow.ellipsis), SizedBox(height: 6), Row(children: [Icon(Icons.local_fire_department, size: 16, color: Colors.orange[700]), SizedBox(width: 4), Text("${f.calories}", style: TextStyle(fontSize: 18, color: Colors.orange[700], fontWeight: FontWeight.bold)), Text(" kcal", style: TextStyle(fontSize: 13, color: Colors.grey[600]))])])),
                          ],
                        ),
                        SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          decoration: BoxDecoration(color: Color(0xFFF0F7EE), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF6E9B6A).withOpacity(0.2), width: 1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _nutrientBadge("Protein", "${f.protein}g", Icons.fitness_center, Color(0xFF3B82F6)),
                              Container(width: 1.5, height: 32, color: Colors.grey[300]),
                              _nutrientBadge("Karbo", "${f.carbs}g", Icons.grain, Color(0xFFF59E0B)),
                              Container(width: 1.5, height: 32, color: Colors.grey[300]),
                              _nutrientBadge("Lemak", "${f.fat}g", Icons.water_drop, Color(0xFFEF4444)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String label) => Column(children: [Icon(icon, size: 20, color: Colors.white), SizedBox(height: 6), Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)))]);

  Widget _nutrientBadge(String label, String value, IconData icon, Color color) => Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 20, color: color), SizedBox(height: 6), Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))), SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600]))]));
}