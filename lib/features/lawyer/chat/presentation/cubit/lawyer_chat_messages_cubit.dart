import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/network/fcm_service.dart';
import 'package:hogga/core/network/websocket_service.dart';

import '../../../../chat/data/models/chat_message_model.dart';
import '../../../../chat/presentation/cubit/chat_messages_state.dart';
import '../../../../chat/presentation/cubit/chat_socket_helpers.dart';
import '../../data/repositories/lawyer_chat_repository.dart';

class LawyerChatMessagesCubit extends Cubit<ChatMessagesState> {
  final LawyerChatRepository repository;
  final int roomId;

  int _currentPage = 1;
  bool _wasSocketDisconnected = false;
  bool _isSyncingLatest = false;
  StreamSubscription<String>? _socketStateSub;
  StreamSubscription<Map<String, dynamic>>? _foregroundMessageSub;

  LawyerChatMessagesCubit({required this.repository, required this.roomId})
    : super(ChatMessagesInitial());

  Future<void> loadMessages() async {
    emit(ChatMessagesLoading());
    try {
      _currentPage = 1;
      final response = await repository.getMessages(roomId, page: 1);
      emit(
        ChatMessagesLoaded(
          messages: response.messages,
          hasMore: response.pagination.hasMore,
          counterparty: response.counterparty,
        ),
      );
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
        final current = state;
        if (current is! ChatMessagesLoaded) {
          log('Lawyer chat event received before messages loaded');
          return;
        }

        try {
          final payload = buildChatMessagePayload(
            data,
            roomId: roomId,
            currentSenderType: 'lawyer',
          );
          if (payload == null) {
            log('Ignoring lawyer chat socket payload: $data');
            return;
          }

          final newMsg = ChatMessageModel.fromJson(payload);
          final exists = current.messages.any((m) => m.id == newMsg.id);
          if (!exists) {
            emit(current.copyWith(messages: [newMsg, ...current.messages]));
          } else {
            log('Lawyer chat message already exists: ${newMsg.id}');
          }
        } catch (e) {
          log('Error parsing lawyer chat socket message: $e');
        }
      }

      void onMessagesRead(dynamic data) {
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
      }

      final channel = echo.private('chat.$roomId');
      bindChatSocketEvents(
        channel: channel,
        roomId: roomId,
        onMessage: onMessageReceived,
        onRead: onMessagesRead,
        logLabel: 'Lawyer chat',
      );
      _listenToSocketReconnect();
      _listenToForegroundChatNotifications();
    } catch (e) {
      log('Lawyer chat socket subscribe failed: $e');
    }
  }

  void _listenToSocketReconnect() {
    _socketStateSub?.cancel();
    _socketStateSub = WebSocketService.connectionStates.listen((state) {
      final normalized = state.toUpperCase();
      if (normalized == 'CONNECTED') {
        if (_wasSocketDisconnected) {
          unawaited(_syncLatestMessages());
        }
        _wasSocketDisconnected = false;
        return;
      }

      if (normalized == 'RECONNECTING' ||
          normalized == 'CONNECTING' ||
          normalized == 'DISCONNECTED') {
        _wasSocketDisconnected = true;
      }
    });
  }

  void _listenToForegroundChatNotifications() {
    _foregroundMessageSub?.cancel();
    _foregroundMessageSub = FcmService.instance.foregroundMessages.listen((
      data,
    ) {
      if (data['type']?.toString() != 'chat_message') {
        return;
      }

      final payloadRoomId = intFromAny(
        data['chat_room_id'] ?? data['chatRoomId'],
      );
      if (payloadRoomId != roomId) {
        log(
          'Ignoring lawyer foreground chat FCM for room $payloadRoomId while room $roomId is open',
        );
        return;
      }

      unawaited(_syncLatestMessages());
    });
  }

  Future<void> _syncLatestMessages() async {
    final current = state;
    if (current is! ChatMessagesLoaded || _isSyncingLatest) {
      return;
    }

    _isSyncingLatest = true;
    try {
      final response = await repository.getMessages(roomId, page: 1);
      final latestIds = response.messages.map((m) => m.id).toSet();
      final olderCached = current.messages
          .where((m) => !latestIds.contains(m.id))
          .toList();

      emit(
        current.copyWith(
          messages: [...response.messages, ...olderCached],
          hasMore: response.pagination.hasMore,
          counterparty: response.counterparty,
        ),
      );
    } catch (e) {
      log('Lawyer chat reconnect sync failed: $e');
    } finally {
      _isSyncingLatest = false;
    }
  }

  @override
  Future<void> close() {
    _socketStateSub?.cancel();
    _foregroundMessageSub?.cancel();
    try {
      WebSocketService.echo?.leave('chat.$roomId');
    } catch (_) {}
    return super.close();
  }

  Future<void> loadMoreMessages() async {
    final current = state;
    if (current is! ChatMessagesLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      _currentPage++;
      final response = await repository.getMessages(roomId, page: _currentPage);
      final combined = [...current.messages, ...response.messages];
      emit(
        current.copyWith(
          messages: combined,
          hasMore: response.pagination.hasMore,
          isLoadingMore: false,
        ),
      );
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
      final newMsg = await repository.sendMessage(
        roomId,
        message: message,
        file: file,
      );
      emit(
        current.copyWith(
          messages: [newMsg, ...current.messages],
          isSending: false,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isSending: false));
      rethrow;
    }
  }
}
