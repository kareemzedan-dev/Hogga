import 'dart:convert';

class IncomingCallPayload {
  static const Duration ringingTimeout = Duration(seconds: 30);

  final int callId;
  final int chatRoomId;
  final String channelName;
  final String serviceType;
  final String callerName;
  final String status;
  final String action;

  const IncomingCallPayload({
    required this.callId,
    required this.chatRoomId,
    required this.channelName,
    required this.serviceType,
    required this.callerName,
    this.status = 'initiated',
    this.action = 'initiated',
  });

  bool get isVideo => serviceType.toLowerCase() == 'video';
  bool get isAudio => !isVideo;
  int get fallbackNotificationId =>
      900000 + (chatRoomId > 0 ? chatRoomId : callId);
  int get notificationId => callId > 0 ? callId : fallbackNotificationId;
  String get notificationTag => 'incoming_call_$notificationId';

  List<int> get notificationIds {
    final ids = <int>{};
    if (callId > 0) {
      ids.add(callId);
    }
    if (chatRoomId > 0) {
      ids.add(fallbackNotificationId);
    }
    if (ids.isEmpty) {
      ids.add(notificationId);
    }
    return ids.toList();
  }

  List<String> get notificationTags {
    return notificationIds.map((id) => 'incoming_call_$id').toList();
  }

  factory IncomingCallPayload.fromMap(Map<String, dynamic> map) {
    String stringOf(dynamic value) => value?.toString() ?? '';
    int intOf(dynamic value) => int.tryParse(stringOf(value)) ?? 0;

    final rawType = stringOf(map['type']).toLowerCase();
    final rawServiceType = stringOf(map['service_type']).toLowerCase();
    final serviceType = rawServiceType.isNotEmpty
        ? rawServiceType
        : rawType.contains('video')
        ? 'video'
        : 'audio';

    final meta = _mapOf(map['meta']);
    final caller = _mapOf(map['caller']);
    final callerName = stringOf(map['caller_name']).isNotEmpty
        ? stringOf(map['caller_name'])
        : stringOf(caller?['name']).isNotEmpty
        ? stringOf(caller?['name'])
        : 'اتصال وارد';
    final status = stringOf(map['status']).isNotEmpty
        ? stringOf(map['status'])
        : stringOf(meta?['status']).isNotEmpty
        ? stringOf(meta?['status'])
        : 'initiated';
    final action = stringOf(map['action']).isNotEmpty
        ? stringOf(map['action'])
        : stringOf(meta?['action']).isNotEmpty
        ? stringOf(meta?['action'])
        : status;

    return IncomingCallPayload(
      callId: intOf(map['call_id'] ?? map['callId'] ?? map['id']),
      chatRoomId: intOf(map['chat_room_id'] ?? map['chatRoomId']),
      channelName: stringOf(map['channel_name']),
      serviceType: serviceType,
      callerName: callerName,
      status: status,
      action: action,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': 'incoming_call',
      'call_id': callId.toString(),
      'chat_room_id': chatRoomId.toString(),
      'channel_name': channelName,
      'service_type': serviceType,
      'caller_name': callerName,
      'status': status,
      'action': action,
    };
  }
}

Map<String, dynamic>? _mapOf(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  if (value is String && value.trim().startsWith('{')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
  }
  return null;
}
