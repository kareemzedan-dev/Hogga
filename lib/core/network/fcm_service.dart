import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/calls/call_coordinator.dart';
import 'package:hogga/core/navigation/app_navigator.dart';
import 'package:hogga/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log('Handling a background message: ${message.messageId}');
  await FcmService.instance.showLocalNotification(message);
}

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundMessagesSub;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSub;
  bool _isInitialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel_v2',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    enableVibration: true,
    enableLights: true,
    playSound: true,
  );

  static const AndroidNotificationChannel _incomingCallChannel =
      AndroidNotificationChannel(
    'incoming_call_channel_v2',
    'Incoming Call Notifications',
    description: 'This channel is used for incoming call notifications.',
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('incoming_call'),
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

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

    _foregroundMessagesSub ??=
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.data['type']?.toString() == 'incoming_call') {
        unawaited(CallCoordinator.instance.handleRemotePayload(message.data));
        return;
      }

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        unawaited(showLocalNotification(message));
      }
    });

    _messageOpenedAppSub ??=
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log('Local notification clicked: ${response.payload}');
        if (response.payload == null || response.payload!.isEmpty) {
          _openNotificationsInbox();
          return;
        }

        try {
          final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
          _handleNotificationNavigation(payload);
        } catch (_) {
          _openNotificationsInbox();
        }
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_incomingCallChannel);
    }
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (notification == null) {
      return;
    }

    final isIncomingCall = message.data['type']?.toString() == 'incoming_call';

    await _localNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          isIncomingCall ? _incomingCallChannel.id : _channel.id,
          isIncomingCall ? _incomingCallChannel.name : _channel.name,
          channelDescription: isIncomingCall
              ? _incomingCallChannel.description
              : _channel.description,
          icon: message.notification?.android?.smallIcon ?? 'ic_stat_hoga_dark',
          importance: Importance.max,
          priority: Priority.high,
          sound: isIncomingCall
              ? const RawResourceAndroidNotificationSound('incoming_call')
              : null,
          playSound: true,
          enableVibration: true,
          vibrationPattern: isIncomingCall
              ? Int64List.fromList([0, 1000, 500, 1000, 500, 1000])
              : Int64List.fromList([0, 250, 250, 250]),
          fullScreenIntent: isIncomingCall,
          category: isIncomingCall ? AndroidNotificationCategory.call : null,
          visibility: NotificationVisibility.public,
          ticker: notification.title,
          ongoing: isIncomingCall,
          autoCancel: !isIncomingCall,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
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

  Future<void> _handleNotificationNavigation(Map<String, dynamic> data) async {
    if (data['type']?.toString() == 'incoming_call') {
      await CallCoordinator.instance.handleRemotePayload(data);
      return;
    }

    _openNotificationsInbox();
  }

  void _openNotificationsInbox() {
    final navigator = AppNavigator.navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamed(AppRoutes.notifications);
  }
}
