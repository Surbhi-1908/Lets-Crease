import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blog_model.dart';
import '../constants/app_constants.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.blogsCollection)
          .orderBy('publishedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BlogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load blogs: $e');
    }
  }

  Future<BlogModel?> getBlogById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.blogsCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return BlogModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load blog: $e');
    }
  }

  Future<List<BlogModel>> getBlogsByTag(String tag) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.blogsCollection)
          .where('tags', arrayContains: tag)
          .orderBy('publishedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BlogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load blogs by tag: $e');
    }
  }
}
