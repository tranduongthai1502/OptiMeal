import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/food_listing.dart';
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
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

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
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final currentLat = double.tryParse(_latitudeController.text.trim());
    final currentLng = double.tryParse(_longitudeController.text.trim());

    final result = await LocationPickerDialog.show(
      context,
      initialLatitude: currentLat,
      initialLongitude: currentLng,
      maxRadiusKm: 1.0,
    );

    if (result != null && mounted) {
      setState(() {
        _latitudeController.text = result.latitude.toStringAsFixed(6);
        _longitudeController.text = result.longitude.toStringAsFixed(6);
        if (result.address != null && result.address!.trim().isNotEmpty) {
          _addressController.text = result.address!;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã chọn vị trí bàn giao (Cách bạn ${LocationUtils.formatDistance(result.distanceKm)})',
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
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
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
                // Map Pinning Preview Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Vị trí ghim trên Bản đồ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _openMapPicker,
                            icon: const Icon(Icons.map_rounded, size: 18),
                            label: const Text('Chọn trên map'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _openMapPicker,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mở bản đồ chọn điểm nhận (giới hạn trong bán kính 1km)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Vĩ độ *',
                                hintText: 'Nhập vĩ độ',
                              ),
                              validator: (value) {
                                final latitude = double.tryParse(value ?? '');
                                if (latitude == null ||
                                    latitude < -90 ||
                                    latitude > 90) {
                                  return 'Nhập vĩ độ hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Kinh độ *',
                                hintText: 'Nhập kinh độ',
                              ),
                              validator: (value) {
                                final longitude = double.tryParse(value ?? '');
                                if (longitude == null ||
                                    longitude < -180 ||
                                    longitude > 180) {
                                  return 'Nhập kinh độ hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bạn có thể bấm "Chọn trên map" để tự động điền tọa độ và địa chỉ trong phạm vi 1km.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
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

                // Category Selector
                const Text(
                  'Danh mục phân loại *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<FoodCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: FoodCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.displayName),
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

                // Title
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

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả chi tiết',
                    hintText: 'Tình trạng, nguồn gốc, quy cách đóng gói...',
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity & Unit & Condition row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
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
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(labelText: 'Đơn vị'),
                        items: const [
                          DropdownMenuItem(value: 'kg', child: Text('kg')),
                          DropdownMenuItem(value: 'suất', child: Text('suất')),
                          DropdownMenuItem(value: 'phần', child: Text('phần')),
                          DropdownMenuItem(value: 'hộp', child: Text('hộp')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _unit = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<FoodCondition>(
                        initialValue: _condition,
                        decoration: const InputDecoration(
                          labelText: 'Hình thức',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: FoodCondition.free,
                            child: Text('Tặng 0đ'),
                          ),
                          DropdownMenuItem(
                            value: FoodCondition.paid,
                            child: Text('Giá cứu hộ'),
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

                // Allergens
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

                // Submit Button
                PrimaryButton(
                  label: _uploadStatusMessage ??
                      'Xác nhận ghim mẻ thực phẩm lên Bản đồ',
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
