class CallTokenModel {
  final int callId;
  final String token;
  final String channelName;
  final int uid;
  final String appId;
  final String serviceType;
  final String expiresAt;

  CallTokenModel({
    required this.callId,
    required this.token,
    required this.channelName,
    required this.uid,
    required this.appId,
    required this.serviceType,
    required this.expiresAt,
  });

  bool get isVideo => serviceType == 'video';
  bool get isAudio => serviceType == 'audio' || serviceType == 'phone';

  factory CallTokenModel.fromJson(Map<String, dynamic> json) {
    return CallTokenModel(
      callId: json['call_id'] ?? 0,
      token: json['token']?.toString() ?? '',
      channelName: json['channel_name']?.toString() ?? '',
      uid: json['uid'] ?? 0,
      appId: json['app_id']?.toString() ?? '',
      serviceType:
          json['service_type']?.toString() ??
          json['type']?.toString() ??
          'audio',
      expiresAt: json['expires_at']?.toString() ?? '',
    );
  }
}
