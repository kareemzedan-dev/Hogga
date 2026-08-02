import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/library/data/models/lawyer_library_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LawyerLibraryItemModel>> searchLibrary(String query);
  Future<List<LawyerLibraryArticleModel>> getCategoryArticles(int categoryId);
  Future<LawyerLibraryArticleDetailsModel> getArticleDetails(int articleId);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final ApiClient apiClient;

  LibraryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LawyerLibraryItemModel>> searchLibrary(String query) async {
    final response = await apiClient.get(
      AppEndPoints.lawyerLibrarySearchEndPoint,
      queryParameters: {'q': query},
    );
    return (response.data['data'] as List)
        .map((e) => LawyerLibraryItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<LawyerLibraryArticleModel>> getCategoryArticles(
    int categoryId,
  ) async {
    final response = await apiClient.get(
      "${AppEndPoints.lawyerLibraryCategoryEndPoint}/$categoryId",
    );
    return (response.data['data'] as List)
        .map((e) => LawyerLibraryArticleModel.fromJson(e))
        .toList();
  }

  @override
  Future<LawyerLibraryArticleDetailsModel> getArticleDetails(
    int articleId,
  ) async {
    final response = await apiClient.get(
      "${AppEndPoints.lawyerLibraryDetailsEndPoint}/$articleId",
    );
    return LawyerLibraryArticleDetailsModel.fromJson(response.data['data']);
  }
}
