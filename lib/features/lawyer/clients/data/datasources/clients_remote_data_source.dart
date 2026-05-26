import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/clients/data/models/lawyer_client_model.dart';

abstract class ClientsRemoteDataSource {
  Future<LawyerClientsResponseModel> getClients({int page = 1});
}

class ClientsRemoteDataSourceImpl implements ClientsRemoteDataSource {
  final ApiClient apiClient;

  ClientsRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<LawyerClientsResponseModel> getClients({int page = 1}) async {
    final response = await apiClient.get(
      AppEndPoints.lawyerClientsEndPoint,
      queryParameters: {'page': page},
    );
    return LawyerClientsResponseModel.fromJson(response.data['data']);
  }
}
