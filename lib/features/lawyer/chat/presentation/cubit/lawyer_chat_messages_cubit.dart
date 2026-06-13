import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/network/websocket_service.dart';
import '../../data/repositories/lawyer_chat_repository.dart';
import '../../../../chat/data/models/chat_message_model.dart';
import '../../../../chat/presentation/cubit/chat_messages_state.dart';

class LawyerChatMessagesCubit extends Cubit<ChatMessagesState> {
  final LawyerChatRepository repository;
  final int roomId;

  int _currentPage = 1;

  LawyerChatMessagesCubit({required this.repository, required this.roomId})
      : super(ChatMessagesInitial());

  Future<void> loadMessages() async {
    emit(ChatMessagesLoading());
    try {
      _currentPage = 1;
      final response = await repository.getMessages(roomId, page: 1);
      emit(ChatMessagesLoaded(
        messages: response.messages,
        hasMore: response.pagination.hasMore,
        counterparty: response.counterparty,
      ));
      _subscribeToChannel();
    } catch (e) {
      emit(ChatMessagesError(e.toString()));
    }
  }

  void _subscribeToChannel() {
    try {
      WebSocketService.init();
      final echo = WebSocketService.echo;
      if (echo == null) return;

      void onMessageReceived(dynamic data) {
        print('🔥 SOCKET WORKING (Lawyer Chat)');
        print(data);
        final current = state;
        if (current is! ChatMessagesLoaded) return;

        try {
          Map<String, dynamic> payload = Map<String, dynamic>.from(data as Map);
          
          if (payload.containsKey('data') && payload['data'] is Map) {
            payload = Map<String, dynamic>.from(payload['data']);
          } else if (payload.containsKey('message') && payload['message'] is Map) {
            payload = Map<String, dynamic>.from(payload['message']);
          }

          if (!payload.containsKey('file_url') && payload.containsKey('file_path')) {
            payload['file_url'] = payload['file_path'];
          }
          if (!payload.containsKey('is_me')) {
            payload['is_me'] = payload['sender_type'] == 'lawyer';
          }
          final newMsg = ChatMessageModel.fromJson(payload);

          final exists = current.messages.any((m) => m.id == newMsg.id);
          if (!exists) {
            emit(current.copyWith(messages: [newMsg, ...current.messages]));
          }
        } catch (e) {
          print('Error parsing WebSocket message in lawyer cubit: $e');
        }
      }

      final channel = echo.private('chat.$roomId');
      channel.listen('.message.sent', onMessageReceived);

      echo.private('chat.$roomId').listen('.messages.read', (dynamic data) {
        final current = state;
        if (current is! ChatMessagesLoaded) return;

        final updated = current.messages.map((m) {
          return ChatMessageModel(
            id: m.id,
            senderId: m.senderId,
            senderType: m.senderType,
            message: m.message,
            fileUrl: m.fileUrl,
            fileType: m.fileType,
            isRead: true,
            isMe: m.isMe,
            createdAt: m.createdAt,
          );
        }).toList();
        emit(current.copyWith(messages: updated));
      });
    } catch (_) {
      // WebSocket unavailable, fallback silently
    }
  }

  @override
  Future<void> close() {
    try {
      WebSocketService.echo?.leave('chat.$roomId');
    } catch (_) {}
    return super.close();
  }

  Future<void> loadMoreMessages() async {
    final current = state;
    if (current is! ChatMessagesLoaded ||
        !current.hasMore ||
        current.isLoadingMore) { return; }

    emit(current.copyWith(isLoadingMore: true));
    try {
      _currentPage++;
      final response = await repository.getMessages(roomId, page: _currentPage);
      final combined = [...current.messages, ...response.messages];
      emit(current.copyWith(
        messages: combined,
        hasMore: response.pagination.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      _currentPage--;
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> sendMessage({String? message, File? file}) async {
    final current = state;
    if (current is! ChatMessagesLoaded) return;
    if ((message == null || message.isEmpty) && file == null) return;

    emit(current.copyWith(isSending: true));
    try {
      final newMsg =
          await repository.sendMessage(roomId, message: message, file: file);
      // Insert optimistically - WebSocket will also push it but we deduplicate
      emit(current.copyWith(
        messages: [newMsg, ...current.messages],
        isSending: false,
      ));
    } catch (e) {
      emit(current.copyWith(isSending: false));
      rethrow;
    }
  }
}
