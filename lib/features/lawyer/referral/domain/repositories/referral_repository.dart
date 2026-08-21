import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/referral_code_data.dart';
import '../entities/referral_history_item.dart';

abstract class ReferralRepository {
  Future<Either<Failure, ReferralCodeData>> getMyReferralCode();
  Future<Either<Failure, ReferralHistoryPage>> getReferralHistory({int page = 1});
}
