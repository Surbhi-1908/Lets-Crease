import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../constants/app_constants.dart';
import '../data/comprehensive_quiz_data.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QuizQuestion>> getQuestionsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.quizzesCollection)
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => QuizQuestion.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load quiz questions: $e');
    }
  }

  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _firestore
          .collection('quiz_results')
          .add(result.toMap());
    } catch (e) {
      throw Exception('Failed to save quiz result: $e');
    }
  }

  Future<List<QuizResult>> getUserQuizHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => QuizResult.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load quiz history: $e');
    }
  }

  // Comprehensive quiz data with skill levels and shuffling (local data helpers)
  static List<QuizQuestion> localQuestionsByCategory(String category, {String skillLevel = 'Beginner'}) {
    return ComprehensiveQuizData.getShuffledQuestions(category, skillLevel);
  }

  static List<QuizQuestion> localQuestionsByLevel(String skillLevel) {
    return ComprehensiveQuizData.getQuestionsByLevel(skillLevel);
  }

  static List<QuizQuestion> allLocalQuestions() {
    return ComprehensiveQuizData.getAllQuestions();
  }

  static List<String> availableCategories() {
    return ComprehensiveQuizData.getAvailableCategories();
  }

  static List<String> availableSkillLevels() {
    return ComprehensiveQuizData.getAvailableSkillLevels();
  }

  static int questionCountFor(String category, String skillLevel) {
    return ComprehensiveQuizData.getQuestionCountByCategory(category, skillLevel);
  }
}
