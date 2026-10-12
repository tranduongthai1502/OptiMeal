import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

/// Firebase implementation for AuthRemoteDataSource.
/// Uses FirebaseAuth (Phone OTP) & Cloud Firestore (users collection).
class AuthFirebaseDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthFirebaseDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  @override
  Future<String> sendOtp(String phoneNumber) async {
    late String resolvedVerificationId;

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval on Android: sign in directly
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('OTP verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        resolvedVerificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    // Wait briefly for codeSent callback to fire
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return resolvedVerificationId;
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    // Upsert user document in Firestore
    final docRef = _usersCol.doc(firebaseUser.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final newUser = UserModel(
        id: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        role: null,
        createdAt: DateTime.now(),
      );
      await docRef.set(newUser.toMap());
      return newUser;
    }

    return UserModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final snapshot = await _usersCol.doc(firebaseUser.uid).get();
    if (!snapshot.exists) return null;

    return UserModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<UserModel> updateUserRole({
    required String userId,
    required UserRole role,
    String? displayName,
  }) async {
    final docRef = _usersCol.doc(userId);

    await docRef.update({
      'role': role.name,
      if (displayName != null) 'displayName': displayName,
    });

    final snapshot = await docRef.get();
    return UserModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
