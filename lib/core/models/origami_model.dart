class OrigamiModel {
  final String id;
  final String name;
  final String category;
  final String difficulty;
  final String pdfPath;
  final String description;
  final String imageUrl;
  final int estimatedTime; // in minutes
  final List<String> tags;

  const OrigamiModel({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.pdfPath,
    required this.description,
    required this.imageUrl,
    required this.estimatedTime,
    required this.tags,
  });

  factory OrigamiModel.fromMap(Map<String, dynamic> map) {
    return OrigamiModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? '',
      pdfPath: map['pdfPath'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      estimatedTime: map['estimatedTime'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'pdfPath': pdfPath,
      'description': description,
      'imageUrl': imageUrl,
      'estimatedTime': estimatedTime,
      'tags': tags,
    };
  }
}
