import 'package:hogga/features/lawyer/clients/domain/entities/lawyer_client.dart';

class LawyerClientModel extends LawyerClient {
  const LawyerClientModel({
    required super.id,
    required super.name,
    super.photo,
    super.phone,
    required super.activeCasesCount,
    super.activeCasesText,
  });

  factory LawyerClientModel.fromJson(Map<String, dynamic> json) {
    return LawyerClientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      photo: json['photo'],
      phone: json['phone'],
      activeCasesCount: json['active_cases_count'] ?? 0,
      activeCasesText: json['active_cases_text'],
    );
  }
}

class LawyerClientsResponseModel {
  final int currentPage;
  final int lastPage;
  final List<LawyerClientModel> data;
  final int total;

  LawyerClientsResponseModel({
    required this.currentPage,
    required this.lastPage,
    required this.data,
    required this.total,
  });

  factory LawyerClientsResponseModel.fromJson(Map<String, dynamic> json) {
    return LawyerClientsResponseModel(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((e) => LawyerClientModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}
