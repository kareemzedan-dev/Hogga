import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case.dart';

class LawyerCaseModel extends LawyerCase {
  const LawyerCaseModel({
    required super.id,
    required super.caseNumber,
    required super.realCaseNumber,
    required super.title,
    required super.statusKey,
    required super.statusText,
    required super.date,
    super.court,
    super.descriptionSnippet,
    required super.clientName,
  });

  factory LawyerCaseModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseModel(
      id: json['id'] ?? 0,
      caseNumber: json['case_number'] ?? 0,
      realCaseNumber: json['real_case_number'] ?? '',
      title: json['title'] ?? '',
      statusKey: json['status_key'] ?? '',
      statusText: json['status_text'] ?? '',
      date: json['date'] ?? '',
      court: json['court'],
      descriptionSnippet: json['description_snippet'],
      clientName: json['client_name'] ?? '',
    );
  }
}
