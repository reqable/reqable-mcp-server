import 'dart:io';
import 'dart:math';

class CommandWebSocket {

  final String host;
  final int port;

  int _reconnectAttempts = 0;

  CommandWebSocket(this.host, this.port);

  void connect() {
    // // Only on Windows, we need websocket to receive commands from Reqable.
    if (!Platform.isWindows) {
      return;
    }
    // Only for localhost
    if (host != 'localhost' && host != '127.0.0.1' && host != '::1') {
      return;
    }
    _connect();
  }

  void _connect() {
    WebSocket.connect(
      'ws://$host:$port/mcp',
    ).then((WebSocket socket) {
      _reconnectAttempts = 0;
      socket.pingInterval = const Duration(seconds: 30);
      socket.listen(
        (dynamic message) {
          if (message == 'shutdown') {
            exit(0);
          }
        },
        onDone: _reconnect,
        onError: (error) {
          _reconnect();
        },
      );
    }).catchError((error) {
      _reconnect();
    });
  }

  void _reconnect() {
    _reconnectAttempts++;
    // Reconnect after a delay
    Future.delayed(Duration(seconds: min(30 * _reconnectAttempts, 300)), _connect);
  }

}