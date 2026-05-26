enum AttachmentType { none, image, file }

class MessageModel {
  final String id;
  final String text;
  final bool isMe;
  final DateTime createdAt;
  final String? attachmentUrl;
  final AttachmentType attachmentType;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.createdAt,
    this.attachmentUrl,
    this.attachmentType = AttachmentType.none,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    return MessageModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isMe: json['senderId'] == currentUserId,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      attachmentUrl: json['attachmentUrl'],
      attachmentType: _getAttachmentType(json['attachmentType']),
    );
  }

  Map<String, dynamic> toJson(String currentUserId, String receiverId) {
    return {
      'id': id,
      'text': text,
      'senderId': currentUserId,
      'receiverId': receiverId,
      'createdAt': createdAt.toIso8601String(),
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType.name,
    };
  }

  static AttachmentType _getAttachmentType(String? type) {
    switch (type) {
      case 'image':
        return AttachmentType.image;
      case 'file':
        return AttachmentType.file;
      default:
        return AttachmentType.none;
    }
  }
}
