import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:dio/dio.dart';
import 'package:hogga/features/lawyer/services/data/models/lawyer_service_model.dart';
import 'package:hogga/features/lawyer/services/data/models/lawyer_service_details_model.dart';
import 'package:hogga/features/lawyer/services/data/models/lawyer_category_item_model.dart';


abstract class ServicesRemoteDataSource {
  Future<List<LawyerServiceModel>> getServices();
  Future<LawyerServiceDetailsModel> getServiceDetails(int id);
  Future<String> addService(Map<String, dynamic> data);
  Future<String> updateService(int id, Map<String, dynamic> data);
  Future<String> deleteService(int id);
  Future<String> changeServiceStatus(int id);
  Future<List<LawyerCategoryItemModel>> getCategoryItems();
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final ApiClient apiClient;

  ServicesRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<List<LawyerServiceModel>> getServices() async {
    final response = await apiClient.get(AppEndPoints.lawyerServicesEndPoint);
    return (response.data['data'] as List)
        .map((e) => LawyerServiceModel.fromJson(e))
        .toList();
  }

  @override
  Future<LawyerServiceDetailsModel> getServiceDetails(int id) async {
    final response = await apiClient.get(AppEndPoints.getLawyerServiceDetailsEndPoint(id));
    return LawyerServiceDetailsModel.fromJson(response.data['data']);
  }

  @override
  Future<String> addService(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(AppEndPoints.lawyerAddServiceEndPoint, data: data);
      return response.data['message'] ?? 'Success';
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final message = e.response?.data['message'] ?? 'حدث خطأ في البيانات المدخلة';
        throw ServerFailure(message);
      }
      rethrow;
    }
  }
  
  @override
  Future<String> updateService(int id, Map<String, dynamic> data) async {
    final response = await apiClient.post(AppEndPoints.getLawyerUpdateServiceEndPoint(id), data: data);
    return response.data['message'] ?? 'Success';
  }
  
  @override
  Future<String> deleteService(int id) async {
    final response = await apiClient.delete(AppEndPoints.getLawyerDeleteServiceEndPoint(id));
    return response.data['message'] ?? 'Deleted successfully';
  }
  
  @override
  Future<String> changeServiceStatus(int id) async {
    try {
      final response = await apiClient.post(AppEndPoints.getLawyerChangeServiceStatusEndPoint(id));
      return response.data['message'] ?? 'Status updated';
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'حدث خطأ أثناء تغيير حالة الخدمة';
      throw ServerFailure(message);
    }
  }

  @override
  Future<List<LawyerCategoryItemModel>> getCategoryItems() async {
    final response = await apiClient.get(AppEndPoints.lawyerCategoryItemsEndPoint);
    return (response.data['data'] as List)
        .map((e) => LawyerCategoryItemModel.fromJson(e))
        .toList();
  }
}
