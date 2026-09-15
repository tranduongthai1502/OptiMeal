import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_copilot_repository.dart';

class RecipeCopilotRepositoryImpl implements RecipeCopilotRepository {
  final List<ColdStorageIngredient> _mockStorage = [
    ColdStorageIngredient(
      id: 'cs-01',
      name: 'Đậu phụ tươi',
      quantityKg: 20.0,
      expiryDate: DateTime.now().add(
        const Duration(hours: 14),
      ), // Hết hạn trong 14 tiếng!
      category: 'Tươi sống',
    ),
    ColdStorageIngredient(
      id: 'cs-02',
      name: 'Cải thìa Đà Lạt',
      quantityKg: 25.0,
      expiryDate: DateTime.now().add(
        const Duration(hours: 18),
      ), // Hết hạn trong 18 tiếng!
      category: 'Rau củ',
    ),
    ColdStorageIngredient(
      id: 'cs-03',
      name: 'Cà chua chín mọng',
      quantityKg: 15.0,
      expiryDate: DateTime.now().add(
        const Duration(hours: 22),
      ), // Hết hạn trong 22 tiếng!
      category: 'Rau củ',
    ),
    ColdStorageIngredient(
      id: 'cs-04',
      name: 'Gạo ST25',
      quantityKg: 80.0,
      expiryDate: DateTime.now().add(const Duration(days: 45)),
      category: 'Đồ khô',
    ),
    ColdStorageIngredient(
      id: 'cs-05',
      name: 'Thịt heo xay đông lạnh',
      quantityKg: 12.0,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      category: 'Tươi sống',
    ),
    ColdStorageIngredient(
      id: 'cs-06',
      name: 'Bí đỏ hồ lô',
      quantityKg: 30.0,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      category: 'Rau củ',
    ),
  ];

