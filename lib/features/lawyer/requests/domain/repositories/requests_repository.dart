import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_model.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_details_model.dart';

abstract class RequestsRepository {
  Future<Either<Failure, List<LawyerCaseRequestModel>>> getCaseRequests();
  Future<Either<Failure, LawyerCaseRequestDetailsModel>> getCaseRequestDetails(int requestId);
  Future<Either<Failure, String>> acceptRequest(int requestId);
  Future<Either<Failure, String>> rejectRequest(int requestId);
}
