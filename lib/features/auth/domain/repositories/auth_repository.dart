import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contract for Authentication repository operations.
abstract class AuthRepository {
  /// Sends an OTP to the given phone number.
  /// Returns a verificationId for completing sign-in.
  Future<Either<Failure, String>> sendOtp(String phoneNumber);

  /// Verifies the OTP code against verificationId.
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Retrieves the currently authenticated user, or null if signed out.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Updates user role (individual / store) after first login.
  Future<Either<Failure, UserEntity>> updateUserRole({
    required String userId,
    required UserRole role,
    String? displayName,
  });

  /// Signs the current user out.
  Future<Either<Failure, void>> signOut();
}
