import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/app.dart';
import 'package:reqable_mcp_server/config.dart';

import 'ws/command.dart';

Future<void> main(List<String> arguments) async {
  final StdioApplication app = StdioApplication(arguments);
  final McpServer server = app.createServer();
  await server.connect(StdioServerTransport());
}

class StdioApplication extends Application {

  late final CommandWebSocket _commandSocket;

  StdioApplication(List<String> arguments) : super(McpServerConfig.fromArgs(arguments)) {
    _commandSocket = CommandWebSocket(config.host, config.port);
    _commandSocket.connect();
  }

  @override
  void onInitialized(McpServer server) {
    _commandSocket.implementation = server.server.getClientVersion();
  }

  @override
  void onAlive(McpServer server) {
    _commandSocket.reconnectIfNeeded();
  }

}
