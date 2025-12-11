import 'package:flutter/material.dart';
import '../models/food_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final List<Food> foods;
  final int totalCalories;
  final DateTime date;

  const HistoryDetailScreen({
    super.key,
    required this.foods,
    required this.totalCalories,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Riwayat"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tanggal: ${date.toLocal()}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Total Kalori: $totalCalories kcal",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),

            const Text(
              "Daftar Makanan:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final f = foods[index];

                  return Card(
                    child: ListTile(
                      title: Text(f.name),
                      subtitle: Text(
                        "Kalori: ${f.calories} kcal\n"
                        "Protein: ${f.protein}g | Karbo: ${f.carbs}g | Lemak: ${f.fat}g",
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
