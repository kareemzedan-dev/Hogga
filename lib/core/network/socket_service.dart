import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;
  
  void Function(Map<String, dynamic>)? onMessageReceived;

  void connect(String url, String userId) {
    _socket = IO.io(url, IO.OptionBuilder()
      .setTransports(['websocket']) 
      .disableAutoConnect()  
      .setQuery({'userId': userId})
      .build()
    );
    
    _socket.connect();

    _socket.onConnect((_) {
      print('Socket connected');
    });

    _socket.on('receive_message', (data) {
      if (onMessageReceived != null) {
        onMessageReceived!(data);
      }
    });

    _socket.onDisconnect((_) => print('Socket disconnected'));
  }

  void sendMessage(Map<String, dynamic> messageData) {
    _socket.emit('send_message', messageData);
  }

  void disconnect() {
    _socket.disconnect();
    _socket.dispose();
  }
}
