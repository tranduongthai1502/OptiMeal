import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optimeal/core/errors/failures.dart';
import 'package:optimeal/features/reputation/domain/entities/user_reputation.dart';
import 'package:optimeal/features/reputation/domain/repositories/reputation_repository.dart';
import 'package:optimeal/features/reputation/domain/usecases/check_no_show_limit_usecase.dart';

class MockReputationRepository extends Mock implements ReputationRepository {}

void main() {
  late MockReputationRepository mockRepository;
  late CheckNoShowLimitUseCase useCase;

  setUp(() {
    mockRepository = MockReputationRepository();
    useCase = CheckNoShowLimitUseCase(mockRepository);
  });

  group('CheckNoShowLimitUseCase Tests', () {
    test('should allow reservation when no-show count is below threshold (< 3)',
        () async {
      const goodReputation = UserReputation(
        userId: 'user-normal',
        averageRating: 4.8,
        totalReviews: 10,
        completedTransactions: 12,
        noShowCount: 1, // Below 3
        isRestricted: false,
      );

      when(() => mockRepository.getUserReputation('user-normal'))
          .thenAnswer((_) async => const Right(goodReputation));

      final result = await useCase('user-normal');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be allowed'),
        (isAllowed) => expect(isAllowed, isTrue),
      );
    });

    test(
        'should restrict user and return ReputationRestrictedFailure when no-show count >= 3',
        () async {
      const violatorReputation = UserReputation(
        userId: 'user-violator',
        averageRating: 2.5,
        totalReviews: 4,
        completedTransactions: 1,
        noShowCount: 3, // Reached threshold of 3
        isRestricted: false,
      );

      when(() => mockRepository.getUserReputation('user-violator'))
          .thenAnswer((_) async => const Right(violatorReputation));

      final result = await useCase('user-violator');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ReputationRestrictedFailure>()),
        (_) => fail('Should be restricted'),
      );
    });
  });
}
