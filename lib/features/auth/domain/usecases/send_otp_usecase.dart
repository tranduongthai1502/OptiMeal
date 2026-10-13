import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import 'phone_number_formatter.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber) {
    final normalizedPhoneNumber =
        normalizeVietnamesePhoneNumber(phoneNumber.trim());
    if (normalizedPhoneNumber == null) {
      return Future.value(
        const Left(
          AuthFailure(
            'Số điện thoại Việt Nam không hợp lệ. Hãy nhập đủ 10 chữ số.',
          ),
        ),
      );
    }
    return repository.sendOtp(normalizedPhoneNumber);
  }
}
