import '../../domain/entities/referral_code_data.dart';

class ReferralCodeModel extends ReferralCodeData {
  const ReferralCodeModel({
    required super.referralCode,
    required super.totalReferredUsers,
  });

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) {
    return ReferralCodeModel(
      referralCode: json['referral_code']?.toString() ?? '',
      totalReferredUsers: (json['total_referred_users'] is num)
          ? (json['total_referred_users'] as num).toInt()
          : int.tryParse(json['total_referred_users']?.toString() ?? '0') ?? 0,
    );
  }
}
