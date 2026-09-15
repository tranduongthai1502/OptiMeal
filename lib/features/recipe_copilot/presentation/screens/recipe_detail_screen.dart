import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/recipe_copilot_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeDetailProvider(recipeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công thức nấu lớn'),
      ),
      body: recipeAsync.when(
        loading: () => const AppLoadingIndicator(message: 'Đang tải công thức...'),
        error: (err, _) => AppErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(recipeDetailProvider(recipeId)),
        ),
        data: (recipe) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Suất ăn: ${recipe.targetPortions} người',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Thời gian: ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} phút',
                            style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recipe.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.description,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // AI Food Safety Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Hướng dẫn sơ chế & An toàn vệ sinh (AI)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...recipe.safetyNotes.map((note) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ingredients Checklist
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checklist nguyên liệu & gia vị (${recipe.targetPortions} suất):',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ...recipe.ingredients.map((ing) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                ing.isShortExpiry
                                    ? Icons.timer_outlined
                                    : Icons.check_circle_outline,
                                size: 18,
                                color: ing.isShortExpiry
                                    ? AppColors.warning
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ing.name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${ing.amount.toStringAsFixed(1)} ${ing.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: ing.isShortExpiry
                                      ? AppColors.warning
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cooking Steps
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quy trình chế biến chảo lớn (Batch Steps):',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ...recipe.cookingSteps.asMap().entries.map((entry) {
                        final stepIndex = entry.key + 1;
                        final stepText = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.primaryContainer,
                                child: Text(
                                  '$stepIndex',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  stepText,
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: 'Bắt đầu nấu & Cập nhật kho lạnh',
                  icon: Icons.outdoor_grill_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Đã ghi nhận công thức vào ca nấu! Nguyên liệu đã được trừ khỏi kho lạnh.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
