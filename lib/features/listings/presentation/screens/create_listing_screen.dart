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
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _addressController = TextEditingController(text: '180 Hai Bà Trưng, Quận 1, TP.HCM');

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
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final newListing = FoodListing(
      id: 'listing-${now.millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      photos: [
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
      condition: _condition,
      price: _condition == FoodCondition.paid ? double.tryParse(_priceController.text.trim()) : null,
      expiresAt: now.add(const Duration(hours: 4)),
      pickupWindowStart: now,
      pickupWindowEnd: now.add(const Duration(hours: 2)),
      latitude: 10.7769,
      longitude: 106.7009,
      addressText: _addressController.text.trim(),
      allergenTags: _selectedAllergens,
      ownerId: 'current-user-id',
      ownerName: 'Tôi (Người đăng)',
      ownerType: UserRole.individual,
      status: ListingStatus.available,
      createdAt: now,
    );

    final result = await ref.read(createListingUseCaseProvider)(newListing);

    setState(() => _isLoading = false);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
        );
      },
      (created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng tin thực phẩm thành công!'), backgroundColor: AppColors.primary),
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
        title: const Text('Đăng tin thực phẩm dư'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo picker placeholder
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4), style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          'Chụp ảnh thực phẩm (Tối đa 3 ảnh)',
                          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên món ăn / thực phẩm *',
                    hintText: 'Ví dụ: 3 phần cơm sườn, 4 bánh mì...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên thực phẩm' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả chi tiết',
                    hintText: 'Tình trạng, cách đóng gói, nguồn gốc...',
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity & Condition row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng phần/hộp *',
                        ),
                        validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Số lượng > 0' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<FoodCondition>(
                        value: _condition,
                        decoration: const InputDecoration(labelText: 'Hình thức *'),
                        items: const [
                          DropdownMenuItem(value: FoodCondition.free, child: Text('Miễn phí (0đ)')),
                          DropdownMenuItem(value: FoodCondition.paid, child: Text('Có phí cứu hộ')),
                        ],
                        onChanged: (val) {
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
                      if (_condition == FoodCondition.paid && (double.tryParse(v ?? '') ?? 0) <= 0) {
                        return 'Vui lòng nhập giá hợp lệ';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ nhận hàng (Self-pickup) *',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
                ),

                const SizedBox(height: 20),
                const Text(
                  'Cảnh báo dị ứng thực phẩm (nếu có):',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                PrimaryButton(
                  label: 'Đăng tin ngay',
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline_rounded,
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
