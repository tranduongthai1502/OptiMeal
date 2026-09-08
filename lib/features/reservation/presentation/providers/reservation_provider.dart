import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/reservation_remote_data_source.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../../domain/usecases/check_reservation_expiry_usecase.dart';
import '../../domain/usecases/confirm_pickup_usecase.dart';

final reservationRemoteDataSourceProvider = Provider<ReservationRemoteDataSource>((ref) {
  return ReservationFirebaseDataSourceImpl();
});

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepositoryImpl(
    remoteDataSource: ref.watch(reservationRemoteDataSourceProvider),
  );
});

final createReservationUseCaseProvider = Provider<CreateReservationUseCase>((ref) {
  return CreateReservationUseCase(ref.watch(reservationRepositoryProvider));
});

final checkReservationExpiryUseCaseProvider = Provider<CheckReservationExpiryUseCase>((ref) {
  return CheckReservationExpiryUseCase(ref.watch(reservationRepositoryProvider));
});

final confirmPickupUseCaseProvider = Provider<ConfirmPickupUseCase>((ref) {
  return ConfirmPickupUseCase(ref.watch(reservationRepositoryProvider));
});

final cancelReservationUseCaseProvider = Provider<CancelReservationUseCase>((ref) {
  return CancelReservationUseCase(ref.watch(reservationRepositoryProvider));
});

// Single reservation provider
final reservationByIdProvider = FutureProvider.family.autoDispose<Reservation, String>((ref, id) async {
  final repo = ref.watch(reservationRepositoryProvider);
  final result = await repo.getReservationById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (res) => res,
  );
});

// Reservation State for active claim flow
class ReservationState {
  final bool isLoading;
  final Reservation? activeReservation;
  final Duration remainingTime;
  final String? errorMessage;

  const ReservationState({
    this.isLoading = false,
    this.activeReservation,
    this.remainingTime = Duration.zero,
    this.errorMessage,
  });

  bool get isExpired => remainingTime == Duration.zero && activeReservation?.status == ReservationStatus.held;

  ReservationState copyWith({
    bool? isLoading,
    Reservation? activeReservation,
    Duration? remainingTime,
    String? errorMessage,
  }) {
    return ReservationState(
      isLoading: isLoading ?? this.isLoading,
      activeReservation: activeReservation ?? this.activeReservation,
      remainingTime: remainingTime ?? this.remainingTime,
      errorMessage: errorMessage,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final CreateReservationUseCase _createUseCase;
  final CheckReservationExpiryUseCase _checkExpiryUseCase;
  final ConfirmPickupUseCase _confirmPickupUseCase;
  final CancelReservationUseCase _cancelUseCase;
  Timer? _countdownTimer;

  ReservationNotifier({
    required CreateReservationUseCase createUseCase,
    required CheckReservationExpiryUseCase checkExpiryUseCase,
    required ConfirmPickupUseCase confirmPickupUseCase,
    required CancelReservationUseCase cancelUseCase,
  })  : _createUseCase = createUseCase,
        _checkExpiryUseCase = checkExpiryUseCase,
        _confirmPickupUseCase = confirmPickupUseCase,
        _cancelUseCase = cancelUseCase,
        super(const ReservationState());

  Future<bool> holdReservation({
    required String listingId,
    required String claimerId,
    required String ownerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _createUseCase(
      listingId: listingId,
      claimerId: claimerId,
      ownerId: ownerId,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (reservation) {
        state = state.copyWith(
          isLoading: false,
          activeReservation: reservation,
          remainingTime: reservation.remainingTimeFrom(DateTime.now()),
        );
        _startTimer(reservation);
        return true;
      },
    );
  }

  void _startTimer(Reservation reservation) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = DateTime.now();
      final remaining = reservation.remainingTimeFrom(now);

      if (remaining <= Duration.zero) {
        timer.cancel();
        // Check and mark expired on backend
        await _checkExpiryUseCase(reservation, currentTime: now);
        state = state.copyWith(
          remainingTime: Duration.zero,
          activeReservation: reservation.copyWith(status: ReservationStatus.expired),
        );
      } else {
        state = state.copyWith(remainingTime: remaining);
      }
    });
  }

  Future<bool> confirmPickup(String qrCode) async {
    if (state.activeReservation == null) return false;
    state = state.copyWith(isLoading: true);
    final result = await _confirmPickupUseCase(
      reservationId: state.activeReservation!.id,
      qrCodeData: qrCode,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (confirmedRes) {
        _countdownTimer?.cancel();
        state = state.copyWith(isLoading: false, activeReservation: confirmedRes);
        return true;
      },
    );
  }

  Future<void> cancelReservation() async {
    if (state.activeReservation == null) return;
    _countdownTimer?.cancel();
    await _cancelUseCase(state.activeReservation!.id);
    state = const ReservationState();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final reservationNotifierProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  return ReservationNotifier(
    createUseCase: ref.watch(createReservationUseCaseProvider),
    checkExpiryUseCase: ref.watch(checkReservationExpiryUseCaseProvider),
    confirmPickupUseCase: ref.watch(confirmPickupUseCaseProvider),
    cancelUseCase: ref.watch(cancelReservationUseCaseProvider),
  );
});
