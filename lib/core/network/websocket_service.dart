import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';

class WebSocketService {
  static Echo? echo;
  static PusherClient? _pusher;

  static void init() {
    if (echo != null) return;

    final token = AppPreferences().token;

    PusherOptions options = PusherOptions(
      host: 'hogga.wingital.com',
      wsPort: 443,
      wssPort: 443,
      encrypted: true,
      auth: PusherAuth(
        'https://hogga.wingital.com/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    _pusher = PusherClient(
      'vfgfv6bvtvd5xmi0c6za',
      options,
      autoConnect: false,
      enableLogging: true,
    );

    echo = Echo(
      broadcaster: EchoBroadcasterType.Pusher,
      client: _pusher,
    );

    _pusher!.connect();
  }

  static void dispose() {
    _pusher?.disconnect();
    echo = null;
    _pusher = null;
  }
}
