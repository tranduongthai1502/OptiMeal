import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/food_listing.dart';
import '../repositories/listings_repository.dart';

class CreateListingUseCase {
  final ListingsRepository repository;

  CreateListingUseCase(this.repository);

  Future<Either<Failure, FoodListing>> call(FoodListing listing) async {
    if (listing.title.trim().isEmpty) {
      return const Left(
        ServerFailure('Tiêu đề món ăn không được để trống.', 'INVALID_TITLE'),
      );
    }

    if (listing.quantity <= 0) {
      return const Left(
        ServerFailure('Số lượng phải lớn hơn 0.', 'INVALID_QUANTITY'),
      );
    }

    if (listing.condition == FoodCondition.paid &&
        (listing.price == null || listing.price! <= 0)) {
      return const Left(
        ServerFailure(
          'Vui lòng nhập giá bán hợp lệ cho thực phẩm có phí.',
          'INVALID_PRICE',
        ),
      );
    }

    if (listing.pickupWindowEnd.isBefore(listing.pickupWindowStart)) {
      return const Left(
        ServerFailure(
          'Thời gian kết thúc lấy hàng phải sau thời gian bắt đầu.',
          'INVALID_PICKUP_WINDOW',
        ),
      );
    }

    if (listing.expiresAt.isBefore(DateTime.now())) {
      return const Left(
        ServerFailure(
          'Hạn sử dụng phải ở thời điểm tương lai.',
          'INVALID_EXPIRY',
        ),
      );
    }

    return repository.createListing(listing);
  }
}
