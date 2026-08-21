import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/referral_code_data.dart';
import '../../domain/entities/referral_history_item.dart';
import '../../domain/repositories/referral_repository.dart';
import '../datasources/referral_remote_data_source.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  final ReferralRemoteDataSource remoteDataSource;

  ReferralRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReferralCodeData>> getMyReferralCode() async {
    try {
      final result = await remoteDataSource.getMyReferralCode();
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReferralHistoryPage>> getReferralHistory({int page = 1}) async {
    try {
      final result = await remoteDataSource.getReferralHistory(page: page);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
