class Score {
  final int? id;
  final String studentId;
  final int score;
  final String subject;
  final DateTime createdAt;

  Score({
    this.id,
    required this.studentId,
    required this.score,
    required this.subject,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'score': score,
      'subject': subject,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      id: map['id'],
      studentId: map['studentId'],
      score: map['score'],
      subject: map['subject'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}