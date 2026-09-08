/// Route path constants for GoRouter.
class RoutePaths {
  RoutePaths._();

  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String onboardingRole = '/onboarding-role';
  static const String home = '/home';
  static const String listingDetail = '/listing/:id';
  static const String createListing = '/create-listing';
  static const String reservationDetail = '/reservation/:id';
  static const String qrScanner = '/reservation/:id/scan';
  static const String chat = '/chat/:reservationId';
  static const String profile = '/profile';
  static const String storeProfile = '/store/:id';

  // Helper generators
  static String listingDetailPath(String id) => '/listing/$id';
  static String reservationDetailPath(String id) => '/reservation/$id';
  static String qrScannerPath(String reservationId) => '/reservation/$reservationId/scan';
  static String chatPath(String reservationId) => '/chat/$reservationId';
  static String storeProfilePath(String id) => '/store/$id';
}
