import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String verificationId,
    required String smsCode,
  }) {
    if (smsCode.trim().length != 6) {
      return Future.value(
          const Left(InvalidOtpFailure('Mã OTP phải có đúng 6 chữ số.')));
    }
    return repository.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
  }
}
