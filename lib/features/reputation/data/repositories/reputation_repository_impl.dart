import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/reputation_repository.dart';

/// Firestore-backed implementation of ReputationRepository.
/// Collections used:
///   - `reviews`           → individual review documents
///   - `user_reputations`  → aggregated reputation per user
///   - `no_show_reports`   → no-show violation records
class ReputationRepositoryImpl implements ReputationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReputationRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _reviewsCol =>
      _firestore.collection('reviews');

  CollectionReference<Map<String, dynamic>> get _reputationsCol =>
      _firestore.collection('user_reputations');

  CollectionReference<Map<String, dynamic>> get _noShowCol =>
      _firestore.collection('no_show_reports');

  @override
  Future<Either<Failure, Review>> submitReview(Review review) async {
    try {
      final docRef = _reviewsCol.doc(review.id.isEmpty ? null : review.id);
      final data = {
        'reservationId': review.reservationId,
        'reviewerId': review.reviewerId,
        'targetUserId': review.targetUserId,
        'rating': review.rating,
        'comment': review.comment,
        'isNoShowReport': review.isNoShowReport,
        'createdAt': review.createdAt.millisecondsSinceEpoch,
      };

      await docRef.set(data);

      // Update aggregated reputation via Firestore transaction
      await _firestore.runTransaction((txn) async {
        final repRef = _reputationsCol.doc(review.targetUserId);
        final repSnap = await txn.get(repRef);

        if (repSnap.exists) {
          final current = repSnap.data()!;
          final totalReviews = (current['totalReviews'] as int? ?? 0) + 1;
          final oldAvg = (current['averageRating'] as num?)?.toDouble() ?? 5.0;
          final newAvg =
              ((oldAvg * (totalReviews - 1)) + review.rating) / totalReviews;

          txn.update(repRef, {
            'totalReviews': totalReviews,
            'averageRating': newAvg,
          });
        } else {
          txn.set(repRef, {
            'userId': review.targetUserId,
            'averageRating': review.rating.toDouble(),
            'totalReviews': 1,
            'completedTransactions': 0,
            'noShowCount': 0,
            'isRestricted': false,
          });
        }
      });

      return Right(
        Review(
          id: docRef.id,
          reservationId: review.reservationId,
          reviewerId: review.reviewerId,
          targetUserId: review.targetUserId,
          rating: review.rating,
          comment: review.comment,
          isNoShowReport: review.isNoShowReport,
          createdAt: review.createdAt,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Lỗi gửi đánh giá: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserReputation>> getUserReputation(
    String userId,
  ) async {
    try {
      final snapshot = await _reputationsCol.doc(userId).get();

      if (!snapshot.exists) {
        return Right(UserReputation(userId: userId));
      }

      final data = snapshot.data()!;
      return Right(
        UserReputation(
          userId: userId,
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 5.0,
          totalReviews: (data['totalReviews'] as int?) ?? 0,
          completedTransactions: (data['completedTransactions'] as int?) ?? 0,
          noShowCount: (data['noShowCount'] as int?) ?? 0,
          isRestricted: data['isRestricted'] as bool? ?? false,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Lỗi tải điểm uy tín: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> reportNoShow({
    required String reservationId,
    required String reportedUserId,
    required String reason,
  }) async {
    try {
      final reporterId = _auth.currentUser?.uid ?? '';
      final docRef = _noShowCol.doc();

      await _firestore.runTransaction((txn) async {
        // Write no-show report
        txn.set(docRef, {
          'reservationId': reservationId,
          'reportedUserId': reportedUserId,
          'reporterId': reporterId,
          'reason': reason,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });

        // Increment noShowCount on user_reputations
        final repRef = _reputationsCol.doc(reportedUserId);
        final repSnap = await txn.get(repRef);

        if (repSnap.exists) {
          final currentCount = (repSnap.data()!['noShowCount'] as int?) ?? 0;
          final newCount = currentCount + 1;
          final isRestricted = newCount >= 3;

          txn.update(repRef, {
            'noShowCount': newCount,
            'isRestricted': isRestricted,
          });
        } else {
          txn.set(repRef, {
            'userId': reportedUserId,
            'averageRating': 5.0,
            'totalReviews': 0,
            'completedTransactions': 0,
            'noShowCount': 1,
            'isRestricted': false,
          });
        }
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Lỗi báo cáo no-show: ${e.toString()}'));
    }
  }
}
