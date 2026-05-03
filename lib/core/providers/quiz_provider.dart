import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

final quizServiceProvider = Provider<QuizService>((ref) => QuizService());

final quizQuestionsProvider = FutureProvider.family<List<QuizQuestion>, String>((ref, category) async {
  final quizService = ref.read(quizServiceProvider);
  return await quizService.getQuestionsByCategory(category);
});

final sampleQuizQuestionsProvider = Provider<List<QuizQuestion>>((ref) {
  return QuizService.allLocalQuestions();
});

final quizQuestionsByCategoryProvider = Provider.family<List<QuizQuestion>, Map<String, String>>((ref, params) {
  final category = params['category'] ?? 'Artists';
  final skillLevel = params['skillLevel'] ?? 'Beginner';
  return QuizService.localQuestionsByCategory(category, skillLevel: skillLevel);
});

class QuizStateNotifier extends StateNotifier<QuizState> {
  QuizStateNotifier() : super(QuizState.initial());

  void startQuiz(List<QuizQuestion> questions, String category) {
    state = state.copyWith(
      questions: questions,
      category: category,
      currentQuestionIndex: 0,
      score: 0,
      isCompleted: false,
      answers: {},
    );
  }

  void answerQuestion(int answerIndex) {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final isCorrect = answerIndex == currentQuestion.correctAnswerIndex;
    
    final newAnswers = {...state.answers};
    newAnswers[currentQuestion.id] = answerIndex;
    
    state = state.copyWith(
      answers: newAnswers,
      score: isCorrect ? state.score + 1 : state.score,
    );
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    } else {
      state = state.copyWith(isCompleted: true);
    }
  }

  void resetQuiz() {
    state = QuizState.initial();
  }
}

class QuizState {
  final List<QuizQuestion> questions;
  final String category;
  final int currentQuestionIndex;
  final int score;
  final bool isCompleted;
  final Map<String, int> answers;

  QuizState({
    required this.questions,
    required this.category,
    required this.currentQuestionIndex,
    required this.score,
    required this.isCompleted,
    required this.answers,
  });

  factory QuizState.initial() {
    return QuizState(
      questions: [],
      category: '',
      currentQuestionIndex: 0,
      score: 0,
      isCompleted: false,
      answers: {},
    );
  }

  QuizState copyWith({
    List<QuizQuestion>? questions,
    String? category,
    int? currentQuestionIndex,
    int? score,
    bool? isCompleted,
    Map<String, int>? answers,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      category: category ?? this.category,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      answers: answers ?? this.answers,
    );
  }
}

final quizStateProvider = StateNotifierProvider<QuizStateNotifier, QuizState>((ref) {
  return QuizStateNotifier();
});
