import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';

abstract class ReportsRepository {
  Future<Either<Failure, LawyerReportModel>> getReports(String period);
}
