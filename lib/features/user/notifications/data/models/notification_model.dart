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
  final int? callId;
  final String? serviceType;
  final String? callerName;

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
    this.callId,
    this.serviceType,
    this.callerName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final meta = payload['meta'] is Map
        ? Map<String, dynamic>.from(payload['meta'] as Map)
        : <String, dynamic>{};

    final createdAtRaw = json['created_at']?.toString();
    final normalizedCreatedAt = createdAtRaw?.replaceFirst(' ', 'T');
    final readAt = json['read_at']?.toString();
    final type = (payload['type'] ?? json['type'])?.toString().toLowerCase();
    final actionType = (meta['action_type'] ?? payload['action_type'])
        ?.toString()
        .toLowerCase();
    final isCallPayload = _isCallType(type) || _isCallType(actionType);
    final isCasePayload = _isCaseType(type) || _isCaseType(actionType);
    final channelName = payload['channel_name']?.toString();

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: payload['title']?.toString() ?? json['title']?.toString() ?? '',
      body:
          payload['body']?.toString() ??
          payload['message']?.toString() ??
          json['body']?.toString() ??
          '',
      createdAt: normalizedCreatedAt != null
          ? DateTime.tryParse(normalizedCreatedAt) ?? DateTime.now()
          : DateTime.now(),
      isRead: readAt != null && readAt.isNotEmpty,
      readAt: readAt,
      type: type,
      actionType: actionType,
      caseId: _firstInt([
        meta['case_id'],
        payload['case_id'],
        json['case_id'],
        meta['legal_case_id'],
        payload['legal_case_id'],
        json['legal_case_id'],
        if (isCasePayload && !isCallPayload) payload['id'],
      ]),
      caseNumber: meta['case_number']?.toString(),
      businessId: _toInt(payload['id']),
      chatRoomId:
          _toInt(payload['chat_room_id']) ??
          _chatRoomIdFromChannel(channelName),
      channelName: channelName,
      callId: _firstInt([
        payload['call_id'],
        json['call_id'],
        if (isCallPayload) payload['id'],
      ]),
      serviceType: payload['service_type']?.toString() ?? type,
      callerName: payload['caller_name']?.toString() ?? _callerName(payload),
    );
  }

  NotificationModel copyWith({bool? isRead, String? readAt}) {
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
      callId: callId,
      serviceType: serviceType,
      callerName: callerName,
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

  static int? _firstInt(List<dynamic> values) {
    for (final value in values) {
      final parsed = _toInt(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static int? _chatRoomIdFromChannel(String? channelName) {
    if (channelName == null || channelName.isEmpty) {
      return null;
    }

    final match = RegExp(
      r'(?:chat_room_|chat\.|private-chat\.)(\d+)',
    ).firstMatch(channelName);
    return int.tryParse(match?.group(1) ?? '');
  }

  static String? _callerName(Map<String, dynamic> payload) {
    final caller = payload['caller'];
    if (caller is Map) {
      return caller['name']?.toString();
    }
    return caller?.toString();
  }

  static bool _isCallType(String? value) {
    final normalized = value?.toLowerCase() ?? '';
    return normalized.contains('call');
  }

  static bool _isCaseType(String? value) {
    final normalized = value?.toLowerCase() ?? '';
    return normalized.contains('case') ||
        normalized.contains('order') ||
        normalized.contains('legal') ||
        normalized.contains('proposal') ||
        normalized.contains('payment');
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
    callId,
    serviceType,
    callerName,
  ];
}
