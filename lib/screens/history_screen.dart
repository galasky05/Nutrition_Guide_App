import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/food_model.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Pagi";
    if (hour < 15) return "Siang";
    if (hour < 18) return "Sore";
    return "Malam";
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return "Hari ini";
    if (diff == 1) return "Kemarin";
    if (diff < 7) return "$diff hari lalu";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final totalItems = historyProvider.history.length;
    final totalCaloriesToday = historyProvider.history.where((h) => DateTime.now().difference(h["date"]).inDays == 0).fold<int>(0, (sum, item) => sum + (item["totalCalories"] as int));

    return Scaffold(
      backgroundColor: Color(0xFFDCEFD8),
      body: CustomScrollView(
        slivers: [
          // Custom AppBar dengan statistik
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF6E9B6A),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [Icon(Icons.history, size: 26), SizedBox(width: 10), Text("Riwayat", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))]),
                        SizedBox(height: 6),
                        Text("Selamat ${_getGreeting()}! 👋", style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _statCard("$totalItems", "Total Catatan", Icons.receipt_long)),
                            SizedBox(width: 10),
                            Expanded(child: _statCard("$totalCaloriesToday", "Kalori Hari Ini", Icons.local_fire_department)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (historyProvider.history.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_sweep_rounded),
                  tooltip: "Hapus Semua",
                  onPressed: () => _showDeleteAllDialog(context, historyProvider),
                ),
            ],
          ),

          // Content
          historyProvider.history.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Color(0xFF6E9B6A).withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.restaurant_menu, size: 64, color: Color(0xFF6E9B6A).withOpacity(0.5)),
                        ),
                        SizedBox(height: 20),
                        Text("Belum Ada Riwayat", style: TextStyle(fontSize: 18, color: Color(0xFF3E6A49), fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Mulai catat makananmu sekarang!", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = historyProvider.history[index];
                        final List<Food> foods = item["foods"];
                        final int total = item["totalCalories"];
                        final DateTime date = item["date"];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.white, Color(0xFFF5F9F4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Color(0xFF3E6A49).withOpacity(0.1), blurRadius: 12, offset: Offset(0, 4))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryDetailScreen(foods: foods, totalCalories: total, date: date))),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6E9B6A), Color(0xFF5A8256)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0xFF6E9B6A).withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))]),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.restaurant, color: Colors.white, size: 20), SizedBox(height: 2), Text("${foods.length}", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [Icon(Icons.local_fire_department, size: 18, color: Colors.orange[700]), SizedBox(width: 6), Text("$total", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E6A49))), Text(" kcal", style: TextStyle(fontSize: 14, color: Colors.grey[600]))]),
                                          SizedBox(height: 6),
                                          Row(children: [Icon(Icons.access_time, size: 14, color: Colors.grey[500]), SizedBox(width: 4), Text(_getRelativeDate(date), style: TextStyle(fontSize: 13, color: Colors.grey[600])), Text(" • ${date.hour}:${date.minute.toString().padLeft(2, '0')}", style: TextStyle(fontSize: 13, color: Colors.grey[500]))]),
                                        ],
                                      ),
                                    ),
                                    IconButton(icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: 24), onPressed: () => _showDeleteDialog(context, historyProvider, index)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: historyProvider.history.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) => Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)),
    child: Row(children: [Icon(icon, size: 20, color: Colors.white), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.9)), maxLines: 1, overflow: TextOverflow.ellipsis)]))]),
  );

  void _showDeleteDialog(BuildContext context, HistoryProvider provider, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange), SizedBox(width: 10), Text("Hapus Riwayat?", style: TextStyle(color: Color(0xFF3E6A49), fontWeight: FontWeight.bold, fontSize: 18))]),
        content: Text("Riwayat ini akan dihapus permanen", style: TextStyle(color: Colors.grey[700])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)), onPressed: () { provider.deleteHistory(index); Navigator.pop(ctx); }, child: Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red), SizedBox(width: 10), Text("Hapus Semua?", style: TextStyle(color: Color(0xFF3E6A49), fontWeight: FontWeight.bold, fontSize: 18))]),
        content: Text("Semua riwayat akan dihapus permanen dan tidak dapat dikembalikan", style: TextStyle(color: Colors.grey[700])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)), onPressed: () { provider.clearAll(); Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✓ Semua riwayat dihapus"), backgroundColor: Color(0xFF6E9B6A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); }, child: Text("Hapus Semua", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}