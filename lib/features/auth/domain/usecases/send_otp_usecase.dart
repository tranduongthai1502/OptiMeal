import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) {
      return Future.value(const Left(AuthFailure('Số điện thoại không được để trống.')));
    }
    return repository.sendOtp(phoneNumber.trim());
  }
}
