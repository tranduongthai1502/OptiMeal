import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/reputation_repository.dart';

class ReputationRepositoryImpl implements ReputationRepository {
  final Map<String, UserReputation> _mockUserReputations = {
    'user-default': const UserReputation(
      userId: 'user-default',
      averageRating: 4.9,
      totalReviews: 18,
      completedTransactions: 22,
      noShowCount: 0,
      isRestricted: false,
    ),
    'user-violator': const UserReputation(
      userId: 'user-violator',
      averageRating: 2.1,
      totalReviews: 5,
      completedTransactions: 2,
      noShowCount: 4,
      isRestricted: true,
    ),
  };

  @override
  Future<Either<Failure, Review>> submitReview(Review review) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Right(review);
  }

  @override
  Future<Either<Failure, UserReputation>> getUserReputation(
      String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final reputation = _mockUserReputations[userId] ??
        UserReputation(
          userId: userId,
          averageRating: 5.0,
          totalReviews: 0,
          completedTransactions: 0,
          noShowCount: 0,
          isRestricted: false,
        );
    return Right(reputation);
  }

  @override
  Future<Either<Failure, void>> reportNoShow({
    required String reservationId,
    required String reportedUserId,
    required String reason,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }
}
