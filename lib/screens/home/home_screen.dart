import 'package:flutter/material.dart';
import '../../models/score.dart';
import '../../repository/score_repository.dart';
import '../add_score/add_score_screen.dart';
import 'widgets/item_score.dart';

class HomeScreen extends StatefulWidget {
  final ScoreRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบข้อมูลคะแนนนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              await widget.repository.deleteScore(id);
              if (mounted) {
                Navigator.of(ctx).pop();
                setState(() {});
              }
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Score Tracker'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Score>>(
        future: widget.repository.getScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ยังไม่มีข้อมูลคะแนนสอบ'));
          }

          final scores = snapshot.data!;
          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final scoreItem = scores[index];
              return ItemScore(
                score: scoreItem,
                onEdit: () {
                  // ส่งข้อมูล scoreItem ไปเพื่อทำการแก้ไข
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddScoreScreen(
                        repository: widget.repository,
                        scoreToEdit: scoreItem,
                      ),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(scoreItem.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScoreScreen(repository: widget.repository),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}