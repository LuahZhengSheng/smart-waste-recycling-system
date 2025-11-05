enum AchievementCategory {
  recycling('Recycling', 'Complete recycling activities'),
  differentWaste('Different Waste', 'Sort different types of waste');

  const AchievementCategory(this.displayName, this.description);
  final String displayName;
  final String description;

  static AchievementCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'recycling':
        return AchievementCategory.recycling;
      case 'different waste':
      case 'differentwaste':
        return AchievementCategory.differentWaste;
      default:
        return AchievementCategory.recycling;
    }
  }
}

enum AchievementStatus {
  locked,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case AchievementStatus.locked:
        return 'Locked';
      case AchievementStatus.inProgress:
        return 'In Progress';
      case AchievementStatus.completed:
        return 'Completed';
    }
  }
}