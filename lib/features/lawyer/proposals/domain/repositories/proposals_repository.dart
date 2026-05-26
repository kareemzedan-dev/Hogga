import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/available_service_details.dart';

abstract class ProposalsRepository {
  Future<Either<Failure, List<LawyerAvailableService>>> getAvailableServices();
  Future<Either<Failure, AvailableServiceDetails>> getAvailableServiceDetails(int id);
  Future<Either<Failure, List<LawyerProposal>>> getProposals();
  Future<Either<Failure, bool>> submitProposal({
    required int serviceId,
    required double price,
    required String description,
  });
  Future<Either<Failure, bool>> updateProposal({
    required int proposalId,
    required double price,
    required String description,
  });
  Future<Either<Failure, bool>> deleteProposal(int proposalId);
}
