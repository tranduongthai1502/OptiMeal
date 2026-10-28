import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

// Repositories & DataSources Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthFirebaseDataSourceImpl();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// UseCase Providers
final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

final updateUserRoleUseCaseProvider = Provider<UpdateUserRoleUseCase>((ref) {
  return UpdateUserRoleUseCase(ref.watch(authRepositoryProvider));
});

// Auth State representation
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? verificationId;
  final String? phoneNumber;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.verificationId,
    this.phoneNumber,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? verificationId,
    String? phoneNumber,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage,
    );
  }
}

// Auth State Controller
class AuthNotifier extends StateNotifier<AuthState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final UpdateUserRoleUseCase _updateUserRoleUseCase;
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthNotifier({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required UpdateUserRoleUseCase updateUserRoleUseCase,
    required AuthRepository authRepository,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _updateUserRoleUseCase = updateUserRoleUseCase,
        _authRepository = authRepository,
        super(const AuthState(isLoading: true)) {
    _initAuthState();
  }

  void _initAuthState() {
    try {
      _authSubscription =
          FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
        if (fbUser == null) {
          state = const AuthState(isLoading: false);
        } else {
          final result = await _authRepository.getCurrentUser();
          result.fold(
            (failure) => state = const AuthState(isLoading: false),
            (user) => state = AuthState(isLoading: false, user: user),
          );
        }
      });
    } catch (_) {
      // Graceful fallback in environments without Firebase (e.g. unit/widget tests)
      state = const AuthState(isLoading: false);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _sendOtpUseCase(phoneNumber);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (verificationId) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
          phoneNumber: phoneNumber,
        );
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(
        errorMessage: 'Thiếu mã xác thực (verification ID).',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _verifyOtpUseCase(
      verificationId: state.verificationId!,
      smsCode: smsCode,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<bool> selectRole(UserRole role, {String? displayName}) async {
    if (state.user == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _updateUserRoleUseCase(
      userId: state.user!.id,
      role: role,
      displayName: displayName,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updatedUser) {
        state = state.copyWith(isLoading: false, user: updatedUser);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    sendOtpUseCase: ref.watch(sendOtpUseCaseProvider),
    verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
    updateUserRoleUseCase: ref.watch(updateUserRoleUseCaseProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});
