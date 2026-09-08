import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review.dart';

abstract class ReputationRepository {
  Future<Either<Failure, Review>> submitReview(Review review);

  Future<Either<Failure, UserReputation>> getUserReputation(String userId);

  Future<Either<Failure, void>> reportNoShow({
    required String reservationId,
    required String reportedUserId,
    required String reason,
  });
}
