import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/food_listing.dart';
import '../providers/listings_provider.dart';

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
  final _quantityController = TextEditingController(text: '10');
  final _priceController = TextEditingController();
  final _addressController =
      TextEditingController(text: '180 Hai Bà Trưng, Phường Đa Kao, Quận 1, TP.HCM');

  FoodCategory _category = FoodCategory.vegetables;
  String _unit = 'kg';
  FoodCondition _condition = FoodCondition.free;
  bool _isLoading = false;
  double _selectedLat = 10.7769;
  double _selectedLng = 106.7009;
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
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final isCharity = _category == FoodCategory.charityMealPoint;

    final newListing = FoodListing(
      id: 'listing-${now.millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      photos: [
        isCharity
            ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80'
            : 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
      ],
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
      latitude: _selectedLat,
      longitude: _selectedLng,
      addressText: _addressController.text.trim(),
      allergenTags: _selectedAllergens,
      ownerId: 'current-user-id',
      ownerName: isCharity ? 'Bếp Ăn Thiện Nguyện' : 'Cửa Hàng / Người Tặng',
      ownerType: isCharity ? UserRole.charityKitchen : UserRole.store,
      status: ListingStatus.available,
      createdAt: now,
    );

    final result = await ref.read(createListingUseCaseProvider)(newListing);

    setState(() => _isLoading = false);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(failure.message), backgroundColor: AppColors.error),
        );
      },
      (created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đăng tin và ghim vị trí lên bản đồ thành công!'),
              backgroundColor: AppColors.primary),
        );
        ref.invalidate(nearbyListingsProvider);
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghim mẻ thực phẩm / Điểm phát'),
      ),
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
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Vị trí ghim trên Bản đồ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedLat = 10.7769;
                                _selectedLng = 106.7009;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Đã cập nhật tọa độ GPS hiện tại')),
                              );
                            },
                            icon: const Icon(Icons.my_location, size: 16),
                            label: const Text('GPS của tôi'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                      Text(
                        'Tọa độ ghim: ${_selectedLat.toStringAsFixed(4)}, ${_selectedLng.toStringAsFixed(4)} (Người nhận sẽ được chỉ đường đến đây)',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
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
                        decoration:
                            const InputDecoration(labelText: 'Hình thức'),
                        items: const [
                          DropdownMenuItem(
                              value: FoodCondition.free,
                              child: Text('Tặng 0đ')),
                          DropdownMenuItem(
                              value: FoodCondition.paid,
                              child: Text('Giá cứu hộ')),
                        ],
                        onChanged: _category == FoodCategory.charityMealPoint
                            ? null
                            : (val) {
                                if (val != null) setState(() => _condition = val);
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
                  label: 'Xác nhận ghim mẻ thực phẩm lên Bản đồ',
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
}
