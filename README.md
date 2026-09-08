# OptiMeal - Ứng dụng Chia Sẻ Thực Phẩm Dư Thừa (Self-Pickup)

Ứng dụng di động kết nối người có thực phẩm dư (cá nhân/hộ gia đình, cửa hàng bánh mì, quán ăn, nhà hàng, siêu thị) với người có nhu cầu thực phẩm giá rẻ hoặc miễn phí. 

Mô hình vận hành cốt lõi là **Tự đến lấy (Self-pickup)** — không sử dụng shipper trung gian để tối ưu chi phí và nâng cao ý thức bảo vệ môi trường, giảm thiểu thất thoát thực phẩm.

---

## 🌟 Tính Năng Chính (MVP)

1. **Xác thực qua SĐT & Phân quyền**: Đăng nhập bằng SMS OTP (Firebase Auth), chọn vai trò **Cá nhân** hoặc **Cửa hàng / Nhà hàng**.
2. **Quản lý tin đăng (Listings)**: Đăng tin thực phẩm dư kèm ảnh, số lượng, hình thức (Miễn phí 0đ hoặc Giá cứu hộ có phí), khung giờ nhận và cảnh báo dị ứng thực phẩm (Allergen tags).
3. **Bản đồ & Tìm kiếm (Map & Search)**: Tích hợp Google Maps + Geolocation tính khoảng cách thực tế, lọc theo bán kính (mặc định 3km), lọc món miễn phí/có phí, chuyển đổi linh hoạt Map View & List View.
4. **Giữ chỗ & Đếm ngược (Reservation & Countdown)**: Người nhận đặt giữ chỗ trong thời gian giới hạn **20 phút**, có đồng hồ đếm ngược trực tiếp. Hết 20 phút tự động hủy và trả thực phẩm về trạng thái có sẵn.
5. **Xác nhận giao nhận bằng mã QR**: Sinh mã QR động cho lượt giữ chỗ. Người cho dùng camera quét mã QR (`mobile_scanner`) hoặc bấm xác nhận để hoàn tất giao dịch.
6. **Hệ thống Điểm Uy Tín & Chống Bùng Hẹn (Reputation & Anti No-show)**: Đánh giá 2 chiều (1-5 sao + bình luận). Tự động theo dõi số lần vắng mặt (`noShowCount >= 3`) để giới hạn quyền giữ chỗ của người vi phạm.
7. **Tin nhắn trao đổi (Chat 1-1)**: Nhắn tin trực tiếp giữa người cho và người nhận gắn theo tin đăng/lượt giữ chỗ.
8. **Hồ sơ cửa hàng đối tác (Store Profile)**: Hiển thị giờ mở cửa, loại hình, khung giờ đăng thực phẩm cuối ngày định kỳ.

---

## 🏗️ Kiến Trúc Hệ Thống (Clean Architecture - Feature-First)

Mã nguồn được tổ chức theo chuẩn **Feature-First Clean Architecture**, đảm bảo tính độc lập, dễ mở rộng, kiểm thử và bảo trì:

```
lib/
  core/
    constants/          # Hằng số toàn ứng dụng (thời gian giữ chỗ, bán kính...)
    theme/              # Bảng màu Eco Green & Deep Navy, ThemeData sáng/tối
    routing/            # Cấu hình GoRouter, danh sách route & deep links
    utils/              # Tiện ích tính khoảng cách (Haversine), format ngày giờ
    errors/             # Phân cấp Failures & Exceptions
    network/            # Kiểm tra kết nối mạng (NetworkInfo abstraction)
    widgets/            # Reusable UI (PrimaryButton, StatusBadge, Loader, ErrorView)
  features/
    auth/               # Đăng nhập SĐT, OTP, Onboarding chọn vai trò
    listings/           # Đăng tin & xem chi tiết thực phẩm dư
    map_search/         # Bản đồ Google Maps, tìm kiếm theo bán kính
    reservation/        # Giữ chỗ 20 phút, đồng hồ đếm ngược, quét mã QR
    reputation/         # Đánh giá 2 chiều, điểm uy tín, phạt No-show
    chat/               # Chat 1-1 realtime giữa 2 bên
    store_profile/      # Hồ sơ cửa hàng, lịch đăng lặp lại
    notifications/      # Dịch vụ thông báo cục bộ & đẩy FCM
    profile/            # Hồ sơ cá nhân, chỉ số giao dịch, cài đặt
  app.dart              # Cấu hình MaterialApp.router, Localization, Themes
  main.dart             # Entry point ứng dụng
test/
  unit/                 # Unit tests cho Domain UseCases
  widget/               # Widget tests
  integration/          # Integration tests E2E
```

---

## 🛠️ Công Nghệ Sử Dụng

