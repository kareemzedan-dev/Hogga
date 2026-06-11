import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/calls/incoming_call_payload.dart';
import 'package:hogga/core/navigation/app_navigator.dart';
import 'package:hogga/core/network/websocket_service.dart';
import 'package:hogga/features/chat/data/models/chat_room_model.dart';
import 'package:hogga/features/chat/data/repositories/chat_repository.dart';
import 'package:hogga/features/lawyer/chat/data/repositories/lawyer_chat_repository.dart';
import 'package:hogga/features/shared/call/presentation/screens/incoming_call_screen.dart';
import 'package:hogga/injection_container.dart' as di;

class CallCoordinator {
  CallCoordinator._();

  static final CallCoordinator instance = CallCoordinator._();

  bool _isInitialized = false;
  bool _isShowingIncomingCall = false;
  int? _activeCallId;
  IncomingCallPayload? _pendingPayload;
  final Set<int> _subscribedRooms = <int>{};
  final Map<int, String> _roomCallerNames = <int, String>{};

  Future<void> initialize() async {
    if (_isInitialized || !AppPreferences().isLoggedIn) {
      return;
    }

    _isInitialized = true;
    try {
      WebSocketService.init();
      final rooms = await _loadRooms();
      _subscribeToCallEvents(rooms);
    } catch (e) {
      log('CallCoordinator init failed: $e');
    }
  }

  Future<void> syncAfterLogin() async {
    _isInitialized = false;
    _subscribedRooms.clear();
    _roomCallerNames.clear();
    await initialize();
  }

  void reset() {
    _isInitialized = false;
    _isShowingIncomingCall = false;
    _activeCallId = null;
    _pendingPayload = null;
    _subscribedRooms.clear();
    _roomCallerNames.clear();
    WebSocketService.dispose();
  }

  Future<void> handleRemotePayload(Map<String, dynamic> data) async {
    final type = data['type']?.toString() ?? '';
    if (type != 'incoming_call') {
      return;
    }

    final payload = IncomingCallPayload.fromMap(data);
    await _showIncomingCall(payload);
  }

  Future<void> processPendingNavigation() async {
    final payload = _pendingPayload;
    if (payload == null) {
      return;
    }

    _pendingPayload = null;
    await _showIncomingCall(payload);
  }

  Future<void> updateCallStatus(
    IncomingCallPayload payload,
    String status,
  ) async {
    try {
      if (AppPreferences().isProvider) {
        await di.sl<LawyerChatRepository>()
            .updateCallStatus(payload.callId, status);
      } else {
        await di.sl<ChatRepository>().updateCallStatus(payload.callId, status);
      }
    } catch (e) {
      log('Failed to update call status: $e');
    }
  }

  void _subscribeToCallEvents(List<ChatRoomModel> rooms) {
    final echo = WebSocketService.echo;
    if (echo == null) {
      return;
    }

    for (final room in rooms) {
      _roomCallerNames[room.chatRoomId] = room.lawyer.name;

      if (!_subscribedRooms.add(room.chatRoomId)) {
        continue;
      }

      final channel = echo.private('chat.${room.chatRoomId}');
      channel.listen('call.event', (dynamic data) {
        _handleSocketCallEvent(data);
      });
      channel.listen('.call.event', (dynamic data) {
        _handleSocketCallEvent(data);
      });
    }
  }

  Future<List<ChatRoomModel>> _loadRooms() async {
    if (AppPreferences().isProvider) {
      return di.sl<LawyerChatRepository>().getChatRooms();
    }
    return di.sl<ChatRepository>().getChatRooms();
  }

  void _handleSocketCallEvent(dynamic rawData) {
    try {
      final map = Map<String, dynamic>.from(rawData as Map);
      final action = map['action']?.toString() ?? '';
      final status = map['status']?.toString() ?? '';

      if (action == 'initiated' || status == 'initiated') {
        final roomId =
            int.tryParse(map['chat_room_id']?.toString() ?? '') ?? 0;
        handleRemotePayload({
          ...map,
          'type': 'incoming_call',
          'service_type': map['type'],
          'caller_name':
              map['caller_name'] ?? _roomCallerNames[roomId] ?? 'اتصال وارد',
        });
        return;
      }

      final callId =
          int.tryParse(map['call_id']?.toString() ?? '') ?? 0;
      if (_activeCallId == callId &&
          {'ended', 'declined', 'missed'}.contains(action.isNotEmpty ? action : status)) {
        _dismissIncomingCall();
      }
    } catch (e) {
      log('Socket call event parse failed: $e');
    }
  }

  Future<void> _showIncomingCall(IncomingCallPayload payload) async {
    if (_isShowingIncomingCall) {
      return;
    }

    final navigator = AppNavigator.navigatorKey.currentState;
    if (navigator == null) {
      _pendingPayload = payload;
      return;
    }

    _isShowingIncomingCall = true;
    _activeCallId = payload.callId;

    await navigator.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => IncomingCallScreen(
          payload: payload,
          onStatusChanged: updateCallStatus,
        ),
      ),
    );

    _isShowingIncomingCall = false;
    _activeCallId = null;
  }

  void _dismissIncomingCall() {
    final navigator = AppNavigator.navigatorKey.currentState;
    if (!_isShowingIncomingCall || navigator == null || !navigator.canPop()) {
      return;
    }
    navigator.pop();
  }
}
