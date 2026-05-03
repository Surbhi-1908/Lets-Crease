import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String skillLevel;
  final List<String> foldingHistory;
  final Map<String, int> quizScores;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.skillLevel,
    required this.foldingHistory,
    required this.quizScores,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      skillLevel: data['skillLevel'] ?? 'Beginner',
      foldingHistory: List<String>.from(data['foldingHistory'] ?? []),
      quizScores: Map<String, int>.from(data['quizScores'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'skillLevel': skillLevel,
      'foldingHistory': foldingHistory,
      'quizScores': quizScores,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? username,
    String? skillLevel,
    List<String>? foldingHistory,
    Map<String, int>? quizScores,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      skillLevel: skillLevel ?? this.skillLevel,
      foldingHistory: foldingHistory ?? this.foldingHistory,
      quizScores: quizScores ?? this.quizScores,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
