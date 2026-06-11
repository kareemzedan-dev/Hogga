class IncomingCallPayload {
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

  factory IncomingCallPayload.fromMap(Map<String, dynamic> map) {
    String stringOf(dynamic value) => value?.toString() ?? '';

    return IncomingCallPayload(
      callId: int.tryParse(stringOf(map['call_id'])) ?? 0,
      chatRoomId: int.tryParse(stringOf(map['chat_room_id'])) ?? 0,
      channelName: stringOf(map['channel_name']),
      serviceType: stringOf(map['service_type']).isEmpty
          ? 'audio'
          : stringOf(map['service_type']),
      callerName: stringOf(map['caller_name']).isEmpty
          ? 'اتصال وارد'
          : stringOf(map['caller_name']),
      status: stringOf(map['status']).isEmpty
          ? 'initiated'
          : stringOf(map['status']),
      action: stringOf(map['action']).isEmpty
          ? 'initiated'
          : stringOf(map['action']),
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
