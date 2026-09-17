class LawyerConsultationModel {
  final int id;
  final String consultationNumber;
  final String title;
  final String description;
  final String type;
  final String typeText;
  final String status;
  final String statusText;
  final String priceType;
  final String price;
  final int duration;
  final CallDurationModel? callDuration;
  final bool isCompletedByUser;
  final bool isCompletedByProvider;
  final String? scheduledAt;
  final String createdAt;
  final ConsultationClientModel client;
  final ConsultationChatInfoModel? chatInfo;

  const LawyerConsultationModel({
    required this.id,
    required this.consultationNumber,
    required this.title,
    this.description = '',
    required this.type,
    required this.typeText,
    required this.status,
    required this.statusText,
    required this.priceType,
    this.price = '',
    required this.duration,
    this.callDuration,
    required this.isCompletedByUser,
    required this.isCompletedByProvider,
    this.scheduledAt,
    required this.createdAt,
    required this.client,
    this.chatInfo,
  });

  bool get hasChatRoom => (chatInfo?.id ?? 0) > 0;
  bool get canComplete => !isCompletedByProvider && status == 'accepted';

  bool get isVideoCall {
    final t = type.toLowerCase();
    final txt = typeText.toLowerCase();
    final ttl = title.toLowerCase();
    return t.contains('video') ||
        txt.contains('فيديو') ||
        ttl.contains('فيديو') ||
        txt.contains('مرئية') ||
        ttl.contains('مرئية');
  }

  bool get isWritten {
    final t = type.toLowerCase();
    final txt = typeText.toLowerCase();
    final ttl = title.toLowerCase();
    return t == 'article' ||
        t.contains('written') ||
        txt.contains('مكتوب') ||
        ttl.contains('مكتوب');
  }

  bool get isVoiceCall {
    if (isVideoCall || isWritten) return false;
    final t = type.toLowerCase();
    final txt = typeText.toLowerCase();
    final ttl = title.toLowerCase();
    return t.contains('audio') ||
        t.contains('immediate') ||
        t.contains('scheduled') ||
        t.contains('call') ||
        txt.contains('صوت') ||
        ttl.contains('صوت') ||
        callDuration != null ||
        duration > 0;
  }

  bool get isCallType => (isVideoCall || isVoiceCall) && !isWritten;

  factory LawyerConsultationModel.fromJson(Map<String, dynamic> json) {
    return LawyerConsultationModel(
      id: _toInt(json['id']),
      consultationNumber: json['consultation_number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      typeText: json['type_text']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusText: json['status_text']?.toString() ?? '',
      priceType: json['price_type']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      duration: _toInt(json['duration']),
      callDuration: json['call_duration'] is Map
          ? CallDurationModel.fromJson(
              Map<String, dynamic>.from(json['call_duration'] as Map),
            )
          : null,
      isCompletedByUser: json['is_completed_by_user'] == true,
      isCompletedByProvider: json['is_completed_by_provider'] == true,
      scheduledAt: json['scheduled_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      client: ConsultationClientModel.fromJson(
        Map<String, dynamic>.from((json['client'] as Map?) ?? const {}),
      ),
      chatInfo: json['chat_info'] is Map
          ? ConsultationChatInfoModel.fromJson(
              Map<String, dynamic>.from(json['chat_info'] as Map),
            )
          : null,
    );
  }
}

class ConsultationClientModel {
  final int? id;
  final String name;
  final String? photo;
  final String? phone;

  const ConsultationClientModel({
    this.id,
    required this.name,
    this.photo,
    this.phone,
  });

  factory ConsultationClientModel.fromJson(Map<String, dynamic> json) {
    return ConsultationClientModel(
      id: json['id'] == null ? null : _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      photo: _cleanImageUrl(json['photo']?.toString()),
      phone: json['phone']?.toString(),
    );
  }
}

class ConsultationChatInfoModel {
  final int id;
  final String? agoraChannel;

  const ConsultationChatInfoModel({required this.id, this.agoraChannel});

  factory ConsultationChatInfoModel.fromJson(Map<String, dynamic> json) {
    return ConsultationChatInfoModel(
      id: _toInt(json['id']),
      agoraChannel: json['agora_channel']?.toString(),
    );
  }
}

class CallDurationModel {
  final int totalMinutes;
  final int usedMinutes;
  final int remainingMinutes;
  final List<dynamic> history;

  const CallDurationModel({
    required this.totalMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
    required this.history,
  });

  factory CallDurationModel.fromJson(Map<String, dynamic> json) {
    return CallDurationModel(
      totalMinutes: _toInt(json['total_minutes']),
      usedMinutes: _toInt(json['used_minutes']),
      remainingMinutes: _toInt(json['remaining_minutes']),
      history: json['history'] is List
          ? List<dynamic>.from(json['history'])
          : const [],
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _cleanImageUrl(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final trimmed = value.trim();
  final markdownMatch = RegExp(r'\]\((https?:\/\/[^)]+)\)').firstMatch(trimmed);
  if (markdownMatch != null) {
    return markdownMatch.group(1)?.replaceAll(r'\&', '&');
  }
  return trimmed.replaceAll(r'\&', '&');
}
