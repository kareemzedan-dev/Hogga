import 'package:hogga/features/lawyer/cases/domain/entities/lawyer_case_details.dart';

class LawyerCaseDetailsModel extends LawyerCaseDetails {
  const LawyerCaseDetailsModel({
    required super.id,
    required super.title,
    required super.caseNumber,
    required super.statusKey,
    required super.statusText,
    super.serviceType,
    super.serviceTypeText,
    super.chatRoomId,
    required super.client,
    required super.sessions,
    required super.documents,
  });

  factory LawyerCaseDetailsModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseDetailsModel(
      id: json['id'] ?? 0,
      title: json['case_title'] ?? '',
      caseNumber: json['case_number'] ?? '',
      statusKey: json['status_key'] ?? '',
      statusText: json['status_text'] ?? '',
      serviceType: json['service_type']?.toString() ?? 'article',
      serviceTypeText: json['service_type_text']?.toString() ?? '',
      chatRoomId: json['chat_room_id'] as int?,
      client: LawyerCaseClientModel.fromJson(json['client'] ?? {}),
      sessions: LawyerCaseSessionsModel.fromJson(json['sessions'] ?? {}),
      documents: (json['documents'] as List? ?? [])
          .map((e) => LawyerCaseDocumentModel.fromJson(e))
          .toList(),
    );
  }
}

class LawyerCaseClientModel extends LawyerCaseClient {
  const LawyerCaseClientModel({
    required super.name,
    super.phone,
    super.photo,
  });

  factory LawyerCaseClientModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseClientModel(
      name: json['name'] ?? '',
      phone: json['phone'],
      photo: json['photo'],
    );
  }
}

class LawyerCaseSessionsModel extends LawyerCaseSessions {
  const LawyerCaseSessionsModel({
    required super.upcoming,
    required super.previous,
  });

  factory LawyerCaseSessionsModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseSessionsModel(
      upcoming: (json['upcoming'] as List? ?? [])
          .map((e) => LawyerCaseSessionModel.fromJson(e))
          .toList(),
      previous: (json['previous'] as List? ?? [])
          .map((e) => LawyerCaseSessionModel.fromJson(e))
          .toList(),
    );
  }
}

class LawyerCaseSessionModel extends LawyerCaseSession {
  const LawyerCaseSessionModel({
    required super.id,
    required super.title,
    required super.date,
    required super.details,
    required super.isUpcoming,
  });

  factory LawyerCaseSessionModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseSessionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      details: json['details'] ?? '',
      isUpcoming: json['is_upcoming'] ?? false,
    );
  }
}

class LawyerCaseDocumentModel extends LawyerCaseDocument {
  const LawyerCaseDocumentModel({
    required super.id,
    required super.name,
    required super.url,
    required super.type,
    required super.addedBy,
  });

  factory LawyerCaseDocumentModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseDocumentModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      addedBy: json['added_by'] ?? '',
    );
  }
}
