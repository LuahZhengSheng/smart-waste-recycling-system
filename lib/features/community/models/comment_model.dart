import 'package:cloud_firestore/cloud_firestore.dart';
import 'reply_model.dart';

class Comment {
  final String commentId;       // Firestore doc ID
  final String userId;          // Author ID
  final String content;         // Comment content
  List<String> likes;           // User IDs who liked this comment
  int replyCount;               // Number of replies (for quick display)
  final DateTime createdAt;
  final DateTime updatedAt;
  List<Reply> replies;          // Loaded replies (optional)

  Comment({
    required this.commentId,
    required this.userId,
    required this.content,
    List<String>? likes,
    this.replyCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Reply>? replies,
  })  : likes = likes ?? [],
        replies = replies ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Empty comment
  static Comment empty() => Comment(
    commentId: '',
    userId: '',
    content: '',
  );

  /// Convert to Firestore JSON (without replies)
  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'userId': userId,
      'content': content,
      'likes': likes,
      'replyCount': replyCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore snapshot
  factory Comment.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null for comment ID: ${doc.id}");
    }
    return Comment(
      commentId: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      replyCount: data['replyCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Attach loaded replies
  Comment withReplies(List<Reply> loadedReplies) {
    return Comment(
      commentId: commentId,
      userId: userId,
      content: content,
      likes: likes,
      replyCount: replyCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      replies: loadedReplies,
    );
  }
}
