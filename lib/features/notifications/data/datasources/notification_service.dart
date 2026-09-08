/// Service abstraction for Local and Push Notifications (FCM).
class NotificationService {
  Future<void> initialize() async {
    // In production:
    // 1. Request notification permissions
    // 2. Initialize FirebaseMessaging background handlers
    // 3. Configure flutter_local_notifications channels
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Scaffold implementation
  }
}
