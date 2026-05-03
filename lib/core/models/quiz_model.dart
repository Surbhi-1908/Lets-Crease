class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String explanation;
  final String skillLevel;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.explanation,
    required this.skillLevel,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      category: map['category'] ?? '',
      explanation: map['explanation'] ?? '',
      skillLevel: map['skillLevel'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'category': category,
      'explanation': explanation,
      'skillLevel': skillLevel,
    };
  }
}

class QuizResult {
  final String userId;
  final String category;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;
  final List<String> answeredQuestions;

  QuizResult({
    required this.userId,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    required this.answeredQuestions,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      userId: map['userId'] ?? '',
      category: map['category'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] ?? 0),
      answeredQuestions: List<String>.from(map['answeredQuestions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'answeredQuestions': answeredQuestions,
    };
  }
}
