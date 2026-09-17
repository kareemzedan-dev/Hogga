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
      id: _readInt(json['id'] ?? json['user_id']),
      name: json['name']?.toString() ??
          json['full_name']?.toString() ??
          json['client_name']?.toString() ??
          json['user_name']?.toString() ??
          '',
      photo: _cleanPhotoUrl(
        json['photo']?.toString() ??
            json['avatar']?.toString() ??
            json['image']?.toString() ??
            json['profile_image']?.toString(),
      ),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _cleanPhotoUrl(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null ||
        trimmed.isEmpty ||
        trimmed.toLowerCase() == 'null' ||
        trimmed.toLowerCase() == '**null**') {
      return null;
    }
    final markdownMatch = RegExp(r'\]\((.*?)\)').firstMatch(trimmed);
    return markdownMatch?.group(1) ?? trimmed;
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
    final legalCase =
        json['legal_case'] is Map ? json['legal_case'] as Map : null;
    final caseObj = json['case'] is Map ? json['case'] as Map : null;
    final chatable = json['chatable'] is Map ? json['chatable'] as Map : null;
    final order = json['order'] is Map ? json['order'] as Map : null;

    final caseTitle = _cleanString(
      json['case_title'] ??
          json['caseTitle'] ??
          legalCase?['title'] ??
          legalCase?['case_title'] ??
          caseObj?['title'] ??
          caseObj?['case_title'] ??
          chatable?['title'] ??
          chatable?['case_title'] ??
          order?['title'] ??
          json['title'],
    );

    final caseNumber = _cleanString(
      json['case_number'] ??
          json['caseNumber'] ??
          legalCase?['case_number'] ??
          caseObj?['case_number'] ??
          chatable?['case_number'] ??
          chatable?['order_number'] ??
          order?['case_number'] ??
          order?['order_number'] ??
          json['order_number'],
    );

    final lawyerJson = json['lawyer'] ??
        json['user'] ??
        json['client'] ??
        json['other_user'] ??
        json['counterparty'] ??
        json['customer'] ??
        json['provider'] ??
        {};

    return ChatRoomModel(
      chatRoomId: _readInt(json['chat_room_id'] ?? json['id']),
      legalCaseId: _readInt(
        json['legal_case_id'] ??
            json['chatable_id'] ??
            legalCase?['id'] ??
            caseObj?['id'] ??
            chatable?['id'] ??
            order?['id'],
      ),
      caseNumber: caseNumber,
      caseTitle: caseTitle,
      lawyer: ChatLawyerModel.fromJson(
        Map<String, dynamic>.from(lawyerJson is Map ? lawyerJson : {}),
      ),
      latestMessage: json['latest_message'] != null
          ? LatestMessageModel.fromJson(
              Map<String, dynamic>.from(json['latest_message']),
            )
          : null,
      unreadCount: _readInt(json['unread_count']),
    );
  }

  static String _cleanString(dynamic value) {
    if (value == null) return '';
    final trimmed = value.toString().trim();
    if (trimmed.toLowerCase() == 'null' || trimmed.toLowerCase() == '**null**') {
      return '';
    }
    return trimmed;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
