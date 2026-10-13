import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
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
  ConfirmationResult? _webConfirmationResult;

  AuthFirebaseDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  @override
  Future<String> sendOtp(String phoneNumber) async {
    try {
      if (kIsWeb) {
        _webConfirmationResult =
            await _firebaseAuth.signInWithPhoneNumber(phoneNumber);
        return _webConfirmationResult!.verificationId;
      }

      final codeSent = Completer<String>();
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException error) {
          if (!codeSent.isCompleted) {
            codeSent.completeError(_toAuthException(error));
          }
        },
        codeSent: (verificationId, _) {
          if (!codeSent.isCompleted) codeSent.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!codeSent.isCompleted) codeSent.complete(verificationId);
        },
      );
      return await codeSent.future;
    } on FirebaseAuthException catch (error) {
      throw _toAuthException(error);
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final userCredential = kIsWeb
          ? await (_webConfirmationResult ??
                  (throw const AuthException(
                    'Phiên xác thực đã hết hạn. Vui lòng yêu cầu mã OTP mới.',
                  )))
              .confirm(smsCode)
          : await _firebaseAuth.signInWithCredential(
              PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode,
              ),
            );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthException(
            'Firebase không trả về tài khoản đã xác thực.');
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      final docRef = _usersCol.doc(firebaseUser.uid);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        final newUser = UserModel(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          role: null,
          createdAt: DateTime.now(),
          isNewUser: isNewUser,
        );
        await docRef.set(newUser.toMap());
        _webConfirmationResult = null;
        return newUser;
      }

      _webConfirmationResult = null;
      return UserModel.fromMap(snapshot.data()!, snapshot.id)
          .copyWith(isNewUser: isNewUser);
    } on FirebaseAuthException catch (error) {
      throw _toAuthException(error);
    }
  }

  AuthException _toAuthException(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-phone-number' => 'Số điện thoại không hợp lệ.',
      'too-many-requests' =>
        'Bạn đã yêu cầu mã quá nhiều lần. Vui lòng thử lại sau.',
      'quota-exceeded' =>
        'Dịch vụ gửi OTP đã hết hạn mức. Vui lòng thử lại sau.',
      'operation-not-allowed' =>
        'Đăng nhập bằng số điện thoại chưa được bật trong Firebase.',
      'configuration-not-found' =>
        'Firebase Authentication chưa được cấu hình cho project. Hãy bật Phone trong Firebase Console.',
      'unauthorized-domain' =>
        'Tên miền hiện tại chưa được cho phép trong Firebase Authentication.',
      'app-not-authorized' =>
        'Ứng dụng web chưa được cấp quyền dùng Firebase Authentication.',
      'captcha-check-failed' =>
        'Không xác minh được reCAPTCHA. Vui lòng tải lại trang và thử lại.',
      'web-storage-unsupported' =>
        'Trình duyệt đang chặn bộ nhớ cần thiết cho xác thực. Hãy bật cookies và thử lại.',
      'network-request-failed' =>
        'Không thể kết nối mạng. Hãy kiểm tra kết nối rồi thử lại.',
      'invalid-verification-code' => 'Mã OTP không đúng.',
      'session-expired' => 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.',
      _ => error.message == null ||
              error.message!.trim().isEmpty ||
              error.message!.trim().toLowerCase() == 'error'
          ? 'Firebase không gửi được OTP. Kiểm tra cấu hình Phone Authentication, '
              'tên miền được phép, reCAPTCHA và hạn mức SMS.'
          : error.message!,
    };
    return AuthException('$message (mã Firebase: ${error.code})', error.code);
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
