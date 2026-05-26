import '../../../../../core/network/api_client.dart';
import '../models/package_model.dart';
import '../models/subscription_model.dart';
import '../models/subscription_progress_model.dart';
import '../../../../../core/constants/end_points.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<PackageModel>> getPackages();
  Future<SubscriptionModel?> getCurrentSubscription();
  Future<SubscriptionProgress> getSubscriptionProgress();
  Future<String> subscribe(int packageId);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PackageModel>> getPackages() async {
    final response = await apiClient.get(AppEndPoints.subscriptionPackagesEndPoint);
    
    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => PackageModel.fromJson(e))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load packages');
    }
  }

  @override
  Future<SubscriptionModel?> getCurrentSubscription() async {
    try {
      final response = await apiClient.get(AppEndPoints.currentSubscriptionEndPoint);
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return SubscriptionModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      // In case the lawyer doesn't have a subscription, the API might return 404 or a specific error.
      // We return null to indicate "No Subscription".
      return null;
    }
  }

  @override
  Future<SubscriptionProgress> getSubscriptionProgress() async {
    final response = await apiClient.get(AppEndPoints.subscriptionProgressEndPoint);
    if (response.data['success'] == true) {
      return SubscriptionProgress.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load progress');
    }
  }

  Future<String> subscribe(int packageId) async {
    final response = await apiClient.post(
      AppEndPoints.subscribeEndPoint,
      data: {'package_id': packageId},
    );
    
    if (response.data['success'] == true) {
      return response.data['message'] ?? 'Subscription successful';
    } else {
      throw Exception(response.data['message'] ?? 'Subscription failed');
    }
  }
}
