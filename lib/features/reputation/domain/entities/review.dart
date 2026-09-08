/// Domain entity representing a two-way review between donor and claimant.
class Review {
  final String id;
  final String reservationId;
  final String reviewerId;
  final String targetUserId;
  final int rating; // 1 to 5 stars
  final String comment;
  final bool isNoShowReport;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.reservationId,
    required this.reviewerId,
    required this.targetUserId,
    required this.rating,
    required this.comment,
    this.isNoShowReport = false,
    required this.createdAt,
  });
}

/// Domain entity representing the aggregate reputation profile of a user.
class UserReputation {
  final String userId;
  final double averageRating;
  final int totalReviews;
  final int completedTransactions;
  final int noShowCount;
  final bool isRestricted;

  const UserReputation({
    required this.userId,
    this.averageRating = 5.0,
    this.totalReviews = 0,
    this.completedTransactions = 0,
    this.noShowCount = 0,
    this.isRestricted = false,
  });

  bool get hasExceededNoShowLimit => noShowCount >= 3;
}
