# OptiMeal - Ứng dụng Chia Sẻ Thực Phẩm Dư Thừa (Self-Pickup)

Ứng dụng di động kết nối người có thực phẩm dư (cá nhân/hộ gia đình, cửa hàng bánh mì, quán ăn, nhà hàng, siêu thị) với người có nhu cầu thực phẩm giá rẻ hoặc miễn phí. 

Mô hình vận hành cốt lõi là **Tự đến lấy (Self-pickup)** — không sử dụng shipper trung gian để tối ưu chi phí và nâng cao ý thức bảo vệ môi trường, giảm thiểu thất thoát thực phẩm.

---

## 🌟 Tính Năng Cốt Lõi

1. **Xác thực qua SĐT & Phân quyền**: Đăng nhập bằng SMS OTP (Firebase Auth), chọn vai trò **Cá nhân / Hộ gia đình**, **Cửa hàng / Nhà hàng / Siêu thị**, hoặc **Bếp ăn từ thiện / Điểm thiện nguyện**.
2. **Trang chủ tổng quan & Khám phá cộng đồng (Home Dashboard & Community Feed)**:
   - **Mô tả**: Màn hình trung tâm sau khi đăng nhập, hiển thị vị trí hiện tại (GPS), bảng chỉ số tác động cộng đồng (*Kg thực phẩm đã giải cứu hôm nay, số suất cơm thiện nguyện đang phục vụ quanh khu vực*).
   - **Thao tác nhanh (Quick Action Hub)**: Các phím tắt 1-chạm giúp điều hướng ngay đến: *"Ghim mẻ tặng lên bản đồ"*, *"Xem bản đồ thực phẩm quanh đây"*, *"Trợ lý AI Bếp ăn"*, và *"Quét mã QR bàn giao"*.
   - **Feed cập nhật trực tiếp**: Bảng tin tổng hợp các mẻ nguyên liệu dư mới được ghim gần bạn (kèm huy hiệu cảnh báo cần giải cứu gấp trong 24h) và danh sách các điểm phát cơm từ thiện đang mở cửa trong ngày.
3. **Bản đồ thời gian thực chia sẻ vị trí nguyên liệu, thực phẩm dư & Nơi phát đồ ăn miễn phí (Real-time Food Surplus & Donation Geolocation Map)**:
   - **Đăng bài & Ghim vị trí trực tiếp trên Map (Donor Post & Pinning)**: Người dùng (người cho / cửa hàng / bếp thiện nguyện) đăng bài bằng cách chọn/ghim trực tiếp vị trí mẻ nguyên liệu hoặc điểm phát đồ ăn trên bản đồ; điền chi tiết thông tin: phân loại danh mục (*Rau củ, Đồ khô, Thực phẩm tươi sống, Điểm phát cơm/đồ ăn nấu sẵn*), số lượng/trọng lượng, ảnh thực tế, hạn sử dụng (*Expiry date / Best before*), và khung giờ nhận hàng.
   - **Không gian địa lý & Tìm kiếm tương tác**: Bản đồ tích hợp GPS hiển thị trực quan các mẻ nguyên liệu sẵn sàng bàn giao cùng vị trí các điểm phát cơm từ thiện cố định/lưu động; hệ thống gom cụm đa lớp (*Cluster Map markers*), bộ lọc theo danh mục và bán kính (*1km - 10km*).
   - **Cơ chế nhận hàng trực tiếp (Self Pickup) & Chỉ đường**: Bên nhận tra cứu khoảng cách, kiểm tra số lượng tồn, chọn *"Giữ chỗ lấy hàng (Self Pickup)"*, kích hoạt chế độ chỉ đường từng bước (*Turn-by-turn routing*), và tự di chuyển đến nhận bàn giao qua mã QR xác thực hai chiều (*Double-handshake QR*).
4. **Trợ lý AI gợi ý thực đơn cho bếp ăn từ thiện (Smart Recipe Copilot)**:
   - **Mô tả**: Bếp ăn thiện nguyện thường nhận về các nhóm nguyên liệu phân tán, ngẫu nhiên. Trợ lý AI (LLM + RAG) tổng hợp danh sách nguyên liệu bếp đang có trong kho lạnh và đề xuất ngay 3–5 công thức món ăn dinh dưỡng số lượng lớn (suất ăn 50–200 người).
   - **Tiêu chí ưu tiên**: Tự động ưu tiên đưa các nguyên liệu có thời gian hết hạn ngắn nhất vào thực đơn bữa ăn tiếp theo để chống lãng phí; hướng dẫn kỹ thuật sơ chế và an toàn vệ sinh thực phẩm.
   - **UX/UI**: Giao diện dạng thẻ món ăn tương tác (*Recipe Cards*), danh sách checklist nguyên liệu kèm định lượng gia vị chi tiết, nút *"Tạo thực đơn mới"* chỉ bằng 1 chạm.

