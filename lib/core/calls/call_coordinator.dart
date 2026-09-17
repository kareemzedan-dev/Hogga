import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/calls/call_screen_launcher.dart';
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
  final Set<int> _closedCallIds = <int>{};
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
    WebSocketService.dispose();
    await initialize();
  }

  void reset() {
    _isInitialized = false;
    _isShowingIncomingCall = false;
    _activeCallId = null;
    _pendingPayload = null;
    _subscribedRooms.clear();
    _closedCallIds.clear();
    _roomCallerNames.clear();
    WebSocketService.dispose();
  }

  Future<void> handleRemotePayload(Map<String, dynamic> data) async {
    final type = data['type']?.toString() ?? '';
    if (!_isIncomingCallType(type)) {
      return;
    }

    final payload = IncomingCallPayload.fromMap(data);
    if (_isTerminalCallPayload(payload)) {
      dismissIncomingCall(payload.callId);
      _markCallClosed(payload.callId);
      return;
    }
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
        await di.sl<LawyerChatRepository>().updateCallStatus(
          payload.callId,
          status,
        );
      } else {
        await di.sl<ChatRepository>().updateCallStatus(payload.callId, status);
      }
    } catch (e) {
      log('Failed to update call status: $e');
    }
  }

  Future<void> acceptIncomingCall(IncomingCallPayload payload) async {
    _pendingPayload = null;
    _dismissIncomingCall();

    final navigator = AppNavigator.navigatorKey.currentState;
    if (navigator == null) {
      _pendingPayload = payload;
      return;
    }

    _isShowingIncomingCall = false;
    _activeCallId = payload.callId;
    try {
      await pushIncomingAgoraCall(navigator: navigator, payload: payload);
    } finally {
      _markCallClosed(payload.callId);
      _activeCallId = null;
    }
  }

  Future<void> declineIncomingCall(IncomingCallPayload payload) async {
    _pendingPayload = null;
    await updateCallStatus(payload, 'declined');
    _markCallClosed(payload.callId);
    dismissIncomingCall(payload.callId);
  }

  void dismissIncomingCall([int? callId]) {
    if (callId != null &&
        callId > 0 &&
        _activeCallId != null &&
        _activeCallId != callId) {
      return;
    }
    _dismissIncomingCall();
    if (callId != null) {
      _markCallClosed(callId);
    }
    _activeCallId = null;
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
      for (final event in [
        '.call.event',
        'call.event',
        'App\\Events\\CallEvent',
      ]) {
        channel.listen(event, (dynamic data) {
          _handleSocketCallEvent(data);
        });
      }
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
      final map = _mapFromSocketData(rawData);
      if (map == null) {
        log('Socket call event ignored: $rawData');
        return;
      }
      final action = map['action']?.toString() ?? '';
      final status = map['status']?.toString() ?? '';

      if (action == 'initiated' || status == 'initiated') {
        final roomId = int.tryParse(map['chat_room_id']?.toString() ?? '') ?? 0;
        handleRemotePayload({
          ...map,
          'type': 'incoming_call',
          'service_type': map['type'],
          'caller_name':
              map['caller_name'] ?? _roomCallerNames[roomId] ?? 'اتصال وارد',
        });
        return;
      }

      final callId = int.tryParse(map['call_id']?.toString() ?? '') ?? 0;
      if (_activeCallId == callId &&
          {
            'ended',
            'declined',
            'missed',
          }.contains(action.isNotEmpty ? action : status)) {
        _markCallClosed(callId);
        _dismissIncomingCall();
      }
    } catch (e) {
      log('Socket call event parse failed: $e');
    }
  }

  Future<void> _showIncomingCall(IncomingCallPayload payload) async {
    if (_shouldIgnoreIncomingCall(payload)) {
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

    _markCallClosed(payload.callId);
    _isShowingIncomingCall = false;
    _activeCallId = null;
  }

  bool _shouldIgnoreIncomingCall(IncomingCallPayload payload) {
    if (_isShowingIncomingCall || isIncomingAgoraCallRouteActive(payload)) {
      return true;
    }
    if (payload.callId > 0) {
      return _activeCallId == payload.callId ||
          _closedCallIds.contains(payload.callId);
    }
    return false;
  }

  bool _isTerminalCallPayload(IncomingCallPayload payload) {
    final values = {
      payload.action.toLowerCase().trim(),
      payload.status.toLowerCase().trim(),
    };
    return values.any(
      (value) =>
          value == 'ended' ||
          value == 'declined' ||
          value == 'missed' ||
          value == 'canceled' ||
          value == 'cancelled',
    );
  }

  void _markCallClosed(int callId) {
    if (callId <= 0) {
      return;
    }
    _closedCallIds.add(callId);
    if (_closedCallIds.length > 50) {
      _closedCallIds.remove(_closedCallIds.first);
    }
  }

  void _dismissIncomingCall() {
    final navigator = AppNavigator.navigatorKey.currentState;
    if (!_isShowingIncomingCall || navigator == null || !navigator.canPop()) {
      return;
    }
    navigator.pop();
  }

  bool _isIncomingCallType(String type) {
    return type == 'incoming_call' ||
        type == 'audio_call' ||
        type == 'video_call';
  }

  Map<String, dynamic>? _mapFromSocketData(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      return Map<String, dynamic>.from(rawData);
    }
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }
    if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
