import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/utils/json.dart';

class CommandWebSocket {

  final String host;
  final int port;

  int _reconnectAttempts = 0;
  int _connectionId = 0;
  WebSocket? _socket;
  Implementation? _implementation;

  CommandWebSocket(this.host, this.port);

  void connect() {
    _connect();
  }

  set implementation(Implementation? value) {
    _implementation = value;
    if (value != null) {
      _sendClientConnectMessage(value);
    }
  }

  void reconnectIfNeeded() {
    _reconnectAttempts = 0;
    if (_socket != null) {
      return;
    }
    _connect();
  }

  void _connect() {
    _connectionId++;
    WebSocket.connect(
      'ws://$host:$port/mcp',
    ).then((WebSocket socket) {
      _reconnectAttempts = 0;
      _socket = socket;
      socket.pingInterval = const Duration(seconds: 60);
      socket.listen(
        (dynamic message) {
          final CommandMessage command = CommandMessage.fromMessage(message);
          switch (command.name) {
            case 'shutdown':
              exit(0);
          }
        },
        onDone: () {
          _socket = null;
          _reconnect();
        },
        onError: (error) {
          _socket = null;
          _reconnect();
        },
      );
      final Implementation? implementation = _implementation;
      if (implementation != null) {
        _sendClientConnectMessage(implementation);
      }
    }).catchError((error) {
      _reconnect();
    });
  }

  void _reconnect() {
    _reconnectAttempts++;
    final int connectionId = _connectionId;
    // Reconnect after a delay
    Future.delayed(Duration(seconds: min(30 * _reconnectAttempts, 300)), () {
      if (connectionId != _connectionId) {
        // Drop the cancelled task
        return;
      }
      _connect();
    });
  }

  void _sendClientConnectMessage(Implementation implementation) {
    _socket?.add(json.encode(CommandMessage(
      name: 'connect',
      payload: {
        ...implementation.toJson(),
        'launchAt': DateTime.now().millisecondsSinceEpoch,
      },
    )));
  }

}

class CommandMessage {

  final String name;
  final Map<String, dynamic>? payload;

  const CommandMessage({
    required this.name,
    this.payload
  });

  factory CommandMessage.fromMessage(String message) {
    final Map<String, dynamic>? jsonMap = json.tryDecode(message);
    if (jsonMap == null) {
      return CommandMessage(
        name: message
      );
    }
    final String? name = jsonMap['name'];
    if (name == null || name.isEmpty) {
      return CommandMessage(
        name: message
      );
    }
    return CommandMessage(
      name: name,
      payload: jsonMap['payload'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'payload': payload,
  };

}