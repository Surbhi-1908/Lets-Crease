import '../models/quiz_model.dart';
import 'beginner_quiz_data.dart';
import 'moderate_quiz_data.dart';
import 'intermediate_quiz_data.dart';

class ComprehensiveQuizData {
  static List<QuizQuestion> getAllQuestions() {
    return [
      ...BeginnerQuizData.getAllBeginnerQuestions(),
      ...ModerateQuizData.getAllModerateQuestions(),
      ...IntermediateQuizData.getAllIntermediateQuestions(),
    ];
  }

  static List<QuizQuestion> getQuestionsByLevel(String skillLevel) {
    switch (skillLevel) {
      case 'Beginner':
        return BeginnerQuizData.getAllBeginnerQuestions();
      case 'Moderate':
        return ModerateQuizData.getAllModerateQuestions();
      case 'Intermediate':
        return IntermediateQuizData.getAllIntermediateQuestions();
      default:
        return BeginnerQuizData.getAllBeginnerQuestions();
    }
  }

  static List<QuizQuestion> getQuestionsByCategoryAndLevel(String category, String skillLevel) {
    final allQuestions = getQuestionsByLevel(skillLevel);
    return allQuestions.where((q) => q.category == category).toList();
  }

  static List<QuizQuestion> getShuffledQuestions(String category, String skillLevel) {
    final questions = getQuestionsByCategoryAndLevel(category, skillLevel);
    final shuffledQuestions = List<QuizQuestion>.from(questions);
    shuffledQuestions.shuffle();
    return shuffledQuestions;
  }

  static List<String> getAvailableCategories() {
    return ['Artists', 'Papers', 'Folding Techniques', 'Traditional Origami'];
  }

  static List<String> getAvailableSkillLevels() {
    return ['Beginner', 'Moderate', 'Intermediate'];
  }

  static int getQuestionCountByCategory(String category, String skillLevel) {
    return getQuestionsByCategoryAndLevel(category, skillLevel).length;
  }
}
