class ReferredUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String createdAt;

  const ReferredUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });
}

class ReferralHistoryItem {
  final int id;
  final ReferredUser referredUser;
  final String codeUsed;
  final String referredAt;
  final bool isRewarded;
  final double rewardAmount;
  final String currency;

  const ReferralHistoryItem({
    required this.id,
    required this.referredUser,
    required this.codeUsed,
    required this.referredAt,
    required this.isRewarded,
    required this.rewardAmount,
    required this.currency,
  });
}

class ReferralHistoryPage {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<ReferralHistoryItem> items;

  const ReferralHistoryPage({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.items,
  });
}
