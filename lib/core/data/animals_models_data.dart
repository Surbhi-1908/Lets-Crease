import '../models/origami_model.dart';

class AnimalsModelsData {
  static List<OrigamiModel> getAnimalsModels() {
    return [
      OrigamiModel(
        id: 'animals_001',
        name: 'Spider',
        category: 'Animals',
        difficulty: 'Intermediate',
        pdfPath: 'assets/pdfs/Spider.pdf',
        description: 'Eight-legged arachnid with detailed leg structure',
        imageUrl: 'assets/images/app_logo.png',
        estimatedTime: 35,
        tags: ['arachnid', 'eight-legs', 'insect'],
      ),
      OrigamiModel(
        id: 'animals_002',
        name: 'Brachiosaurus',
        category: 'Animals',
        difficulty: 'Advanced',
        pdfPath: 'assets/pdfs/Brachiosaurus .pdf',
        description: 'Long-necked dinosaur with impressive height and detail',
        imageUrl: 'assets/images/app_logo.png',
        estimatedTime: 50,
        tags: ['dinosaur', 'long-neck', 'prehistoric', 'herbivore'],
      ),
    ];
  }

  static List<String> getDifficultyLevels() {
    return ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
  }

  static List<OrigamiModel> getModelsByDifficulty(String difficulty) {
    return getAnimalsModels()
        .where((model) => model.difficulty == difficulty)
        .toList();
  }

  static OrigamiModel? getModelById(String id) {
    try {
      return getAnimalsModels().firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }
}
