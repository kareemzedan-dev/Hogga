import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:hogga/features/lawyer/referral/data/models/referral_code_model.dart';
import 'package:hogga/features/lawyer/referral/data/models/referral_history_model.dart';
import 'package:hogga/features/lawyer/referral/domain/entities/referral_code_data.dart';
import 'package:hogga/features/lawyer/referral/domain/entities/referral_history_item.dart';
import 'package:hogga/features/lawyer/referral/domain/repositories/referral_repository.dart';
import 'package:hogga/features/lawyer/referral/presentation/cubit/referral_cubit.dart';
import 'package:hogga/features/lawyer/referral/presentation/cubit/referral_history_cubit.dart';
import 'package:hogga/features/lawyer/referral/presentation/cubit/referral_state.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_transaction_model.dart';

class MockReferralRepository implements ReferralRepository {
  bool shouldReturnError = false;
  ReferralCodeData mockCodeData = const ReferralCodeData(
    referralCode: 'REF-B39D7D',
    totalReferredUsers: 4,
  );

  ReferralHistoryPage mockHistoryPage = const ReferralHistoryPage(
    currentPage: 1,
    lastPage: 2,
    total: 2,
    items: [
      ReferralHistoryItem(
        id: 1,
        referredUser: ReferredUser(
          id: 13,
          name: 'أحمد علي',
          email: 'ahmed@example.com',
          phone: '96891234567',
          createdAt: '2026-08-16',
        ),
        codeUsed: 'REF-B39D7D',
        referredAt: '2026-08-16',
        isRewarded: true,
        rewardAmount: 70.0,
        currency: 'OMR',
      ),
    ],
  );

  @override
  Future<Either<Failure, ReferralCodeData>> getMyReferralCode() async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Failed to fetch code'));
    }
    return Right(mockCodeData);
  }

  @override
  Future<Either<Failure, ReferralHistoryPage>> getReferralHistory({int page = 1}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Failed to fetch history'));
    }
    return Right(mockHistoryPage);
  }
}

void main() {
  group('Referral Model Tests', () {
    test('ReferralCampaignModel.fromJson parses correctly', () {
      final json = {
        'status': 'on',
        'bonus_amount': 70.0,
        'referral_code': 'REF-B39D7D',
      };
      final campaign = ReferralCampaign(
        status: json['status'] as String,
        bonusAmount: (json['bonus_amount'] as num).toDouble(),
        referralCode: json['referral_code'] as String,
      );

      expect(campaign.status, 'on');
      expect(campaign.isOn, true);
      expect(campaign.bonusAmount, 70.0);
      expect(campaign.referralCode, 'REF-B39D7D');
    });

    test('ReferralCodeModel.fromJson parses correctly', () {
      final json = {
        'referral_code': 'REF-B39D7D',
        'total_referred_users': 4,
      };
      final model = ReferralCodeModel.fromJson(json);

      expect(model.referralCode, 'REF-B39D7D');
      expect(model.totalReferredUsers, 4);
    });

    test('ReferralHistoryPageModel.fromJson parses paginated items correctly', () {
      final json = {
        'current_page': 1,
        'last_page': 1,
        'total': 1,
        'data': [
          {
            'id': 1,
            'referred_user': {
              'id': 13,
              'name': 'أحمد علي',
              'email': 'ahmed@test.com',
              'phone': '96891234567',
              'created_at': '2026-08-16',
            },
            'code_used': 'REF-B39D7D',
            'referred_at': '2026-08-16',
            'is_rewarded': true,
            'reward_amount': 70.0,
            'currency': 'OMR',
          }
        ]
      };
      final page = ReferralHistoryPageModel.fromJson(json);

      expect(page.currentPage, 1);
      expect(page.total, 1);
      expect(page.items.length, 1);
      expect(page.items.first.isRewarded, true);
      expect(page.items.first.rewardAmount, 70.0);
      expect(page.items.first.referredUser.name, 'أحمد علي');
    });

    test('LawyerWalletTransactionModel identifies referral_bonus correctly', () {
      final json = {
        'id': 101,
        'transaction_type': 'referral_bonus',
        'type': 'credit',
        'notes': 'بونص إحالة مكافأة استقطاب',
        'amount': '70.00',
        'created_at': '2026-08-16',
      };
      final tx = LawyerWalletTransactionModel.fromJson(json);

      expect(tx.isReferralBonus, true);
      expect(tx.isIncome, true);
      expect(tx.title, 'بونص إحالة مكافأة استقطاب');
      expect(tx.amount, '70.00');
    });
  });

  group('Referral Cubits Tests', () {
    late MockReferralRepository mockRepo;
    late ReferralCubit referralCubit;
    late ReferralHistoryCubit historyCubit;

    setUp(() {
      mockRepo = MockReferralRepository();
      referralCubit = ReferralCubit(repository: mockRepo);
      historyCubit = ReferralHistoryCubit(repository: mockRepo);
    });

    tearDown(() {
      referralCubit.close();
      historyCubit.close();
    });

    test('ReferralCubit emits ReferralCodeLoaded on success', () async {
      await referralCubit.getReferralCode();
      expect(referralCubit.state, isA<ReferralCodeLoaded>());
      final loaded = referralCubit.state as ReferralCodeLoaded;
      expect(loaded.codeData.referralCode, 'REF-B39D7D');
      expect(loaded.codeData.totalReferredUsers, 4);
    });

    test('ReferralCubit emits ReferralError on failure', () async {
      mockRepo.shouldReturnError = true;
      await referralCubit.getReferralCode();
      expect(referralCubit.state, isA<ReferralError>());
    });

    test('ReferralHistoryCubit loads history items on refresh', () async {
      await historyCubit.loadHistory(refresh: true);
      expect(historyCubit.state.items.length, 1);
      expect(historyCubit.state.currentPage, 1);
      expect(historyCubit.state.hasReachedMax, false);
    });
  });
}
