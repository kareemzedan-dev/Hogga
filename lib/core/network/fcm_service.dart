import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/calls/call_coordinator.dart';
import 'package:hogga/core/calls/incoming_call_payload.dart';
import 'package:hogga/core/navigation/app_navigator.dart';
import 'package:hogga/core/network/api_client.dart';
import 'package:hogga/firebase_options.dart';
import 'package:hogga/features/chat/data/repositories/chat_repository.dart';
import 'package:hogga/features/lawyer/chat/data/repositories/lawyer_chat_repository.dart';
import 'package:hogga/injection_container.dart' as di;

const String _pendingDeclinedCallsKey = 'pending_declined_call_ids';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  log('Handling a background message: ${message.messageId}');
  await FcmService.instance.showLocalNotification(message);
}

@pragma('vm:entry-point')
void _localNotificationBackgroundHandler(NotificationResponse response) {
  unawaited(_handleLocalNotificationInBackground(response));
}

Future<void> _handleLocalNotificationInBackground(
  NotificationResponse response,
) async {
  if (response.actionId != 'decline_call') {
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await AppPreferences.init();
    if (!di.sl.isRegistered<ApiClient>()) {
      await di.init();
    }

    final payloadText = response.payload;
    if (payloadText == null || payloadText.isEmpty) {
      return;
    }

    final payload = jsonDecode(payloadText) as Map<String, dynamic>;
    final callPayload = IncomingCallPayload.fromMap(payload);
    await _declineCallDirectly(callPayload);
    await _cancelBackgroundNotification(response, callPayload);
  } catch (e) {
    log('Failed to handle background call action: $e');
  }
}

Set<int> _pendingDeclinedCallIds() {
  final saved = AppPreferences().getString(_pendingDeclinedCallsKey);
  if (saved == null || saved.isEmpty) {
    return <int>{};
  }

  try {
    final decoded = jsonDecode(saved);
    if (decoded is List) {
      return decoded
          .map((id) => int.tryParse(id.toString()) ?? 0)
          .where((id) => id > 0)
          .toSet();
    }
  } catch (_) {}
  return <int>{};
}

Future<void> _savePendingDeclinedCallIds(Set<int> ids) async {
  await AppPreferences().setString(
    _pendingDeclinedCallsKey,
    jsonEncode(ids.toList()),
  );
}

Future<void> _queuePendingDecline(int callId) async {
  if (callId <= 0) {
    return;
  }
  final pending = _pendingDeclinedCallIds()..add(callId);
  await _savePendingDeclinedCallIds(pending);
}

Future<void> _removePendingDecline(int callId) async {
  final pending = _pendingDeclinedCallIds();
  if (pending.remove(callId)) {
    await _savePendingDeclinedCallIds(pending);
  }
}

Future<bool> _declineCallById(int callId) async {
  try {
    if (callId <= 0) {
      log('Incoming call decline skipped: missing call_id');
      return false;
    }

    if (AppPreferences().isProvider) {
      await di.sl<LawyerChatRepository>().updateCallStatus(callId, 'declined');
    } else {
      await di.sl<ChatRepository>().updateCallStatus(callId, 'declined');
    }
    await _removePendingDecline(callId);
    log('Incoming call declined: $callId');
    return true;
  } catch (e) {
    await _queuePendingDecline(callId);
    log('Incoming call decline API failed: $e');
    return false;
  }
}

Future<bool> _declineCallDirectly(IncomingCallPayload payload) {
  return _declineCallById(payload.callId);
}

Future<void> _retryPendingCallDeclines() async {
  if (!AppPreferences().isLoggedIn) {
    return;
  }

  final pending = _pendingDeclinedCallIds().toList();
  for (final callId in pending) {
    await _declineCallById(callId);
  }
}

Future<void> _cancelBackgroundNotification(
  NotificationResponse response,
  IncomingCallPayload payload,
) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('ic_stat_hoga_dark'),
  );
  await plugin.initialize(settings: settings);

  await _cancelCallNotificationCandidates(
    plugin: plugin,
    responseId: response.id,
    payload: payload,
  );
}

