import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/food_model.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Makanan"),
        backgroundColor: Colors.green,
        actions: [
          if (historyProvider.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                historyProvider.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Semua riwayat dihapus")),
                );
              },
            ),
        ],
      ),

      body: historyProvider.history.isEmpty
          ? const Center(
              child: Text(
                "Belum ada riwayat",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: historyProvider.history.length,
              itemBuilder: (context, index) {
                final item = historyProvider.history[index];
                final List<Food> foods = item["foods"];
                final int total = item["totalCalories"];
                final DateTime date = item["date"];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailScreen(
                            foods: foods,
                            totalCalories: total,
                            date: date,
                          ),
                        ),
                      );
                    },
                    title: Text(
                      "Total Kalori: $total kcal",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      "${foods.length} makanan\n${date.toLocal()}",
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        historyProvider.deleteHistory(index);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
