import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String movieTitle;
  final String comment;
  final int rating;
  final String? imageUrl;
  final DateTime createdAt;
  final int likes;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.movieTitle,
    required this.comment,
    required this.rating,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      comment: data['comment'] ?? '',
      rating: data['rating'] ?? 0,
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'movieTitle': movieTitle,
      'comment': comment,
      'rating': rating,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }
}