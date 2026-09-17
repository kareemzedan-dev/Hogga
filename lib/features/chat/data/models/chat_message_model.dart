class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderType;
  final String? message;
  final String? fileUrl;
  final String fileType;
  final bool isRead;
  final bool isMe;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderType,
    this.message,
    this.fileUrl,
    required this.fileType,
    required this.isRead,
    required this.isMe,
    required this.createdAt,
  });

  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  bool get hasText => message != null && message!.isNotEmpty;
  bool get isImage => fileType == 'image';
  bool get isPdf => fileType == 'pdf';
  bool get isAudio => fileType == 'audio';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _toInt(json['id']) ?? 0,
      senderId: _toInt(json['sender_id']) ?? 0,
      senderType: json['sender_type']?.toString() ?? '',
      message: json['message']?.toString(),
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString() ?? 'text',
      isRead: _toBool(json['is_read']),
      isMe: _toBool(json['is_me']),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
}

class ChatPaginationModel {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  ChatPaginationModel({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory ChatPaginationModel.fromJson(Map<String, dynamic> json) {
    return ChatPaginationModel(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 20,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class CounterpartyModel {
  final int id;
  final String type;
  final String name;
  final String? photo;

  CounterpartyModel({
    required this.id,
    required this.type,
    required this.name,
    this.photo,
  });

  factory CounterpartyModel.fromJson(Map<String, dynamic> json) {
    return CounterpartyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      photo: _cleanPhotoUrl(
        json['photo'] ??
            json['avatar'] ??
            json['image'] ??
            json['profile_image'],
      ),
    );
  }

  static String? _cleanPhotoUrl(dynamic value) {
    if (value == null) return null;
    final trimmed = value.toString().trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'null' ||
        trimmed.toLowerCase() == '**null**') {
      return null;
    }
    final markdownMatch = RegExp(r'\]\((.*?)\)').firstMatch(trimmed);
    return markdownMatch?.group(1) ?? trimmed;
  }
}

class ChatMessagesResponse {
  final List<ChatMessageModel> messages;
  final ChatPaginationModel pagination;
  final CounterpartyModel? counterparty;

  ChatMessagesResponse({
    required this.messages,
    required this.pagination,
    this.counterparty,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = rawData is List ? rawData : <dynamic>[];
    return ChatMessagesResponse(
      messages: list
          .whereType<Map>()
          .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: json['pagination'] != null
          ? ChatPaginationModel.fromJson(
              Map<String, dynamic>.from(json['pagination']),
            )
          : ChatPaginationModel(
              total: 0,
              perPage: 20,
              currentPage: 1,
              lastPage: 1,
            ),
      counterparty: json['counterparty'] != null
          ? CounterpartyModel.fromJson(
              Map<String, dynamic>.from(json['counterparty']),
            )
          : null,
    );
  }
}
