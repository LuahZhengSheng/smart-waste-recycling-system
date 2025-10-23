import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String replyId;         // Firestore doc ID
  final String userId;          // Author ID
  final String content;         // Reply content
  List<String> likes;           // User IDs who liked this reply
  final DateTime createdAt;
  final DateTime updatedAt;

  Reply({
    required this.replyId,
    required this.userId,
    required this.content,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : likes = likes ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'replyId': replyId,
      'userId': userId,
      'content': content,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore snapshot
  factory Reply.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null for reply ID: ${doc.id}");
    }
    return Reply(
      replyId: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
