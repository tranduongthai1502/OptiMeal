import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review.dart';
import '../repositories/reputation_repository.dart';

class CheckNoShowLimitUseCase {
  final ReputationRepository repository;

  CheckNoShowLimitUseCase(this.repository);

  /// Checks if user is eligible to make a food reservation.
  /// If no-show count >= 3, blocks the operation.
  Future<Either<Failure, bool>> call(String userId) async {
    final result = await repository.getUserReputation(userId);

    return result.fold((failure) => Left(failure), (reputation) {
      if (reputation.noShowCount >= AppConstants.maxNoShowThreshold ||
          reputation.isRestricted) {
        return const Left(ReputationRestrictedFailure());
      }
      return const Right(true);
    });
  }
}

class SubmitReviewUseCase {
  final ReputationRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<Either<Failure, Review>> call(Review review) {
    if (review.rating < 1 || review.rating > 5) {
      return Future.value(
        const Left(ServerFailure('Đánh giá phải từ 1 đến 5 sao.')),
      );
    }
    return repository.submitReview(review);
  }
}
