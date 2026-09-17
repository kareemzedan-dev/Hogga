import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/available_service_details.dart';

abstract class ProposalsRepository {
  Future<Either<Failure, List<LawyerAvailableService>>> getAvailableServices();
  Future<Either<Failure, AvailableServiceDetails>> getAvailableServiceDetails(
    int id,
  );
  Future<Either<Failure, List<LawyerProposal>>> getProposals();
  Future<Either<Failure, String>> submitProposal({
    required int serviceId,
    required double offerPrice,
    required String description,
  });
  Future<Either<Failure, String>> updateProposal({
    required int proposalId,
    required double offerPrice,
    required String description,
  });
  Future<Either<Failure, String>> deleteProposal(int proposalId);
}
