import 'package:hogga/features/lawyer/requests/domain/entities/lawyer_case_request.dart';

class LawyerCaseRequestModel extends LawyerCaseRequest {
  const LawyerCaseRequestModel({
    required super.id,
    required super.title,
    required super.statusKey,
    required super.statusText,
    required super.date,
    required super.time,
  });

  factory LawyerCaseRequestModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseRequestModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      statusKey: json['status_key'] ?? '',
      statusText: json['status_text'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
