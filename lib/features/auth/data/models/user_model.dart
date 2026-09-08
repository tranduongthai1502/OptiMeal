import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    super.displayName,
    super.avatarUrl,
    super.role,
    super.reputationScore = 5.0,
    super.totalDonations = 0,
    super.totalPickups = 0,
    super.noShowCount = 0,
    super.isRestricted = false,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      displayName: map['displayName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      role: map['role'] != null
          ? UserRole.values.firstWhere(
              (r) => r.name == map['role'],
              orElse: () => UserRole.individual,
            )
          : null,
      reputationScore: (map['reputationScore'] as num?)?.toDouble() ?? 5.0,
      totalDonations: (map['totalDonations'] as num?)?.toInt() ?? 0,
      totalPickups: (map['totalPickups'] as num?)?.toInt() ?? 0,
      noShowCount: (map['noShowCount'] as num?)?.toInt() ?? 0,
      isRestricted: map['isRestricted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role?.name,
      'reputationScore': reputationScore,
      'totalDonations': totalDonations,
      'totalPickups': totalPickups,
      'noShowCount': noShowCount,
      'isRestricted': isRestricted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    double? reputationScore,
    int? totalDonations,
    int? totalPickups,
    int? noShowCount,
    bool? isRestricted,
  }) {
    return UserModel(
      id: id,
      phoneNumber: phoneNumber,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      reputationScore: reputationScore ?? this.reputationScore,
      totalDonations: totalDonations ?? this.totalDonations,
      totalPickups: totalPickups ?? this.totalPickups,
      noShowCount: noShowCount ?? this.noShowCount,
      isRestricted: isRestricted ?? this.isRestricted,
      createdAt: createdAt,
    );
  }
}
