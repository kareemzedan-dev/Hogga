import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/proposals/data/models/lawyer_proposal_model.dart';
import 'package:hogga/features/lawyer/proposals/data/models/available_service_details_model.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/available_service_details.dart';
import 'package:hogga/features/lawyer/services/data/models/lawyer_available_service_model.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';

abstract class ProposalsRemoteDataSource {
  Future<List<LawyerAvailableService>> getAvailableServices();
  Future<AvailableServiceDetails> getAvailableServiceDetails(int id);
  Future<List<LawyerProposal>> getProposals();
  Future<bool> submitProposal({
    required int serviceId,
    required double price,
    required String description,
  });
  Future<bool> updateProposal({
    required int proposalId,
    required double price,
    required String description,
  });
  Future<bool> deleteProposal(int proposalId);
}

class ProposalsRemoteDataSourceImpl implements ProposalsRemoteDataSource {
  final ApiClient apiClient;

  ProposalsRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<List<LawyerAvailableService>> getAvailableServices() async {
    final response = await apiClient.get(AppEndPoints.lawyerAvailableServicesEndPoint);
    return (response.data['data'] as List)
        .map((e) => LawyerAvailableServiceModel.fromJson(e))
        .toList();
  }

  @override
  Future<AvailableServiceDetails> getAvailableServiceDetails(int id) async {
    final response = await apiClient.get(AppEndPoints.getLawyerProposalServiceDetailsEndPoint(id));
    return AvailableServiceDetailsModel.fromJson(response.data['data']);
  }

  @override
  Future<List<LawyerProposal>> getProposals() async {
    final response = await apiClient.get(AppEndPoints.lawyerMyProposalsEndPoint);
    return (response.data['data'] as List)
        .map((e) => LawyerProposalModel.fromJson(e))
        .toList();
  }

  @override
  Future<bool> submitProposal({
    required int serviceId,
    required double price,
    required String description,
  }) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerSubmitProposalEndPoint,
      data: {
        'legal_case_id': serviceId,
        'price': price.toString(),
        'description': description,
      },
    );
    return response.data['status'] == true;
  }

  @override
  Future<bool> updateProposal({
    required int proposalId,
    required double price,
    required String description,
  }) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerUpdateProposalEndPoint,
      data: {
        'proposal_id': proposalId,
        'price': price.toString(),
        'description': description,
      },
    );
    return response.data['status'] == true;
  }

  @override
  Future<bool> deleteProposal(int proposalId) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerDeleteProposalEndPoint,
      data: {'proposal_id': proposalId},
    );
    return response.data['status'] == true;
  }
}
