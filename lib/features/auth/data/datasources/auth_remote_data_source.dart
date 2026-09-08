import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

/// Contract for Authentication remote data source.
/// Abstracted so it can be swapped with Firebase, Supabase, or custom REST API.
abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String phoneNumber);

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateUserRole({
    required String userId,
    required UserRole role,
    String? displayName,
  });

  Future<void> signOut();
}

/// Firebase implementation skeleton for AuthRemoteDataSource.
/// Uses FirebaseAuth & Cloud Firestore.
class AuthFirebaseDataSourceImpl implements AuthRemoteDataSource {
  // In production: final FirebaseAuth _firebaseAuth; final FirebaseFirestore _firestore;

  @override
  Future<String> sendOtp(String phoneNumber) async {
    // Stub implementation simulating OTP send for initial scaffolding
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return 'fake-verification-id-for-$phoneNumber';
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Sample mock return for scaffold
    return UserModel(
      id: 'mock-user-101',
      phoneNumber: '+84987654321',
      displayName: 'Nguyễn Văn A',
      role: null, // First-time user needs role onboarding
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Scaffold initial state
    return null;
  }

  @override
  Future<UserModel> updateUserRole({
    required String userId,
    required UserRole role,
    String? displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return UserModel(
      id: userId,
      phoneNumber: '+84987654321',
      displayName: displayName ?? 'Người dùng',
      role: role,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
