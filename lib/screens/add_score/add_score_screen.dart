import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/score.dart';
import '../../repository/score_repository.dart';
import '../home/home_screen.dart';

class AddScoreScreen extends StatefulWidget {
  final ScoreRepository repository;
  final Score? scoreToEdit; // ถ้ามีค่าแสดงว่าเป็นโหมดแก้ไข (Update)

  const AddScoreScreen({
    super.key,
    required this.repository,
    this.scoreToEdit,
  });

  @override
  State<AddScoreScreen> createState() => _AddScoreScreenState();
}

class _AddScoreScreenState extends State<AddScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _studentIdController;
  late TextEditingController _scoreController;
  String? _selectedSubject;

  final List<String> _subjects = ['คณิตศาสตร์', 'วิทยาศาสตร์', 'ภาษาอังกฤษ'];

  @override
  void initState() {
    super.initState();
    // นำข้อมูลเดิมมาใส่ใน ฟอร์ม หากอยู่ในโหมดแก้ไข
    _studentIdController = TextEditingController(text: widget.scoreToEdit?.studentId ?? '');
    _scoreController = TextEditingController(text: widget.scoreToEdit?.score.toString() ?? '');
    _selectedSubject = widget.scoreToEdit?.subject;
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (widget.scoreToEdit == null) {
        // --- โหมดเพิ่มข้อมูลใหม่ ---
        final newScore = Score(
          studentId: _studentIdController.text.trim(),
          score: int.parse(_scoreController.text.trim()),
          subject: _selectedSubject!,
          createdAt: DateTime.now(),
        );
        await widget.repository.insertScore(newScore);
      } else {
        // --- โหมดแก้ไขข้อมูลเดิม ---
        final updatedScore = Score(
          id: widget.scoreToEdit!.id,
          studentId: _studentIdController.text.trim(),
          score: int.parse(_scoreController.text.trim()),
          subject: _selectedSubject!,
          createdAt: widget.scoreToEdit!.createdAt, // ใช้วันเวลาเดิม หรือปรับเป็น DateTime.now() ได้
        );
        await widget.repository.updateScore(updatedScore);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(repository: widget.repository),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.scoreToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขคะแนนสอบ' : 'เพิ่มคะแนนสอบ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextFormField รหัสนักศึกษา
              TextFormField(
                controller: _studentIdController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'รหัสนักศึกษา',
                  counterText: '', // ซ่อน Counter ตัวนับจำนวนตัวอักษร
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกรหัสนักศึกษา';
                  }
                  if (value.trim().length != 10) {
                    return 'รหัสนักศึกษาต้องมี 10 หลัก';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TextFormField คะแนนที่ได้
              TextFormField(
                controller: _scoreController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'คะแนนที่ได้',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกคะแนน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // DropdownButtonFormField รายวิชา
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                items: _subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSubject = value),
                decoration: const InputDecoration(
                  labelText: 'รายวิชา',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเลือกรายวิชา';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isEditing ? 'อัปเดตข้อมูล' : 'บันทึกข้อมูล',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}