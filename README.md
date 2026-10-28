# OptiMeal

Ứng dụng chia sẻ thực phẩm dư thừa — kết nối người cho và người nhận theo mô hình tự đến lấy (self-pickup).

---

## Cài đặt tính năng Chỉ đường (OpenRouteService)

Tính năng "Xem đường đi" dùng **[OpenRouteService](https://openrouteservice.org/)** — hoàn toàn miễn phí, không cần thẻ thanh toán.

### 1. Lấy API Key miễn phí
1. Đăng ký tại https://openrouteservice.org/
2. Vào **Dashboard → Tokens → Request a token**
3. Copy API key

### 2. Chạy ứng dụng kèm API key
```bash
flutter run --dart-define=ORS_API_KEY=your_api_key_here
```

### 3. Build release
```bash
flutter build apk --dart-define=ORS_API_KEY=your_api_key_here
flutter build ipa --dart-define=ORS_API_KEY=your_api_key_here
```

> ⚠️ **Không commit API key vào source code.** Dùng CI/CD secrets hoặc file `.env` (không track) để quản lý.

### Hạn mức miễn phí ORS
| Mã lỗi | Ý nghĩa | Cách xử lý |
|---|---|---|
| HTTP 403 | Vượt hạn mức ngày (2.000 req/ngày) | Thử lại ngày mai |
| HTTP 429 | Gọi quá nhanh | Đợi vài giây |
| Network error | Mất kết nối | Kiểm tra WiFi/4G |

---

## Biến môi trường (dart-define)

| Biến | Mô tả | Bắt buộc? |
|---|---|---|
| `ORS_API_KEY` | API key OpenRouteService | Có (để dùng chỉ đường) |

---

## Firestore — Cấu hình thủ công cần làm

### Composite Index

Collection `food_listings`:

| Field | Hướng |
|---|---|
| `status` | Ascending |
| `expiresAt` | Ascending |

**Tạo tại:** Firebase Console → Firestore Database → Indexes → Add Composite Index

### Security Rules gợi ý
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /food_listings/{listingId} {
      // Ai cũng đọc được listing available
      allow read: if true;
      // Chỉ người đăng nhập mới tạo được
      allow create: if request.auth != null;
      // Chỉ owner mới sửa/xoá
      allow update: if request.auth != null &&
        (request.auth.uid == resource.data.ownerId ||
         // Hoặc người nhận đơn (claim transaction)
         request.resource.data.status == 'reserved');
      allow delete: if request.auth.uid == resource.data.ownerId;
    }
  }
}
```

---

## Tính năng bản đồ đã triển khai

- ✅ Bản đồ OSM với attribution đúng chuẩn ToS
- ✅ Xin quyền GPS, fallback Đà Nẵng nếu từ chối
- ✅ Stream realtime marker món ăn (Firestore snapshots + Haversine)
- ✅ CircleLayer bán kính tìm kiếm
- ✅ Bottom sheet chi tiết + nhận đơn (Firestore transaction)
- ✅ Chỉ đường ORS + PolylineLayer + fitCamera
- ✅ Mở app bản đồ ngoài (Google Maps link, không cần API key)
- ✅ Map picker khi tạo đơn

---

## Cấu trúc thư mục bản đồ

```
lib/features/map_search/
├── data/
│   └── services/
│       └── ors_routing_service.dart   # ORS API client
├── domain/
│   └── entities/
│       ├── route_result.dart           # Data class kết quả tuyến đường
│       └── search_filter.dart          # Bộ lọc tìm kiếm
├── presentation/
│   ├── providers/
│   │   ├── location_provider.dart      # GPS stream provider
│   │   ├── map_search_provider.dart    # Stream listings realtime
│   │   └── routing_provider.dart      # ORS FutureProvider.family
│   ├── screens/
│   │   ├── home_map_search_screen.dart # Màn hình bản đồ chính
│   │   └── location_picker_screen.dart # Chọn vị trí khi tạo đơn
│   └── widgets/
│       ├── listing_bottom_sheet.dart   # Bottom sheet chi tiết đơn
│       ├── map_controls.dart           # Search bar, category pills
│       └── map_pin_widgets.dart        # Marker, beacon, cluster pin
```
