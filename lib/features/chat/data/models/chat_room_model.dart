import 'package:flutter/material.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class ChatLawyerModel {
  final int id;
  final String name;
  final String? photo;

  ChatLawyerModel({required this.id, required this.name, this.photo});

  factory ChatLawyerModel.fromJson(Map<String, dynamic> json) {
    return ChatLawyerModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      photo: json['photo']?.toString(),
    );
  }
}

class LatestMessageModel {
  final String? message;
  final String? fileType;
  final String? createdAt;

  LatestMessageModel({this.message, this.fileType, this.createdAt});

  factory LatestMessageModel.fromJson(Map<String, dynamic> json) {
    return LatestMessageModel(
      message: json['message']?.toString(),
      fileType: json['file_type']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  String getPreview(BuildContext context) {
    if (message != null && message!.isNotEmpty) return message!;
    if (fileType == 'pdf') return '📄 ${AppStrings.pdfFile.tr(context)}';
    if (fileType == 'image') return '🖼 ${AppStrings.imagePreview.tr(context)}';
    if (fileType == 'audio') return '🎵 ${AppStrings.audioPreview.tr(context)}';
    return '📎 ${AppStrings.attachment.tr(context)}';
  }
}

class ChatRoomModel {
  final int chatRoomId;
  final int legalCaseId;
  final String caseNumber;
  final String caseTitle;
  final ChatLawyerModel lawyer;
  final LatestMessageModel? latestMessage;
  final int unreadCount;

  ChatRoomModel({
    required this.chatRoomId,
    required this.legalCaseId,
    required this.caseNumber,
    required this.caseTitle,
    required this.lawyer,
    this.latestMessage,
    required this.unreadCount,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatRoomId: json['chat_room_id'] ?? 0,
      legalCaseId: json['legal_case_id'] ?? 0,
      caseNumber: json['case_number']?.toString() ?? '',
      caseTitle: json['case_title']?.toString() ?? '',
      lawyer: ChatLawyerModel.fromJson(
          Map<String, dynamic>.from(json['lawyer'] ?? {})),
      latestMessage: json['latest_message'] != null
          ? LatestMessageModel.fromJson(
              Map<String, dynamic>.from(json['latest_message']))
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
