import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../chat/data/models/chat_room_model.dart';
import '../../../../chat/data/models/chat_message_model.dart';
import '../../../../chat/data/models/call_token_model.dart';

class LawyerChatRemoteDataSource {
  final ApiClient apiClient;

  LawyerChatRemoteDataSource({required this.apiClient});

  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await apiClient.get(AppEndPoints.lawyerChats);
    final rawData = response.data['data'];
    final list = rawData is List ? rawData : <dynamic>[];
    return list
        .whereType<Map>()
        .map((e) => ChatRoomModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ChatMessagesResponse> getMessages(int roomId, {int page = 1}) async {
    final response = await apiClient.get(
      AppEndPoints.lawyerChatMessages(roomId),
      queryParameters: {'page': page},
    );
    return ChatMessagesResponse.fromJson(response.data);
  }

  Future<ChatMessageModel> sendMessage(
    int roomId, {
    String? message,
    File? file,
  }) async {
    final formData = FormData();
    if (message != null && message.isNotEmpty) {
      formData.fields.add(MapEntry('message', message));
    }
    if (file != null) {
      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }
    final response = await apiClient.post(
      AppEndPoints.lawyerSendChatMessage(roomId),
      data: formData,
    );
    return ChatMessageModel.fromJson(response.data['data']);
  }

  Future<CallTokenModel> getCallToken(int roomId) async {
    final response = await apiClient.get(AppEndPoints.lawyerCallToken(roomId));
    return CallTokenModel.fromJson(response.data['data']);
  }

  Future<void> connectCall(int callId) async {
    await apiClient.post(AppEndPoints.lawyerConnectCall(callId));
  }

  Future<int> endCall(int callId, {int duration = 0}) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerEndCall(callId),
      data: {'duration': duration},
    );
    final responseDuration = response.data?['data']?['duration'];
    return (responseDuration is num && responseDuration > 0)
        ? responseDuration.toInt()
        : 0;
  }

  Future<void> updateCallStatus(int callId, String status) async {
    await apiClient.post(
      AppEndPoints.lawyerCallStatus(callId),
      data: {'status': status},
    );
  }
}
