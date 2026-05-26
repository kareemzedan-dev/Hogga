import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/documents/data/models/lawyer_document_model.dart';

abstract class DocumentsRemoteDataSource {
  Future<LawyerDocumentsResponseModel> getDocuments({String? folder});
  Future<void> uploadDocument({
    required String name,
    required File file,
    String? folder,
  });
  Future<void> deleteDocument(int documentId);
}

class DocumentsRemoteDataSourceImpl implements DocumentsRemoteDataSource {
  final ApiClient apiClient;

  DocumentsRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<LawyerDocumentsResponseModel> getDocuments({String? folder}) async {
    final response = await apiClient.get(AppEndPoints.lawyerDocumentsEndPoint, queryParameters: folder != null ? {'folder': folder} : null);
    return LawyerDocumentsResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> uploadDocument({
    required String name,
    required File file,
    String? folder,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      if (folder != null) 'folder': folder,
    });
    await apiClient.post(AppEndPoints.lawyerDocumentsEndPoint, data: formData);
  }

  @override
  Future<void> deleteDocument(int documentId) async {
    await apiClient.post(
      "${AppEndPoints.lawyerDocumentsEndPoint}/$documentId",
      data: {'_method': 'DELETE'},
    );
  }
}
