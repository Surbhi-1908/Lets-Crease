import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String id;
  final String title;
  final String content;
  final String artistName;
  final String imageUrl;
  final DateTime publishedAt;
  final List<String> tags;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.artistName,
    required this.imageUrl,
    required this.publishedAt,
    required this.tags,
  });

  factory BlogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BlogModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      artistName: data['artistName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      publishedAt: (data['publishedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'artistName': artistName,
      'imageUrl': imageUrl,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'tags': tags,
    };
  }
}
