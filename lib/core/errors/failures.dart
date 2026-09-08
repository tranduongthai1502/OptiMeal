/// Base Failure class representing domain-level errors.
/// All specific failure types extend this class.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

/// Server or API remote failures.
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Đã xảy ra lỗi từ máy chủ. Vui lòng thử lại sau.', String? code])
      : super(message, code: code);
}

/// Network or internet connection failure.
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Không có kết nối mạng. Vui lòng kiểm tra Wi-Fi hoặc 4G.', String? code])
      : super(message, code: code);
}

/// Authentication and authorization failures.
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Xác thực không thành công. Vui lòng đăng nhập lại.', String? code])
      : super(message, code: code);
}

/// Invalid OTP failure.
class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure([String message = 'Mã OTP không hợp lệ hoặc đã hết hạn.', String? code])
      : super(message, code: code);
}

/// Local cache or storage failure.
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Lỗi lưu trữ cục bộ.', String? code])
      : super(message, code: code);
}

/// Reservation specific failures (e.g. expired, already claimed).
class ReservationFailure extends Failure {
  const ReservationFailure([String message = 'Không thể giữ chỗ cho thực phẩm này.', String? code])
      : super(message, code: code);
}

class ReservationExpiredFailure extends ReservationFailure {
  const ReservationExpiredFailure([String message = 'Thời gian giữ chỗ (20 phút) đã hết hạn.'])
      : super(message, 'RESERVATION_EXPIRED');
}

/// Reputation restriction failure (e.g. too many no-shows).
class ReputationRestrictedFailure extends Failure {
  const ReputationRestrictedFailure([String message = 'Tài khoản của bạn đã bị giới hạn giữ chỗ do quá số lần vắng mặt (no-show).'])
  : super(message, code: 'NO_SHOW_RESTRICTED');
}

/// Permission failure (e.g. GPS, Camera).
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Ứng dụng cần quyền truy cập để thực hiện tác vụ này.', String? code])
      : super(message, code: code);
}
