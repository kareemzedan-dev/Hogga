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

Future<void> _declineCallDirectly(IncomingCallPayload payload) async {
  try {
    if (payload.callId <= 0) {
      log('Incoming call decline skipped: missing call_id');
      return;
    }

    if (AppPreferences().isProvider) {
      await di.sl<LawyerChatRepository>().updateCallStatus(
        payload.callId,
        'declined',
      );
    } else {
      await di.sl<ChatRepository>().updateCallStatus(
        payload.callId,
        'declined',
      );
    }
    log('Incoming call declined: ${payload.callId}');
  } catch (e) {
    log('Incoming call decline API failed: $e');
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
  static const String incomingCallChannelId = 'incoming_call_channel_v5';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<Map<String, dynamic>> _foregroundDataController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundMessagesSub;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSub;
  bool _isInitialized = false;

  Stream<Map<String, dynamic>> get foregroundMessages =>
      _foregroundDataController.stream;

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
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _foregroundMessagesSub ??= FirebaseMessaging.onMessage.listen((message) {
      log('Got a message whilst in the foreground!');
      final data = Map<String, dynamic>.from(message.data);
      log('Message data: $data');
      log('Message notification: ${message.notification}');
      _foregroundDataController.add(data);

      if (_isCallType(data['type']?.toString())) {
        unawaited(showLocalNotification(message));
        unawaited(CallCoordinator.instance.handleRemotePayload(data));
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
      return await _fcm.getToken();
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

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

    if (type == 'chat_message') {
      final roomId = data['chat_room_id']?.toString();
      if (roomId != null) {
        final isLawyer = AppPreferences().role == 'lawyer';
        navigator.pushNamed(
          isLawyer ? AppRoutes.lawyerChat : AppRoutes.chat,
          arguments: {
            'chatRoomId': int.tryParse(roomId) ?? 0,
            'lawyerName': '',
            'caseTitle': '',
          },
        );
        return;
      }
    }

    if (type == 'order_status' ||
        type == 'legal_case_update' ||
        type == 'payment' ||
        type?.contains('call') == true) {
      final isLawyer = AppPreferences().role == 'lawyer';
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