---

## 🏗️ Kiến Trúc Hệ Thống (Clean Architecture - Feature-First)

Mã nguồn được tổ chức theo chuẩn **Feature-First Clean Architecture**, đảm bảo tính độc lập, dễ mở rộng, kiểm thử và bảo trì:

```
lib/
  core/
    constants/          # Hằng số toàn ứng dụng (bán kính quét, danh mục thực phẩm...)
    theme/              # Bảng màu Eco Green & Pure White, ThemeData sáng/tối
    routing/            # Cấu hình GoRouter, danh sách route & deep links
    utils/              # Tiện ích tính khoảng cách (Haversine), format ngày giờ, geolocation
    errors/             # Phân cấp Failures & Exceptions
    network/            # Kiểm tra kết nối mạng (NetworkInfo abstraction)
    widgets/            # Reusable UI (PrimaryButton, StatusBadge, Loader, RecipeCard)
  features/
    auth/               # Đăng nhập SĐT, OTP, Onboarding phân quyền (Cá nhân, Cửa hàng, Bếp từ thiện)
    listings/           # Đăng tin & quản lý kho nguyên liệu thực phẩm dư
    map_search/         # Bản đồ thời gian thực (Cluster markers, lọc bán kính 1-10km, Turn-by-turn routing)
    recipe_copilot/     # Trợ lý AI gợi ý thực đơn (LLM Prompting, RAG công thức suất ăn 50-200 người)
    reservation/        # Giữ chỗ lấy hàng (Self Pickup) & Xác thực hai chiều (Double-handshake QR)
    store_profile/      # Hồ sơ bếp ăn thiện nguyện / cửa hàng đối tác & lịch phát cơm
    notifications/      # Dịch vụ thông báo nhận nguyên liệu mới & cảnh báo cận date
    profile/            # Hồ sơ cá nhân / tổ chức từ thiện, chỉ số tác động xã hội & cài đặt
  app.dart              # Cấu hình MaterialApp.router, Localization, Themes
  main.dart             # Entry point ứng dụng
test/
  unit/                 # Unit tests cho Domain UseCases & AI Prompts
  widget/               # Widget tests
  integration/          # Integration tests E2E
```

---

## 🛠️ Công Nghệ Sử Dụng

| Thành phần | Thư viện / Công nghệ | Vai trò |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart 3.x | Đa nền tảng Android & iOS |
| **State Management** | `flutter_riverpod` + `riverpod_annotation` | Quản lý state theo dạng reactive, testable |
| **AI Copilot** | Google Gemini API / OpenAI LLM + RAG | Tạo công thức nấu ăn suất ăn lớn 50-200 người từ nguyên liệu có sẵn |
| **Navigation** | `go_router` | Điều hướng khai báo, hỗ trợ deep link |
| **Maps & Routing** | `google_maps_flutter`, `geolocator`, `flutter_polyline_points` | Bản đồ thời gian thực, gom cụm (Cluster), chỉ đường Turn-by-turn |
| **Mã QR Xác Thực** | `qr_flutter`, `mobile_scanner` | Sinh và quét mã QR xác nhận hai chiều (Double-handshake QR) |
| **Backend & Realtime**| Firebase (Auth, Firestore, Storage, Messaging) | Xác thực OTP, đồng bộ vị trí nguyên liệu & kho lạnh thời gian thực |
| **Đa ngôn ngữ** | `flutter_localizations`, `intl` | Tiếng Việt & Tiếng Anh |
| **Testing** | `flutter_test`, `mocktail` | Viết unit tests cho domain layer |
| **Linting** | `flutter_lints` | Phân tích tĩnh code nghiêm ngặt |

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
- `/onboarding-role`: Chọn vai trò (Cá nhân, Cửa hàng / Siêu thị, Bếp ăn từ thiện)
- `/home`: Trang chính bản đồ thời gian thực (Cluster Map, bộ lọc bán kính & danh mục)
- `/create-listing`: Tạo tin đăng mẻ nguyên liệu / thực phẩm dư
- `/listing/:id`: Xem chi tiết nguyên liệu, điểm phát đồ ăn & bấm giữ chỗ lấy hàng
- `/reservation/:id`: Màn hình giữ chỗ & mã QR xác thực nhận hàng hai chiều
- `/reservation/:id/scan`: Quét mã QR xác nhận bàn giao nguyên liệu
- `/recipe-copilot`: Trợ lý AI gợi ý thực đơn cho bếp ăn từ thiện (Smart Recipe Copilot)
- `/recipe/:id`: Chi tiết công thức nấu số lượng lớn (50-200 người) & checklist nguyên liệu
- `/store/:id`: Hồ sơ điểm phát đồ ăn / bếp thiện nguyện / cửa hàng đối tác
- `/profile`: Thông tin tài khoản, chỉ số kg thực phẩm đã giải cứu & cài đặt

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
