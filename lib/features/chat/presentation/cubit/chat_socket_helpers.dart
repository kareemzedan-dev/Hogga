import 'dart:convert';
import 'dart:developer';

import 'package:pusher_client/pusher_client.dart';

const List<String> chatMessageSocketEvents = [
  '.message.sent',
  'message.sent',
  'MessageSent',
  'App\\Events\\MessageSent',
];

const List<String> chatReadSocketEvents = [
  '.messages.read',
  'messages.read',
  'MessagesRead',
  'App\\Events\\MessagesRead',
];

void bindChatSocketEvents({
  required dynamic channel,
  required int roomId,
  required void Function(dynamic data) onMessage,
  required void Function(dynamic data) onRead,
  required String logLabel,
}) {
  for (final event in chatMessageSocketEvents) {
    channel.listen(event, onMessage);
  }

  for (final event in chatReadSocketEvents) {
    channel.listen(event, onRead);
  }

  try {
    channel.listenToAll((dynamic event, dynamic data) {
      final eventName = event?.toString() ?? '';
      log('$logLabel socket event: $eventName');

      if (_isMessageEvent(eventName)) {
        onMessage(data);
      } else if (_isReadEvent(eventName)) {
        onRead(data);
      }
    });
  } catch (_) {
    // Some channel implementations do not expose listenToAll.
  }

  try {
    channel.subscribed(() {
      log('$logLabel subscribed to private-chat.$roomId');
    });
    channel.error((dynamic status) {
      log('$logLabel subscription error for private-chat.$roomId: $status');
    });
  } catch (_) {
    // Subscription callbacks are package-specific.
  }

  log('$logLabel binding events for private-chat.$roomId');
}

Map<String, dynamic>? normalizeChatSocketPayload(dynamic rawData) {
  final payload = _asMap(rawData);
  if (payload == null) {
    return null;
  }

  final dataPayload = _asMap(payload['data']);
  if (dataPayload != null) {
    return {...payload, ...dataPayload};
  }

  final messagePayload = _asMap(payload['message']);
  if (messagePayload != null) {
    return {...payload, ...messagePayload};
  }

  return payload;
}

Map<String, dynamic>? buildChatMessagePayload(
  dynamic rawData, {
  required int roomId,
  required String currentSenderType,
}) {
  final payload = normalizeChatSocketPayload(rawData);
  if (payload == null) {
    return null;
  }

  final payloadRoomId = intFromAny(
    payload['chat_room_id'] ?? payload['chatRoomId'] ?? payload['room_id'],
  );
  if (payloadRoomId != null && payloadRoomId > 0 && payloadRoomId != roomId) {
    return null;
  }

  payload['chat_room_id'] = payloadRoomId ?? roomId;
  payload['id'] = intFromAny(payload['id']) ?? 0;
  payload['sender_id'] = intFromAny(payload['sender_id']) ?? 0;

  if (!payload.containsKey('file_url') && payload.containsKey('file_path')) {
    payload['file_url'] = payload['file_path'];
  }
  if (!payload.containsKey('file_type') || payload['file_type'] == null) {
    payload['file_type'] = 'text';
  }
  if (!payload.containsKey('is_read')) {
    payload['is_read'] = false;
  }
  if (!payload.containsKey('is_me')) {
    payload['is_me'] = payload['sender_type']?.toString() == currentSenderType;
  }
  if (!payload.containsKey('created_at') || payload['created_at'] == null) {
    payload['created_at'] = DateTime.now().toIso8601String();
  }

  return payload;
}

int? intFromAny(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

bool boolFromAny(dynamic value) {
  if (value is bool) {
    return value;
  }
  final normalized = value?.toString().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is PusherEvent) {
    return _asMap(value.data);
  }
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
  }
  return null;
}

bool _isMessageEvent(String event) {
  final key = _normalizedEventName(event);
  return key == 'message.sent' || key == 'messagesent';
}

bool _isReadEvent(String event) {
  final key = _normalizedEventName(event);
  return key == 'messages.read' || key == 'messagesread';
}

String _normalizedEventName(String event) {
  var key = event.replaceAll('\\', '.');
  if (key.startsWith('.')) {
    key = key.substring(1);
  }
  key = key.replaceFirst(RegExp(r'^App\.Events\.', caseSensitive: false), '');
  return key.toLowerCase();
}
