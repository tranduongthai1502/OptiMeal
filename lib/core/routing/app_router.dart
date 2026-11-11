import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/listings/presentation/screens/create_listing_screen.dart';
import '../../features/listings/presentation/screens/listing_detail_screen.dart';
import '../../features/map_search/presentation/screens/home_map_search_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/recipe_copilot/presentation/screens/recipe_copilot_screen.dart';
import '../../features/recipe_copilot/presentation/screens/recipe_detail_screen.dart';
import '../../features/reservation/presentation/screens/qr_scanner_screen.dart';
import '../../features/reservation/presentation/screens/reservation_detail_screen.dart';
import '../../features/store_profile/presentation/screens/store_profile_screen.dart';
import 'route_paths.dart';

/// Chuyển đổi một Stream thành Listenable để GoRouter tự động reload khi Stream thay đổi (ví dụ: authStateChanges).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application GoRouter configuration supporting deep linking and standard navigation.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RoutePaths.login,
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    final isAuthRoute = location == RoutePaths.login ||
        location == RoutePaths.otpVerification;

    // 1. Chưa đăng nhập: chỉ cho phép vào /login hoặc /otp-verification
    if (!isLoggedIn) {
      return isAuthRoute ? null : RoutePaths.login;
    }

    // 2. Đã đăng nhập: không cho phép quay lại /login hoặc /otp-verification
    if (isAuthRoute || location == '/') {
      return RoutePaths.home;
    }

    // Cho phép đi tiếp vào các route bình thường
    return null;
  },
  routes: [
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.otpVerification,
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboardingRole,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: RoutePaths.home,
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: RoutePaths.mapSearch,
      builder: (context, state) => const HomeMapSearchScreen(),
    ),
    GoRoute(
      path: RoutePaths.recipeCopilot,
      builder: (context, state) => const RecipeCopilotScreen(),
    ),
    GoRoute(
      path: RoutePaths.recipeDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return RecipeDetailScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.createListing,
      builder: (context, state) => const CreateListingScreen(),
    ),
    GoRoute(
      path: RoutePaths.listingDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ListingDetailScreen(listingId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.reservationDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReservationDetailScreen(reservationId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.qrScanner,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return QrScannerScreen(reservationId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.chat,
      builder: (context, state) {
        final reservationId = state.pathParameters['reservationId'] ?? '';
        return ChatScreen(reservationId: reservationId);
      },
    ),
    GoRoute(
      path: RoutePaths.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RoutePaths.storeProfile,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return StoreProfileScreen(storeId: id);
      },
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Không tìm thấy trang: ${state.uri}'))),
);
