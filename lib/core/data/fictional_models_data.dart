import '../models/origami_model.dart';

class FictionalModelsData {
  static List<OrigamiModel> getFictionalModels() {
    return [
      OrigamiModel(
        id: 'fictional_001',
        name: 'Buddhist Monk',
        category: 'Fictional',
        difficulty: 'Advanced',
        pdfPath: 'assets/pdfs/Buddhist Monk Diagrams PDF.pdf',
        description: 'A detailed origami model of a Buddhist monk in meditation pose',
        imageUrl: 'assets/images/app_logo.png',
        estimatedTime: 45,
        tags: ['spiritual', 'human', 'meditation'],
      ),
      OrigamiModel(
        id: 'fictional_003',
        name: 'Ganesha',
        category: 'Fictional',
        difficulty: 'Expert',
        pdfPath: 'assets/pdfs/Ganesha \$ - Diagrams.pdf',
        description: 'Hindu deity Ganesha with elephant head and multiple arms',
        imageUrl: 'assets/images/app_logo.png',
        estimatedTime: 75,
        tags: ['deity', 'elephant', 'spiritual', 'complex'],
      ),
      OrigamiModel(
        id: 'fictional_004',
        name: 'Lao-Tseu',
        category: 'Fictional',
        difficulty: 'Advanced',
        pdfPath: 'assets/pdfs/Lao-Tseu - Diagrammes PDF.pdf',
        description: 'Ancient Chinese philosopher Lao-Tseu in contemplative pose',
        imageUrl: 'assets/images/app_logo.png',
        estimatedTime: 50,
        tags: ['philosopher', 'human', 'wisdom'],
      ),
      OrigamiModel(
        id: 'fictional_006',
        name: 'Magic Tower (Tour de Magie)',
        category: 'Fictional',
        difficulty: 'Advanced',
        pdfPath: 'assets/pdfs/Tour de Magie - Diagrammes PDF.pdf',
        description: 'Mystical tower with magical elements and intricate design',
        imageUrl: 'assets/images/app_logo.png',
        estimatedTime: 55,
        tags: ['magic', 'tower', 'fantasy', 'architecture'],
      ),
    ];
  }

  static List<String> getDifficultyLevels() {
    return ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
  }

  static List<OrigamiModel> getModelsByDifficulty(String difficulty) {
    return getFictionalModels()
        .where((model) => model.difficulty == difficulty)
        .toList();
  }

  static OrigamiModel? getModelById(String id) {
    try {
      return getFictionalModels().firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }
}
