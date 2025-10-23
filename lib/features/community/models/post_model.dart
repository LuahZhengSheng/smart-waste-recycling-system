import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/community/models/comment_model.dart';

class PostModel {
  final String postId;           // Firestore doc ID
  final String userId;           // Author ID
  final String postType;         // Type of community (tip, discussion, question, etc.)
  final String content;          // Post content
  List<String> media;            // List of media URLs
  List<String> likes;            // User IDs who liked this community
  int commentCount;              // Number of comments (for display)
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isDisabled;               // Whether this community is disabled
  List<Comment> comments;        // Loaded comments (optional)

  PostModel({
    required this.postId,
    required this.userId,
    required this.postType,
    required this.content,
    List<String>? media,
    List<String>? likes,
    this.commentCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDisabled = false,
    List<Comment>? comments,
  })  : media = media ?? [],
        likes = likes ?? [],
        comments = comments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create an empty Post object
  static PostModel empty() => PostModel(
    postId: '',
    userId: '',
    postType: '',
    content: '',
  );

  /// Convert Post to Firestore JSON (without comments, since they are separate docs)
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'postType': postType,
      'content': content,
      'media': media,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDisabled': isDisabled,
    };
  }

  /// Create Post from Firestore snapshot
  factory PostModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null for community ID: ${doc.id}");
    }
    return PostModel(
      postId: doc.id,
      userId: data['userId'] ?? '',
      postType: data['postType'] ?? '',
      content: data['content'] ?? '',
      media: List<String>.from(data['media'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDisabled: data['isDisabled'] ?? false,
    );
  }

  /// CopyWith method for easy updates
  PostModel copyWith({
    String? postId,
    String? userId,
    String? postType,
    String? content,
    List<String>? media,
    List<String>? likes,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDisabled,
    List<Comment>? comments,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      postType: postType ?? this.postType,
      content: content ?? this.content,
      media: media ?? this.media,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDisabled: isDisabled ?? this.isDisabled,
      comments: comments ?? this.comments,
    );
  }

  /// Attach loaded comments to the Post object
  PostModel withComments(List<Comment> loadedComments) {
    return PostModel(
      postId: postId,
      userId: userId,
      postType: postType,
      content: content,
      media: media,
      likes: likes,
      commentCount: commentCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDisabled: isDisabled,
      comments: loadedComments,
    );
  }

  @override
  String toString() {
    return 'PostModel(postId: $postId, userId: $userId, postType: $postType, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content}, likes: ${likes.length}, commentCount: $commentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostModel &&
        other.postId == postId &&
        other.userId == userId &&
        other.postType == postType &&
        other.content == content &&
        other.media == media &&
        other.likes == likes &&
        other.commentCount == commentCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isDisabled == isDisabled &&
        other.comments == comments;
  }

  @override
  int get hashCode {
    return postId.hashCode ^
    userId.hashCode ^
    postType.hashCode ^
    content.hashCode ^
    media.hashCode ^
    likes.hashCode ^
    commentCount.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    isDisabled.hashCode ^
    comments.hashCode;
  }
}