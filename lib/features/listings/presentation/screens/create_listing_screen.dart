import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/food_listing.dart';
import '../../../map_search/presentation/providers/location_provider.dart';
import '../../../map_search/presentation/providers/map_search_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/location_picker_dialog.dart';

class PickedPhotoItem {
  final String name;
  final Uint8List bytes;

  const PickedPhotoItem({required this.name, required this.bytes});
}

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();

  /// Vị trí được chọn bằng map picker — bắt buộc phải có trước khi submit.
  LatLng? _selectedLocation;

  final ImagePicker _picker = ImagePicker();
  final List<PickedPhotoItem> _foodPhotos = [];
  final List<PickedPhotoItem> _locationPhotos = [];
  String? _uploadStatusMessage;

  FoodCategory _category = FoodCategory.vegetables;
  String _unit = 'kg';
  FoodCondition _condition = FoodCondition.free;
  bool _isLoading = false;
  final List<String> _selectedAllergens = [];

  final List<String> _availableAllergens = [
    'Hải sản',
    'Sữa',
    'Đậu phộng',
    'Gluten',
    'Trứng',
    'Đậu nành',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pos = ref.read(locationProvider).position;
      if (pos != null && _selectedLocation == null && mounted) {
        setState(() {
          _selectedLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final currentGps = ref.read(locationProvider).position;
    final initialLat = _selectedLocation?.latitude ?? currentGps?.latitude;
    final initialLng = _selectedLocation?.longitude ?? currentGps?.longitude;

    final result = await LocationPickerDialog.show(
      context,
      userLatitude: currentGps?.latitude,
      userLongitude: currentGps?.longitude,
      initialLatitude: initialLat,
      initialLongitude: initialLng,
      maxRadiusKm: 1.0,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedLocation = LatLng(result.latitude, result.longitude);
        if (result.address != null && result.address!.trim().isNotEmpty) {
          _addressController.text = result.address!;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.distanceKm > 0
                ? 'Đã chọn vị trí bàn giao (Cách bạn ${LocationUtils.formatDistance(result.distanceKm)})'
                : 'Đã chọn vị trí bàn giao trên bản đồ',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickPhoto({
    required ImageSource source,
    required bool isLocationPhoto,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 65,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (isLocationPhoto) {
            _locationPhotos
                .add(PickedPhotoItem(name: image.name, bytes: bytes));
          } else {
            _foodPhotos.add(PickedPhotoItem(name: image.name, bytes: bytes));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerSheet({required bool isLocationPhoto}) {
    final targetList = isLocationPhoto ? _locationPhotos : _foodPhotos;
    final maxCount = isLocationPhoto ? 2 : 4;

    if (targetList.length >= maxCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tối đa $maxCount ảnh cho mục này.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Text(
                isLocationPhoto
                    ? 'Chụp / Chọn ảnh điểm nhận ngoài đời'
                    : 'Chụp / Chọn ảnh mẻ thực phẩm',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: const Text('Chụp ảnh mới (Camera)'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(
                  source: ImageSource.camera,
                  isLocationPhoto: isLocationPhoto,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Chọn ảnh từ thư viện'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(
                  source: ImageSource.gallery,
                  isLocationPhoto: isLocationPhoto,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _uploadPhotos(
    List<PickedPhotoItem> items,
  ) async {
    final List<String> urls = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      // Lưu trực tiếp dưới dạng Base64 Data URI vào Cloud Firestore (hoàn toàn miễn phí, 0 lỗi CORS)
      final base64String = base64Encode(item.bytes);
      urls.add('data:image/jpeg;base64,$base64String');
    }
    return urls;
  }

  Future<void> _handleSubmit() async {
    // Kiểm tra vị trí trước khi validate form
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn vị trí trên bản đồ.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập trước khi đăng tin.'),
          backgroundColor: AppColors.error,
        ),
      );
      await context.push(RoutePaths.login);
      return;
    }

    if (user.role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn vai trò trước khi đăng tin.'),
          backgroundColor: AppColors.warning,
        ),
      );
      await context.push(RoutePaths.onboardingRole);
      return;
    }

    final totalCount = _foodPhotos.length + _locationPhotos.length;
    setState(() {
      _isLoading = true;
      _uploadStatusMessage =
          totalCount > 0 ? 'Đang lưu $totalCount ảnh vào Firestore...' : null;
    });

    final now = DateTime.now();
    final isCharity = _category == FoodCategory.charityMealPoint;
    final listingId = 'listing-${now.millisecondsSinceEpoch}';

    // Lưu ảnh mẻ thực phẩm & ảnh địa điểm nhận dạng Base64 trực tiếp vào Firestore doc
    final foodUrls = await _uploadPhotos(_foodPhotos);
    final locationUrls = await _uploadPhotos(_locationPhotos);

    final newListing = FoodListing(
      id: listingId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      photos: foodUrls,
      locationPhotos: locationUrls,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
      unit: _unit,
      category: _category,
      isCharityPoint: isCharity,
      condition: _condition,
      price: _condition == FoodCondition.paid
          ? double.tryParse(_priceController.text.trim())
          : null,
      expiresAt: now.add(const Duration(hours: 12)),
      pickupWindowStart: now,
      pickupWindowEnd: now.add(const Duration(hours: 6)),
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      addressText: _addressController.text.trim(),
      allergenTags: _selectedAllergens,
      ownerId: user.id,
      ownerName: user.displayName ?? user.phoneNumber,
      ownerType: user.role!,
      status: ListingStatus.available,
      createdAt: now,
    );

    final result = await ref.read(createListingUseCaseProvider)(newListing);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _uploadStatusMessage = null;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng tin và ghim vị trí lên bản đồ thành công!'),
            backgroundColor: AppColors.primary,
          ),
        );
        ref.invalidate(nearbyListingsProvider);
        ref.invalidate(filteredNearbyListingsProvider);
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final locationState = ref.watch(locationProvider);

    // Tự động gán vị trí nếu có GPS và chưa gán
    if (_selectedLocation == null && locationState.position != null) {
      _selectedLocation = LatLng(
        locationState.position!.latitude,
        locationState.position!.longitude,
      );
    }
    final user = authState.user;

    if (user == null) {
      return _buildLoginRequiredView(context);
    }

    if (user.role == null) {
      return _buildRoleRequiredView(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ghim mẻ thực phẩm / Điểm phát')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Chọn vị trí bằng bản đồ ──────────────────────────────────
                const Text(
                  'Vị trí ghim trên Bản đồ *',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _openLocationPicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedLocation != null
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: _selectedLocation != null ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedLocation != null
                              ? Icons.location_on_rounded
                              : Icons.add_location_alt_outlined,
                          color: _selectedLocation != null
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _selectedLocation == null
                              ? const Text(
                                  'Bấm để chọn vị trí trên bản đồ',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Đã chọn vị trí ✓',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}'
                                      '  Lng: ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                                      style: const TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: _selectedLocation != null
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Địa chỉ văn bản ──────────────────────────────────────────
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ bàn giao trực tiếp *',
                    hintText: 'Nhập số nhà, tên đường, phường/quận...',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập địa chỉ bàn giao'
                      : null,
                ),
                const SizedBox(height: 20),

                // 1. Ảnh địa điểm nhận ngoài đời
                _buildPhotoPickerCard(
                  title: 'Ảnh địa điểm nhận ngoài đời',
                  subtitle:
                      'Chụp mặt tiền, cổng nhà, biển hiệu hoặc bàn nhận đồ để người nhận dễ tìm thấy.',
                  icon: Icons.storefront_outlined,
                  items: _locationPhotos,
                  maxCount: 2,
                  isLocationPhoto: true,
                ),
                const SizedBox(height: 16),

                // 2. Hình ảnh mặt hàng / thực phẩm
                _buildPhotoPickerCard(
                  title: 'Hình ảnh mặt hàng / thực phẩm',
                  subtitle:
                      'Chụp mẻ nguyên liệu, đồ ăn, phần cơm hoặc quy cách đóng gói thực tế.',
                  icon: Icons.fastfood_outlined,
                  items: _foodPhotos,
                  maxCount: 4,
                  isLocationPhoto: false,
                ),
                const SizedBox(height: 20),

                // ── Danh mục ──────────────────────────────────────────────────
                const Text(
                  'Danh mục phân loại *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<FoodCategory>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: FoodCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _category = val;
                        if (val == FoodCategory.vegetables ||
                            val == FoodCategory.dryGoods ||
                            val == FoodCategory.freshMeatFish) {
                          _unit = 'kg';
                        } else if (val == FoodCategory.charityMealPoint) {
                          _unit = 'suất';
                          _condition = FoodCondition.free;
                        } else {
                          _unit = 'hộp';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // ── Tiêu đề ───────────────────────────────────────────────────
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: _category == FoodCategory.charityMealPoint
                        ? 'Tên điểm phát cơm từ thiện *'
                        : 'Tên mẻ nguyên liệu / thực phẩm *',
                    hintText: _category == FoodCategory.charityMealPoint
                        ? 'Ví dụ: Bếp Cơm Nụ Cười - Phát 150 suất cơm'
                        : 'Ví dụ: 30kg Bắp cải & Cà chua bi tươi',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập tên tiêu đề'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Mô tả ─────────────────────────────────────────────────────
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả chi tiết',
                    hintText: 'Tình trạng, nguồn gốc, quy cách đóng gói...',
                  ),
                ),
                const SizedBox(height: 16),

                // ── Số lượng + đơn vị + hình thức ────────────────────────────
                // FIX overflow: isExpanded + flex cân đối + khoảng cách nhỏ lại
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng *',
                        ),
                        validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                            ? 'Số lượng > 0'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Đơn vị'),
                        items: const [
                          DropdownMenuItem(
                            value: 'kg',
                            child: Text('kg', overflow: TextOverflow.ellipsis),
                          ),
                          DropdownMenuItem(
                            value: 'suất',
                            child:
                                Text('suất', overflow: TextOverflow.ellipsis),
                          ),
                          DropdownMenuItem(
                            value: 'phần',
                            child:
                                Text('phần', overflow: TextOverflow.ellipsis),
                          ),
                          DropdownMenuItem(
                            value: 'hộp',
                            child: Text('hộp', overflow: TextOverflow.ellipsis),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _unit = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<FoodCondition>(
                        initialValue: _condition,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Hình thức',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: FoodCondition.free,
                            child: Text(
                              'Tặng 0đ',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: FoodCondition.paid,
                            child: Text(
                              'Giá cứu hộ',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: _category == FoodCategory.charityMealPoint
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() => _condition = val);
                                }
                              },
                      ),
                    ),
                  ],
                ),

                if (_condition == FoodCondition.paid) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá cứu hộ (VND) *',
                      hintText: 'Ví dụ: 15000',
                      suffixText: 'đ',
                    ),
                    validator: (v) {
                      if (_condition == FoodCondition.paid) {
                        final p = double.tryParse(v ?? '');
                        if (p == null || p <= 0) return 'Nhập giá > 0đ';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // ── Dị ứng thực phẩm ──────────────────────────────────────────
                const Text(
                  'Cảnh báo dị ứng thực phẩm (nếu có):',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableAllergens.map((allergen) {
                    final isSelected = _selectedAllergens.contains(allergen);
                    return FilterChip(
                      label: Text(allergen),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAllergens.add(allergen);
                          } else {
                            _selectedAllergens.remove(allergen);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ── Nút submit ─────────────────────────────────────────────────
                // FIX overflow: rút ngắn label để vừa Row icon + Text trong
                // PrimaryButton trên màn hình hẹp.
                PrimaryButton(
                  label: _uploadStatusMessage ?? 'Ghim lên Bản đồ',
                  icon: Icons.push_pin_rounded,
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPickerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<PickedPhotoItem> items,
    required int maxCount,
    required bool isLocationPhoto,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: items.isNotEmpty
              ? (isLocationPhoto ? AppColors.secondary : AppColors.primary)
                  .withValues(alpha: 0.4)
              : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isLocationPhoto
                          ? AppColors.secondary
                          : AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color:
                      isLocationPhoto ? AppColors.secondary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: items.length == maxCount
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}/$maxCount ảnh',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: items.length == maxCount
                        ? AppColors.success
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            item.bytes,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                items.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (items.length < maxCount)
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showImagePickerSheet(
                      isLocationPhoto: isLocationPhoto,
                    ),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 24,
                            color: isLocationPhoto
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Thêm ảnh',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequiredView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ghim mẻ thực phẩm / Điểm phát')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primary,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Yêu cầu đăng nhập',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn cần đăng nhập bằng số điện thoại để ghim mẻ thực phẩm hoặc điểm phát cơm lên bản đồ. Điều này giúp bảo đảm tính xác thực và thông tin liên hệ cho người nhận.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Đăng nhập ngay',
                  icon: Icons.login_rounded,
                  onPressed: () => context.push(RoutePaths.login),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleRequiredView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ghim mẻ thực phẩm / Điểm phát')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.secondary,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Chọn vai trò của bạn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vui lòng chọn vai trò (Cá nhân/Hộ gia đình, Cửa hàng/Quán ăn hoặc Bếp từ thiện) để kích hoạt quyền đăng mẻ thực phẩm.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Chọn vai trò ngay',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.push(RoutePaths.onboardingRole),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