| Thành phần | Thư viện / Công nghệ | Vai trò |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart 3.x | Đa nền tảng Android & iOS |
| **State Management** | `flutter_riverpod` + `riverpod_annotation` | Quản lý state theo dạng reactive, testable |
| **Error Handling** | `fpdart` | Xử lý lỗi hàm `Either<Failure, T>` tường minh |
| **Navigation** | `go_router` | Điều hướng khai báo, hỗ trợ deep link |
| **Maps & Vị trí** | `google_maps_flutter`, `geolocator`, `geocoding` | Bản đồ và tính toán khoảng cách |
| **Mã QR & Camera** | `qr_flutter`, `mobile_scanner` | Sinh và quét mã QR xác nhận nhận hàng |
| **Backend Abstraction**| Firebase (Auth, Firestore, Storage, Messaging) | Có sẵn Repository Interface để thay thế backend |
| **Đa ngôn ngữ** | `flutter_localizations`, `intl` | Mặc định Tiếng Việt (sẵn khung EN) |
| **Testing** | `flutter_test`, `mocktail` | Viết unit tests cho domain layer |
| **Linting** | `flutter_lints` | Phân tích tĩnh code nghiêm ngặt |

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### Yêu cầu tiên quyết
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản 3.16 trở lên).
- Android Studio hoặc Xcode để chạy emulator/simulator.

### Các bước khởi chạy
1. **Clone repository và di chuyển vào thư mục dự án**:
   ```bash
   cd OptiMeal
   ```

2. **Cài đặt các thư viện**:
   ```bash
   flutter pub get
   ```

3. **Tạo file cấu hình môi trường từ mẫu**:
   ```bash
   cp .env.example .env
   ```
   *(Điền API keys của bạn vào file `.env`)*

4. **Chạy bộ kiểm thử (Unit tests)**:
   ```bash
   flutter test
   ```

5. **Chạy ứng dụng**:
   ```bash
   flutter run
   ```

---

## 📋 Danh Sách Tuyến Đường (Routes)

- `/login`: Đăng nhập bằng số điện thoại
- `/otp-verification`: Nhập mã xác thực OTP
- `/onboarding-role`: Chọn vai trò (Cá nhân hoặc Cửa hàng)
- `/home`: Trang chính xem bản đồ và danh sách thực phẩm
- `/create-listing`: Tạo tin đăng chia sẻ thực phẩm
- `/listing/:id`: Xem chi tiết món ăn & bấm giữ chỗ
- `/reservation/:id`: Màn hình đếm ngược 20 phút & hiển thị mã QR
- `/reservation/:id/scan`: Người cho thực phẩm quét mã QR xác nhận
- `/chat/:reservationId`: Nhắn tin trao đổi giữa 2 bên
- `/store/:id`: Xem hồ sơ doanh nghiệp / cửa hàng
- `/profile`: Xem điểm uy tín, lịch sử và cài đặt

---

## 📌 Các Bước Cần Làm Tiếp Theo (Thủ Công)

Sau khi codebase đã được dựng sẵn khung hoàn chỉnh, bạn thực hiện các bước sau để kết nối dịch vụ thật:

1. **Tạo Firebase Project**:
   - Truy cập [Firebase Console](https://console.firebase.google.com/) tạo project mới.
   - Thêm ứng dụng Android (`google-services.json` vào thư mục `android/app/`).
   - Thêm ứng dụng iOS (`GoogleService-Info.plist` vào thư mục `ios/Runner/`).
   - Cài đặt Firebase CLI và chạy `flutterfire configure`.

2. **Bật Firebase Authentication**:
   - Bật phương thức đăng nhập **Phone** trong tab *Authentication > Sign-in method*.
   - Đăng ký số điện thoại test (ví dụ: `+84987654321` với OTP `123456`) để dev không tốn SMS quota.

3. **Tạo Firestore Database & Bảo Mật Rules**:
   - Tạo collections: `users`, `listings`, `reservations`, `chats`, `reviews`.
   - Cấu hình Firestore Security Rules đảm bảo chỉ người tham gia giao dịch mới được đọc/ghi chat và thông tin giữ chỗ.

4. **Lấy Google Maps API Key**:
   - Truy cập [Google Cloud Console](https://console.cloud.google.com/), kích hoạt **Maps SDK for Android** và **Maps SDK for iOS**.
   - Khai báo API key vào `android/app/src/main/AndroidManifest.xml` và `ios/Runner/AppDelegate.swift`.

5. **Cấp quyền Camera & Vị trí**:
   - **Android**: Đã khai báo trong `AndroidManifest.xml` (`CAMERA`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`).
   - **iOS**: Khai báo `NSCameraUsageDescription` và `NSLocationWhenInUseUsageDescription` trong file `ios/Runner/Info.plist`.
