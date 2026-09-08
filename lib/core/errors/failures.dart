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
  const ServerFailure(
      [super.message = 'Đã xảy ra lỗi từ máy chủ. Vui lòng thử lại sau.',
      String? code])
      : super(code: code);
}

/// Network or internet connection failure.
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message =
          'Không có kết nối mạng. Vui lòng kiểm tra Wi-Fi hoặc 4G.',
      String? code])
      : super(code: code);
}

/// Authentication and authorization failures.
class AuthFailure extends Failure {
  const AuthFailure(
      [super.message = 'Xác thực không thành công. Vui lòng đăng nhập lại.',
      String? code])
      : super(code: code);
}

/// Invalid OTP failure.
class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure(
      [super.message = 'Mã OTP không hợp lệ hoặc đã hết hạn.', String? code])
      : super(code: code);
}

/// Local cache or storage failure.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Lỗi lưu trữ cục bộ.', String? code])
      : super(code: code);
}

/// Reservation specific failures (e.g. expired, already claimed).
class ReservationFailure extends Failure {
  const ReservationFailure(
      [super.message = 'Không thể giữ chỗ cho thực phẩm này.', String? code])
      : super(code: code);
}

class ReservationExpiredFailure extends ReservationFailure {
  const ReservationExpiredFailure(
      [String message = 'Thời gian giữ chỗ (20 phút) đã hết hạn.'])
      : super(message, 'RESERVATION_EXPIRED');
}

/// Reputation restriction failure (e.g. too many no-shows).
class ReputationRestrictedFailure extends Failure {
  const ReputationRestrictedFailure(
      [super.message =
          'Tài khoản của bạn đã bị giới hạn giữ chỗ do quá số lần vắng mặt (no-show).'])
      : super(code: 'NO_SHOW_RESTRICTED');
}

/// Permission failure (e.g. GPS, Camera).
class PermissionFailure extends Failure {
  const PermissionFailure(
      [super.message = 'Ứng dụng cần quyền truy cập để thực hiện tác vụ này.',
      String? code])
      : super(code: code);
}
