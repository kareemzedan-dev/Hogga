import 'dart:async';
import 'dart:developer';

import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/constants/end_points.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client/pusher_client.dart';

class WebSocketService {
  static const String _pusherKey = 'vfgfv6bvtvd5xmi0c6za';
  static const String _pusherHost = 'hogga.wingital.com';

  static Echo? echo;
  static PusherClient? _pusher;
  static String? _authToken;
  static String _connectionState = '';
  static bool _autoReconnect = false;
  static Timer? _reconnectTimer;
  static final StreamController<String> _connectionStateController =
      StreamController<String>.broadcast();

  static Stream<String> get connectionStates =>
      _connectionStateController.stream;

  static void init({bool forceReconnect = false}) {
    final token = AppPreferences().token;
    if (token == null || token.isEmpty) {
      log('Pusher init skipped: missing auth token');
      return;
    }

    if (forceReconnect || (_authToken != null && _authToken != token)) {
      dispose();
    }

    if (echo != null) {
      _connectIfNeeded('init');
      return;
    }

    _authToken = token;
    _connectionState = '';
    _autoReconnect = true;
    final authEndpoint = '${AppEndPoints.baseUrl}broadcasting/auth';
    log('Pusher auth endpoint: $authEndpoint');

    final options = PusherOptions(
      host: _pusherHost,
      wsPort: 443,
      wssPort: 443,
      encrypted: true,
      auth: PusherAuth(
        authEndpoint,
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    _pusher = PusherClient(
      _pusherKey,
      options,
      autoConnect: false,
      enableLogging: true,
    );

    _pusher!.onConnectionStateChange((state) {
      final currentState = state?.currentState?.toString() ?? '';
      if (currentState.isNotEmpty) {
        _connectionState = currentState.toUpperCase();
        _connectionStateController.add(currentState);
        if (_connectionState == 'CONNECTED') {
          _reconnectTimer?.cancel();
        } else if (_connectionState == 'DISCONNECTED') {
          _scheduleReconnect();
        }
      }
      log('Pusher state changed: $currentState');
    });

    _pusher!.onConnectionError((error) {
      log(
        'Pusher connection error: ${error?.message} | Exception: ${error?.exception}',
      );
    });

    echo = Echo(broadcaster: EchoBroadcasterType.Pusher, client: _pusher);
  }

  static void reconnect() {
    _connectIfNeeded('manual reconnect');
  }

  static void _scheduleReconnect() {
    if (!_autoReconnect || echo == null || _reconnectTimer?.isActive == true) {
      return;
    }

    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      if (_autoReconnect && echo != null) {
        _connectIfNeeded('state disconnected');
      }
    });
  }

  static void _connectIfNeeded(String reason) {
    final pusher = _pusher;
    if (pusher == null) {
      return;
    }

    if (_connectionState == 'CONNECTED' ||
        _connectionState == 'CONNECTING' ||
        _connectionState == 'RECONNECTING') {
      return;
    }

    log(
      'Pusher reconnect requested from $reason; currentState=${_connectionState.isEmpty ? 'unknown' : _connectionState}',
    );
    unawaited(pusher.connect());
  }

  static void dispose() {
    _autoReconnect = false;
    _reconnectTimer?.cancel();
    _pusher?.disconnect();
    echo = null;
    _pusher = null;
    _authToken = null;
    _connectionState = 'DISCONNECTED';
  }
}
