import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? type; // e.g., 'order_update', 'payment', 'system'

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isRead: json['read_at'] != null || json['is_read'] == true,
      type: json['type'],
    );
  }

  @override
  List<Object?> get props => [id, title, body, createdAt, isRead, type];
}
