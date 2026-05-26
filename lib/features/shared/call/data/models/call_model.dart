enum CallType { video, audio }

class CallModel {
  final String channelName;
  final String? token;
  final CallType type;
  final int durationInSeconds; // Duration provided by backend
  final String callerName;
  final String callerAvatar;

  CallModel({
    required this.channelName,
    this.token,
    required this.type,
    required this.durationInSeconds,
    required this.callerName,
    required this.callerAvatar,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      channelName: json['channelName'] ?? '',
      token: json['token'],
      type: json['type'] == 'video' ? CallType.video : CallType.audio,
      durationInSeconds: json['duration'] ?? 0,
      callerName: json['callerName'] ?? 'Unknown',
      callerAvatar: json['callerAvatar'] ?? '',
    );
  }
}
