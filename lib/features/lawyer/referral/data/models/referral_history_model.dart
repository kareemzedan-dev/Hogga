import '../../domain/entities/referral_history_item.dart';

class ReferredUserModel extends ReferredUser {
  const ReferredUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.createdAt,
  });

  factory ReferredUserModel.fromJson(Map<String, dynamic> json) {
    return ReferredUserModel(
      id: (json['id'] is num)
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class ReferralHistoryItemModel extends ReferralHistoryItem {
  const ReferralHistoryItemModel({
    required super.id,
    required super.referredUser,
    required super.codeUsed,
    required super.referredAt,
    required super.isRewarded,
    required super.rewardAmount,
    required super.currency,
  });

  factory ReferralHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final rawRewarded = json['is_rewarded'];
    final isRewarded = rawRewarded == true || rawRewarded == 1 || rawRewarded == '1' || rawRewarded == 'true';
    final rawAmount = json['reward_amount'];
    final rewardAmount = (rawAmount is num)
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;

    return ReferralHistoryItemModel(
      id: (json['id'] is num)
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      referredUser: ReferredUserModel.fromJson(json['referred_user'] is Map<String, dynamic>
          ? json['referred_user'] as Map<String, dynamic>
          : (json['referred_user'] is Map ? Map<String, dynamic>.from(json['referred_user']) : {})),
      codeUsed: json['code_used']?.toString() ?? '',
      referredAt: json['referred_at']?.toString() ?? '',
      isRewarded: isRewarded,
      rewardAmount: rewardAmount,
      currency: json['currency']?.toString() ?? 'OMR',
    );
  }
}

class ReferralHistoryPageModel extends ReferralHistoryPage {
  const ReferralHistoryPageModel({
    required super.currentPage,
    required super.lastPage,
    required super.total,
    required super.items,
  });

  factory ReferralHistoryPageModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ReferralHistoryItemModel.fromJson)
        .toList();

    return ReferralHistoryPageModel(
      currentPage: (json['current_page'] is num)
          ? (json['current_page'] as num).toInt()
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: (json['last_page'] is num)
          ? (json['last_page'] as num).toInt()
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      total: (json['total'] is num)
          ? (json['total'] as num).toInt()
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      items: list,
    );
  }
}