Future<void> _cancelCallNotificationCandidates({
  required FlutterLocalNotificationsPlugin plugin,
  required int? responseId,
  required IncomingCallPayload payload,
}) async {
  final ids = <int>{...payload.notificationIds};
  if (responseId != null) {
    ids.add(responseId);
  }

  for (final id in ids) {
    await plugin.cancel(id: id);
    for (final tag in payload.notificationTags) {
      await plugin.cancel(id: id, tag: tag);
    }
  }
}

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();
  static const String incomingCallChannelId = 'incoming_call_channel_v6';

  /// Must be registered before [runApp].
  static bool _backgroundHandlerRegistered = false;

  static void registerBackgroundHandler() {
    if (_backgroundHandlerRegistered) {
      return;
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _backgroundHandlerRegistered = true;
  }

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<Map<String, dynamic>> _foregroundDataController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundMessagesSub;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSub;
  bool _isInitialized = false;

  Stream<Map<String, dynamic>> get foregroundMessages =>
      _foregroundDataController.stream;

  /// Currently open chat room ID (null when not in a chat room).
  /// Used to suppress annoying heads-up notifications while the user is actively viewing the conversation.
  int? activeChatRoomId;

  int? extractChatRoomId(Map<String, dynamic> data) {
    int? parseVal(dynamic val) {
      if (val == null) return null;
      if (val is int && val > 0) return val;
      final parsed = int.tryParse(val.toString());
      if (parsed != null && parsed > 0) return parsed;
      return null;
    }

    final direct = parseVal(data['chat_room_id']) ??
        parseVal(data['chatRoomId']) ??
        parseVal(data['room_id']) ??
        parseVal(data['roomId']) ??
        parseVal(data['chat_id']) ??
        parseVal(data['chatId']);
    if (direct != null) return direct;

    final channelName =
        data['channel_name']?.toString() ?? data['channel']?.toString();
    if (channelName != null && channelName.isNotEmpty) {
      final match = RegExp(
        r'(?:chat_room_|chat\.|private-chat\.)(\d+)',
      ).firstMatch(channelName);
      final fromChannel = int.tryParse(match?.group(1) ?? '');
      if (fromChannel != null && fromChannel > 0) return fromChannel;
    }

    for (final key in ['data', 'payload']) {
      final nested = data[key];
      if (nested is Map<String, dynamic>) {
        final nestedId = extractChatRoomId(nested);
        if (nestedId != null) return nestedId;
      } else if (nested is String && nested.isNotEmpty) {
        try {
          final decoded = jsonDecode(nested);
          if (decoded is Map<String, dynamic>) {
            final nestedId = extractChatRoomId(decoded);
            if (nestedId != null) return nestedId;
          }
        } catch (_) {}
      }
    }

    return null;
  }

  bool isMessageForActiveChatRoom(Map<String, dynamic> data) {
    final currentActive = activeChatRoomId;
    if (currentActive == null || currentActive <= 0) return false;
    final roomId = extractChatRoomId(data);
    if (roomId == null || roomId <= 0) return false;
    return roomId == currentActive;
  }

  // NOTE: Channel ID is versioned - bump version when changing importance/sound
  // to force Android to recreate it because Android caches channel settings.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel_v4',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    enableVibration: true,
    enableLights: true,
    playSound: true,
  );

  static const AndroidNotificationChannel _incomingCallChannel =
      AndroidNotificationChannel(
        incomingCallChannelId,
        'Incoming Call Notifications',
        description: 'This channel is used for incoming call notifications.',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('incoming_call'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      );

  static const List<AndroidNotificationAction> _incomingCallActions = [
    AndroidNotificationAction(
      'decline_call',
      'رفض',
      titleColor: Color(0xFFE53935),
      showsUserInterface: false,
      cancelNotification: true,
      semanticAction: SemanticAction.delete,
    ),
    AndroidNotificationAction(
      'accept_call',
      'رد',
      titleColor: Color(0xFF1DB954),
      showsUserInterface: true,
      cancelNotification: true,
      semanticAction: SemanticAction.call,
    ),
  ];

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      log('FCM initialize skipped: Firebase is not ready');
      return;
    }

    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else {
      log('User declined or has not accepted notification permission');
    }

    await _configureLocalNotifications();
    await _retryPendingCallDeclines();
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    if (!_backgroundHandlerRegistered) {
      registerBackgroundHandler();
    }

    _foregroundMessagesSub ??= FirebaseMessaging.onMessage.listen((message) {
      log('Got a message whilst in the foreground!');
      final data = Map<String, dynamic>.from(message.data);
      log('Message data: $data');
      log('Message notification: ${message.notification}');
      _foregroundDataController.add(data);

      if (_isCallType(data['type']?.toString())) {
        unawaited(CallCoordinator.instance.handleRemotePayload(data));
        return;
      }

      if (isMessageForActiveChatRoom(data)) {
        log('Foreground chat notification suppressed: user is viewing chat room $activeChatRoomId');
        return;
      }

      if (message.notification != null) {
        unawaited(showLocalNotification(message));
      } else {
        unawaited(_showFromDataPayload(data));
      }
    });

    _messageOpenedAppSub ??= FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      log('Notification clicked from background state');
      unawaited(_handleNotificationNavigation(message.data));
    });

    final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log('App opened from terminated state via notification');
      await _handleNotificationNavigation(initialMessage.data);
    }

    _isInitialized = true;
  }

  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_hoga_dark');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        unawaited(_handleLocalNotificationResponse(response));
      },
      onDidReceiveBackgroundNotificationResponse:
          _localNotificationBackgroundHandler,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_incomingCallChannel);
    }
  }

  Future<void> _handleLocalNotificationResponse(
    NotificationResponse response,
  ) async {
    log(
      'Local notification clicked: ${response.payload} actionId=${response.actionId}',
    );

    final payloadText = response.payload;
    if (payloadText == null || payloadText.isEmpty) {
      _openNotificationsInbox();
      return;
    }

    try {
      final payload = jsonDecode(payloadText) as Map<String, dynamic>;

      if (response.actionId == 'accept_call') {
        final callPayload = IncomingCallPayload.fromMap(payload);
        await _cancelCallNotification(response.id, callPayload);
        await CallCoordinator.instance.acceptIncomingCall(callPayload);
        return;
      }

      if (response.actionId == 'decline_call') {
        final callPayload = IncomingCallPayload.fromMap(payload);
        await _cancelCallNotification(response.id, callPayload);
        await _declineCallDirectly(callPayload);
        CallCoordinator.instance.dismissIncomingCall(callPayload.callId);
        return;
      }

      await _handleNotificationNavigation(payload);
    } catch (e) {
      log('Failed to handle local notification response: $e');
      _openNotificationsInbox();
    }
  }

  Future<void> _cancelCallNotification(
    int? responseId,
    IncomingCallPayload payload,
  ) async {
    await _cancelCallNotificationCandidates(
      plugin: _localNotificationsPlugin,
      responseId: responseId,
      payload: payload,
    );
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    if (isMessageForActiveChatRoom(message.data)) {
      log('showLocalNotification suppressed for active chat room $activeChatRoomId');
      return;
    }
    final notification = message.notification;
    final title = _resolveNotificationTitle(
      message.data,
      notification?.title ??
          message.data['title']?.toString() ??
          message.data['body']?.toString() ??
          '',
    );
    final body =
        notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';

    await _showLocalNotificationFromData(
      data: message.data,
      title: title,
      body: body,
      smallIcon: notification?.android?.smallIcon ?? 'ic_stat_hoga_dark',
    );
  }

  Future<void> _showFromDataPayload(Map<String, dynamic> data) {
    if (isMessageForActiveChatRoom(data)) {
      log('_showFromDataPayload suppressed for active chat room $activeChatRoomId');
      return Future.value();
    }
    final title = _resolveNotificationTitle(
      data,
      data['title']?.toString() ?? data['body']?.toString() ?? '',
    );
    final body = data['body']?.toString() ?? data['message']?.toString() ?? '';

    return _showLocalNotificationFromData(
      data: data,
      title: title,
      body: body,
      smallIcon: 'ic_stat_hoga_dark',
    );
  }

  Future<void> _showLocalNotificationFromData({
    required Map<String, dynamic> data,
    required String title,
    required String body,
    required String smallIcon,
  }) async {
    if (isMessageForActiveChatRoom(data)) {
      log('_showLocalNotificationFromData suppressed for active chat room $activeChatRoomId');
      return;
    }
    if (title.isEmpty && body.isEmpty) {
      return;
    }

    final isIncomingCall = _isCallType(data['type']?.toString());
    final callPayload = isIncomingCall
        ? IncomingCallPayload.fromMap(data)
        : null;
    final notificationId = callPayload?.notificationId ?? data.hashCode;

    await _localNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          isIncomingCall ? _incomingCallChannel.id : _channel.id,
          isIncomingCall ? _incomingCallChannel.name : _channel.name,
          channelDescription: isIncomingCall
              ? _incomingCallChannel.description
              : _channel.description,
          icon: smallIcon,
          importance: Importance.max,
          priority: Priority.high,
          sound: isIncomingCall
              ? const RawResourceAndroidNotificationSound('incoming_call')
              : null,
          audioAttributesUsage: isIncomingCall
              ? AudioAttributesUsage.notificationRingtone
              : AudioAttributesUsage.notification,
          playSound: true,
          enableVibration: true,
          vibrationPattern: isIncomingCall
              ? Int64List.fromList([0, 1000, 500, 1000, 500, 1000])
              : Int64List.fromList([0, 250, 250, 250]),
          fullScreenIntent: isIncomingCall,
          category: isIncomingCall ? AndroidNotificationCategory.call : null,
          visibility: NotificationVisibility.public,
          ticker: title,
          ongoing: isIncomingCall,
          autoCancel: !isIncomingCall,
          timeoutAfter: isIncomingCall
              ? IncomingCallPayload.ringingTimeout.inMilliseconds
              : null,
          tag: callPayload?.notificationTag,
          actions: isIncomingCall ? _incomingCallActions : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  Future<String?> getToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }
      // iOS requires an APNs token before FCM can issue a device token.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apns = await _fcm.getAPNSToken();
        if (apns == null) {
          log('APNs token not ready yet');
          return null;
        }
      }
      return await _fcm.getToken();
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  Stream<String> get onTokenRefresh {
    if (Firebase.apps.isEmpty) {
      return const Stream<String>.empty();
    }
    return _fcm.onTokenRefresh;
  }

  bool _isCallType(String? type) {
    return type == 'incoming_call' ||
        type == 'audio_call' ||
        type == 'video_call';
  }

  String _resolveNotificationTitle(Map<String, dynamic> data, String fallback) {
    final type = data['type']?.toString();
    if (type == 'chat_message') {
      final senderName =
          data['sender_name']?.toString() ??
          data['lawyer_name']?.toString() ??
          data['client_name']?.toString() ??
          data['user_name']?.toString() ??
          data['name']?.toString();

      if (senderName != null && senderName.trim().isNotEmpty) {
        return 'رسالة جديدة من ${senderName.trim()}';
      }
    }

    return fallback;
  }

  Future<void> _handleNotificationNavigation(Map<String, dynamic> data) async {
    final navigator = AppNavigator.navigatorKey.currentState;
    if (navigator == null) return;

    final type = data['type']?.toString();

    if (_isCallType(type)) {
      await CallCoordinator.instance.handleRemotePayload(data);
      return;
    }

    final roomId = data['chat_room_id']?.toString() ??
        data['room_id']?.toString() ??
        data['chat_id']?.toString();
    final isChatMessage = type == 'chat_message' ||
        type == 'new_message' ||
        type == 'message' ||
        type == 'chat' ||
        data['action_type'] == 'chat_message' ||
        data['action_type'] == 'new_message' ||
        (roomId != null && !_isCallType(type));

    if (isChatMessage && roomId != null && (int.tryParse(roomId) ?? 0) > 0) {
      final isLawyer = AppPreferences().isLawyer ||
          data['receiver_type'] == 'lawyer' ||
          data['receiver_type'] == 'provider' ||
          data['role'] == 'lawyer' ||
          data['role'] == 'provider';

      navigator.pushNamed(
        isLawyer ? AppRoutes.lawyerChat : AppRoutes.chat,
        arguments: {
          'chatRoomId': int.tryParse(roomId) ?? 0,
          'clientName': data['sender_name']?.toString() ??
              data['user_name']?.toString() ??
              data['client_name']?.toString() ??
              '',
          'lawyerName': data['sender_name']?.toString() ?? '',
          'caseTitle': data['case_title']?.toString() ?? '',
        },
      );
      return;
    }

    if (type == 'order_status' ||
        type == 'legal_case_update' ||
        type == 'payment' ||
        type?.contains('call') == true) {
      final isLawyer = AppPreferences().isLawyer;
      if (isLawyer) {
        navigator.pushNamed(AppRoutes.lawyerMain, arguments: 2);
      } else {
        navigator.pushNamed(AppRoutes.myOrders);
      }
      return;
    }

    _openNotificationsInbox();
  }

  void _openNotificationsInbox() {
    final navigator = AppNavigator.navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamed(AppRoutes.notifications);
    }
  }
}
