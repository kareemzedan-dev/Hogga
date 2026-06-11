import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? type;
  final String? readAt;
  final String? actionType;
  final int? caseId;
  final String? caseNumber;
  final int? businessId;
  final int? chatRoomId;
  final String? channelName;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.type,
    this.readAt,
    this.actionType,
    this.caseId,
    this.caseNumber,
    this.businessId,
    this.chatRoomId,
    this.channelName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final meta = payload['meta'] is Map<String, dynamic>
        ? payload['meta'] as Map<String, dynamic>
        : <String, dynamic>{};

    final createdAtRaw = json['created_at']?.toString();
    final normalizedCreatedAt = createdAtRaw?.replaceFirst(' ', 'T');
    final readAt = json['read_at']?.toString();

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: payload['title']?.toString() ?? json['title']?.toString() ?? '',
      body: payload['body']?.toString() ??
          payload['message']?.toString() ??
          json['body']?.toString() ??
          '',
      createdAt: normalizedCreatedAt != null
          ? DateTime.tryParse(normalizedCreatedAt) ?? DateTime.now()
          : DateTime.now(),
      isRead: readAt != null && readAt.isNotEmpty,
      readAt: readAt,
      type: payload['type']?.toString() ?? json['type']?.toString(),
      actionType: meta['action_type']?.toString(),
      caseId: _toInt(meta['case_id']),
      caseNumber: meta['case_number']?.toString(),
      businessId: _toInt(payload['id']),
      chatRoomId: _toInt(payload['chat_room_id']),
      channelName: payload['channel_name']?.toString(),
    );
  }

  NotificationModel copyWith({
    bool? isRead,
    String? readAt,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      type: type,
      readAt: readAt ?? this.readAt,
      actionType: actionType,
      caseId: caseId,
      caseNumber: caseNumber,
      businessId: businessId,
      chatRoomId: chatRoomId,
      channelName: channelName,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        createdAt,
        isRead,
        type,
        readAt,
        actionType,
        caseId,
        caseNumber,
        businessId,
        chatRoomId,
        channelName,
      ];
}
