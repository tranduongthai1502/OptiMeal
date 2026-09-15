import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUserRoleUseCase {
  final AuthRepository repository;

  UpdateUserRoleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String userId,
    required UserRole role,
    String? displayName,
  }) {
    return repository.updateUserRole(
      userId: userId,
      role: role,
      displayName: displayName,
    );
  }
}