  @override
  Future<Either<Failure, List<ColdStorageIngredient>>>
      getColdStorageIngredients() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Right(_mockStorage);
  }

  @override
  Future<Either<Failure, List<BatchRecipe>>> generateBatchRecipes({
    required int targetPortions,
    List<String>? focusIngredients,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Ratio multiplier based on portions (base is 100 portions = 1.0)
    final ratio = targetPortions / 100.0;

    final recipes = [
      BatchRecipe(
        id: 'recipe-001',
        title: 'Đậu Phụ Sốt Cà Chua & Canh Cải Thìa Nấu Tôm Khô',
        description:
            'Thực đơn ưu tiên số 1: Tận dụng trọn vẹn 3 nguyên liệu sắp hết hạn (Đậu phụ, Cải thìa, Cà chua). Món sốt đậm đà đưa cơm, canh thanh mát nhiều vitamin.',
        targetPortions: targetPortions,
        prepTimeMinutes: 30,
        cookTimeMinutes: 45,
        usesExpiringIngredients: true,
        photoUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
        safetyNotes: [
          'Đậu phụ tươi cận date: Cần chần nhanh qua nước sôi có pha 1% muối loãng trong 2 phút để khử chua và giữ miếng đậu chắc khi nấu chảo lớn.',
          'Cà chua: Rửa sạch ngâm nước muối 10 phút trước khi xắt múi cau hoặc xay nhuyễn nấu sốt.',
          'Kiểm tra nhiệt độ tâm món xào/sốt đạt ít nhất 75°C trước khi múc chia suất.',
        ],
        ingredients: [
          BatchIngredient(
            name: 'Đậu phụ tươi',
            amount: 18.0 * ratio,
            unit: 'kg',
            isShortExpiry: true,
          ),
          BatchIngredient(
            name: 'Cà chua chín',
            amount: 12.0 * ratio,
            unit: 'kg',
            isShortExpiry: true,
          ),
          BatchIngredient(
            name: 'Cải thìa tươi',
            amount: 20.0 * ratio,
            unit: 'kg',
            isShortExpiry: true,
          ),
          BatchIngredient(
            name: 'Hành tím & tỏi băm',
            amount: 1.2 * ratio,
            unit: 'kg',
            isFromColdStorage: false,
          ),
          BatchIngredient(
            name: 'Gia vị tổng hợp (Hạt nêm chay, nước tương, dầu hào)',
            amount: 2.0 * ratio,
            unit: 'lít/kg',
            isFromColdStorage: false,
          ),
        ],
        cookingSteps: [
          'Sơ chế: Cắt đậu phụ thành khối vuông 3x3 cm, chần nước sôi 2 phút vớt ráo. Cải thìa tách bẹ rửa sạch, xắt khúc 4cm.',
          'Nấu sốt (Chảo lớn 100L): Phi thơm hành tỏi với 500ml dầu ăn, cho toàn bộ cà chua vào xào nhuyễn thành sốt sánh mịn.',
          'Om đậu: Nêm gia vị vừa ăn, cho đậu phụ vào đảo nhẹ tay từ đáy chảo, hạ lửa nhỏ om trong 20 phút cho đậu ngấm đượm sốt.',
          'Nấu canh: Đun sôi nồi nước dùng 40L, nêm gia vị, cho cải thìa vào nấu vừa chín tới (khoảng 3 phút) để giữ màu xanh mướt.',
          'Hoàn tất: Giữ nóng trong khay giữ nhiệt và chia đều vào các phần cơm từ thiện.',
        ],
      ),
      BatchRecipe(
        id: 'recipe-002',
        title: 'Canh Bí Đỏ Thịt Băm & Cải Thìa Xào Tỏi',
        description:
            'Thực đơn giàu năng lượng và tinh bột tốt cho người lao động. Phối hợp cải thìa giải cứu cùng bí đỏ kho lạnh ngọt bùi.',
        targetPortions: targetPortions,
        prepTimeMinutes: 25,
        cookTimeMinutes: 40,
        usesExpiringIngredients: true,
        photoUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
        safetyNotes: [
          'Thịt heo xay trữ đông cần rã đông hoàn toàn trong ngăn mát tủ lạnh trước khi xào, không ngâm trực tiếp nước ấm.',
          'Bí đỏ gọt vỏ bỏ ruột rửa sạch, cắt miếng vừa ăn 2.5cm tránh bị nát khi hầm chảo lớn.',
        ],
        ingredients: [
          BatchIngredient(
            name: 'Bí đỏ hồ lô',
            amount: 25.0 * ratio,
            unit: 'kg',
            isFromColdStorage: true,
          ),
          BatchIngredient(
            name: 'Cải thìa',
            amount: 15.0 * ratio,
            unit: 'kg',
            isShortExpiry: true,
          ),
          BatchIngredient(
            name: 'Thịt heo xay',
            amount: 8.0 * ratio,
            unit: 'kg',
            isFromColdStorage: true,
          ),
          BatchIngredient(
            name: 'Hành lá, ngò rí',
            amount: 1.0 * ratio,
            unit: 'kg',
            isFromColdStorage: false,
          ),
        ],
        cookingSteps: [
          'Xào thịt băm với hành phi cho săn thơm, nêm hạt nêm và tiêu.',
          'Nấu canh bí đỏ: Cho bí đỏ vào nồi nước dùng lớn, nấu chín mềm khoảng 15 phút, thả thịt băm vào khuấy đều.',
          'Xào cải thìa: Dùng chảo lớn phi tỏi thơm lừng, xào cải thìa trên lửa lớn trong 5 phút.',
          'Rắc hành ngò lên canh và đậy nắp giữ nóng.',
        ],
      ),
      BatchRecipe(
        id: 'recipe-003',
        title: 'Cơm Chiên Dương Châu Rau Củ Hỗn Hợp (Chay/Mặn)',
        description:
            'Món ăn một tô tiện lợi, chế biến nhanh cho số lượng đông 100-200 người. Dùng gạo ST25 kết hợp rau củ thái hạt lựu.',
        targetPortions: targetPortions,
        prepTimeMinutes: 35,
        cookTimeMinutes: 30,
        usesExpiringIngredients: false,
        photoUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600&auto=format&fit=crop&q=80',
        safetyNotes: [
          'Cơm nấu chín phải được xới tơi và để nguội ráo trước khi chiên để hạt cơm săn chắc không bị nhão.',
        ],
        ingredients: [
          BatchIngredient(
            name: 'Gạo ST25',
            amount: 20.0 * ratio,
            unit: 'kg',
            isFromColdStorage: true,
          ),
          BatchIngredient(
            name: 'Cà rốt & Đậu que thái hạt lựu',
            amount: 8.0 * ratio,
            unit: 'kg',
            isFromColdStorage: true,
          ),
          BatchIngredient(
            name: 'Trứng gà / Chả lụa',
            amount: 5.0 * ratio,
            unit: 'kg',
            isFromColdStorage: false,
          ),
        ],
        cookingSteps: [
          'Nấu cơm chín, đổ ra mâm xới tơi và hong quạt cho ráo hạt.',
          'Xào chín sơ các loại rau củ hạt lựu và nhân mặn.',
          'Chiên cơm trên chảo đại đảo đều tay với gia vị và dầu màu điều.',
          'Trộn đều toàn bộ rau củ vào cơm, rắc hành hoa đảo đều lần cuối.',
        ],
      ),
    ];

    return Right(recipes);
  }

  @override
  Future<Either<Failure, BatchRecipe>> getRecipeById(String id) async {
    final list = await generateBatchRecipes(targetPortions: 100);
    return list.map(
      (recipes) =>
          recipes.firstWhere((r) => r.id == id, orElse: () => recipes.first),
    );
  }
}
