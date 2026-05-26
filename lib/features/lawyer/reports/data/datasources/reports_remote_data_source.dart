import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';

abstract class ReportsRemoteDataSource {
  Future<LawyerReportModel> getReports(String period);
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiClient apiClient;

  ReportsRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<LawyerReportModel> getReports(String period) async {
    final response = await apiClient.get(AppEndPoints.lawyerReportsEndPoint, queryParameters: {'period': period});
    return LawyerReportModel.fromJson(response.data);
  }
}
