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
    super.serviceType,
    super.serviceTypeText,
    super.chatRoomId,
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
      serviceType: json['service_type']?.toString() ?? 'article',
      serviceTypeText: json['service_type_text']?.toString() ?? '',
      chatRoomId: json['chat_room_id'] as int?,
    );
  }
}
