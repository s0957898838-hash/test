import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/score.dart';

class ItemScore extends StatelessWidget {
  final Score score;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemScore({
    super.key,
    required this.score,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(score.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // ด้านซ้าย: ข้อมูลนักศึกษา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รหัส: ${score.studentId}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('วิชา: ${score.subject}'),
                  Text(
                    'บันทึกเมื่อ: $formattedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // ด้านขวา: คะแนนสอบขนาดใหญ่ + ปุ่มแก้ไข + ปุ่มลบ
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${score.score}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 8),
                // ปุ่มแก้ไข (Edit)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: onEdit,
                ),
                // ปุ่มลบ (Delete)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}