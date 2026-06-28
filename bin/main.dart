import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp/app.dart';

Future<void> main(List<String> arguments) async {
  final Application application = Application.createFromArgs(arguments);
  final McpServer server = application.createServer();
  await server.connect(StdioServerTransport());
}
