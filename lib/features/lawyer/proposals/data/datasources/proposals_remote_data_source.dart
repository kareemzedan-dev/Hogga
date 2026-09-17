import '../../../../../../core/errors/failures.dart';
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
  Future<String> submitProposal({
    required int serviceId,
    required double offerPrice,
    required String description,
  });
  Future<String> updateProposal({
    required int proposalId,
    required double offerPrice,
    required String description,
  });
  Future<String> deleteProposal(int proposalId);
}

class ProposalsRemoteDataSourceImpl implements ProposalsRemoteDataSource {
  final ApiClient apiClient;

  ProposalsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LawyerAvailableService>> getAvailableServices() async {
    final response = await apiClient.get(
      AppEndPoints.lawyerAvailableServicesEndPoint,
    );
    return (response.data['data'] as List)
        .map((e) => LawyerAvailableServiceModel.fromJson(e))
        .toList();
  }

  @override
  Future<AvailableServiceDetails> getAvailableServiceDetails(int id) async {
    final response = await apiClient.get(
      AppEndPoints.getLawyerProposalServiceDetailsEndPoint(id),
    );
    return AvailableServiceDetailsModel.fromJson(response.data['data']);
  }

  @override
  Future<List<LawyerProposal>> getProposals() async {
    final response = await apiClient.get(
      AppEndPoints.lawyerMyProposalsEndPoint,
    );
    return (response.data['data'] as List)
        .map((e) => LawyerProposalModel.fromJson(e))
        .toList();
  }

  @override
  Future<String> submitProposal({
    required int serviceId,
    required double offerPrice,
    required String description,
  }) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerSubmitProposalEndPoint,
      data: {
        'legal_case_id': serviceId,
        'price': offerPrice,
        'offer_price': offerPrice,
        'description': description,
      },
    );
    final isSuccess =
        response.data['status'] == true || response.data['success'] == true;
    if (!isSuccess) {
      throw ServerFailure(
        response.data['message']?.toString() ?? 'فشل تقديم العرض',
      );
    }
    return response.data['message']?.toString() ?? 'تم تقديم العرض بنجاح';
  }

  @override
  Future<String> updateProposal({
    required int proposalId,
    required double offerPrice,
    required String description,
  }) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerUpdateProposalEndPoint(proposalId),
      data: {
        'price': offerPrice,
        'offer_price': offerPrice,
        'description': description,
      },
    );
    final isSuccess =
        response.data['status'] == true || response.data['success'] == true;
    if (!isSuccess) {
      throw ServerFailure(
        response.data['message']?.toString() ?? 'فشل تعديل العرض',
      );
    }
    return response.data['message']?.toString() ?? 'تم تعديل العرض بنجاح';
  }

  @override
  Future<String> deleteProposal(int proposalId) async {
    final response = await apiClient.delete(
      AppEndPoints.lawyerDeleteProposalEndPoint(proposalId),
    );
    final isSuccess =
        response.data['status'] == true || response.data['success'] == true;
    if (isSuccess) {
      return response.data['message']?.toString() ?? 'تم حذف العرض بنجاح.';
    } else {
      throw ServerFailure(
        response.data['message']?.toString() ?? 'فشل حذف العرض',
      );
    }
  }
}
