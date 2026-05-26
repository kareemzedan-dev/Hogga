import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_model.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_details_model.dart';

abstract class CasesRepository {
  Future<Either<Failure, List<LawyerCaseModel>>> getCases({String? type});
  Future<Either<Failure, LawyerCaseDetailsModel>> getCaseDetails(int caseId);
  Future<Either<Failure, bool>> addCaseSession({
    required int caseId,
    required String title,
    required String date,
    required String details,
  });
  Future<Either<Failure, bool>> uploadCaseDocument({
    required int caseId,
    required String title,
    required File document,
  });
}
