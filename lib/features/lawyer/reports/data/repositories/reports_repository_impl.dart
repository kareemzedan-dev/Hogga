import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/reports/domain/repositories/reports_repository.dart';
import 'package:hogga/features/lawyer/reports/data/datasources/reports_remote_data_source.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LawyerReportModel>> getReports(String period) async {
    try {
      final remoteData = await remoteDataSource.getReports(period);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
