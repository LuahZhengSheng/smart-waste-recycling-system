/// Post type enumeration
enum PostType {
  tip('Tip', 'tip'),
  question('Question', 'question'),
  discussion('Discussion', 'discussion');

  final String displayName;
  final String value;

  const PostType(this.displayName, this.value);

  static PostType fromString(String value) {
    return PostType.values.firstWhere(
          (type) => type.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PostType.tip,
    );
  }
}

/// Media type enumeration
enum MediaType {
  image,
  video
}

/// Comment sort type enumeration
enum CommentSortType {
  topComments('Top comments'),
  newestFirst('Newest first');

  final String displayName;

  const CommentSortType(this.displayName);
}

/// Time filter enumeration
enum TimeFilter {
  allTime('All Time'),
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  thisYear('This Year');

  final String displayName;

  const TimeFilter(this.displayName);
}