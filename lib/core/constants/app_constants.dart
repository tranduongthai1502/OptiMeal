/// Core application constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'OptiMeal';
  static const String appTagline = 'Chia sẻ thực phẩm - Giảm thiểu lãng phí';

  /// Default reservation hold time in minutes (20 minutes).
  static const int defaultReservationDurationMinutes = 20;

  /// Default search radius for surplus food in kilometers (3km).
  static const double defaultSearchRadiusKm = 3.0;

  /// Max radius allowed for search in kilometers.
  static const double maxSearchRadiusKm = 20.0;

  /// Threshold for no-show count before penalizing or restricting user.
  static const int maxNoShowThreshold = 3;

  /// Default pagination limit.
  static const int defaultPageSize = 20;

  /// Shared Preferences Keys
  static const String prefKeyUserId = 'pref_user_id';
  static const String prefKeyUserRole = 'pref_user_role';
  static const String prefKeyThemeMode = 'pref_theme_mode';
  static const String prefKeyLocale = 'pref_locale';
}
