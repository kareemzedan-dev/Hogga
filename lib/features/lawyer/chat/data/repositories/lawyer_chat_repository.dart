import 'dart:io';
import '../datasources/lawyer_chat_remote_data_source.dart';
import '../../../../chat/data/models/chat_room_model.dart';
import '../../../../chat/data/models/chat_message_model.dart';
import '../../../../chat/data/models/call_token_model.dart';

class LawyerChatRepository {
  final LawyerChatRemoteDataSource remoteDataSource;

  LawyerChatRepository({required this.remoteDataSource});

  Future<List<ChatRoomModel>> getChatRooms() => remoteDataSource.getChatRooms();

  Future<ChatMessagesResponse> getMessages(int roomId, {int page = 1}) =>
      remoteDataSource.getMessages(roomId, page: page);

  Future<ChatMessageModel> sendMessage(
    int roomId, {
    String? message,
    File? file,
  }) => remoteDataSource.sendMessage(roomId, message: message, file: file);

  Future<CallTokenModel> getCallToken(int roomId) =>
      remoteDataSource.getCallToken(roomId);

  Future<void> connectCall(int callId) => remoteDataSource.connectCall(callId);

  Future<int> endCall(int callId, {int duration = 0}) =>
      remoteDataSource.endCall(callId, duration: duration);

  Future<void> updateCallStatus(int callId, String status) =>
      remoteDataSource.updateCallStatus(callId, status);
}
