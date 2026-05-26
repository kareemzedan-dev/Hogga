import 'package:dio/dio.dart';
import 'package:hogga/features/user/home/data/models/banners_model.dart';
import 'package:hogga/features/user/home/data/models/home_model.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/api_client.dart';
import '../models/categories_model.dart';
import '../models/lawyer_service_model.dart';
abstract class HomeRemoteDataSource {
  Future<List<Category>> getCategories();
  Future<BannerResponseModel> getBanners();
  Future<HomeModel> getHomeData();
  Future<List<SubCategory>> getSubCategories(int categoryId);
  Future<List<SubCategory>> getChildCategories(int subCategoryId);
  Future<LawyerServiceResponse> getServices(int childCategoryId, {int page = 1});
  Future<ServiceDetailsModel> getServiceDetails(int serviceId);
  Future<ProviderProfileModel> getProviderDetails(int providerId);
  Future<List<ProviderProfileModel>> getProviders({Map<String, dynamic>? filters});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await apiClient.get(AppEndPoints.getCategoriesEndPoint);
      
      final List categoriesJson = response.data['categories'] ?? response.data['data'] ?? [];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load categories');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<BannerResponseModel> getBanners() async {
    try {
      final response = await apiClient.get(AppEndPoints.getBanners);

      return BannerResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load banners');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<HomeModel> getHomeData() async {
    try {
      final response = await apiClient.get(AppEndPoints.getHomeEndPoint);
      return HomeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load home data');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<SubCategory>> getSubCategories(int categoryId) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.getSubCategoriesEndPoint,
        queryParameters: {'category_id': categoryId},
      );
      final List data = response.data['data'] ?? [];
      return data.map((e) => SubCategory.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load sub categories');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<SubCategory>> getChildCategories(int subCategoryId) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.getChildCategoriesEndPoint,
        queryParameters: {'categories_sub_id': subCategoryId},
      );
      final List data = response.data['data'] ?? [];
      return data.map((e) => SubCategory.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load child categories');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<LawyerServiceResponse> getServices(int childCategoryId, {int page = 1}) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.getServicesEndPoint,
        queryParameters: {
          'child_category_id': childCategoryId,
          'page': page,
        },
      );
      return LawyerServiceResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load services');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ServiceDetailsModel> getServiceDetails(int serviceId) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.getServiceDetailsEndPoint(serviceId),
      );
      return ServiceDetailsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load service details');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ProviderProfileModel> getProviderDetails(int providerId) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.getProviderDetailsEndPoint(providerId),
      );
      return ProviderProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load provider details');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ProviderProfileModel>> getProviders({Map<String, dynamic>? filters}) async {
    try {
      final response = await apiClient.get(
        AppEndPoints.getProvidersEndPoint,
        queryParameters: filters,
      );
      final responseData = response.data['data'];
      final List data = responseData is Map<String, dynamic>
          ? (responseData['data'] as List? ?? [])
          : (response.data['data'] as List? ?? []);
      return data.map((e) => ProviderProfileModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to load providers');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
