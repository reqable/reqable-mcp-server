import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp/api/client.dart';
import 'package:reqable_mcp/tools/script.dart';

void registerScriptResources(McpServer server, ReqableApiClient client) {
  final ScriptService scriptService = ScriptService(client: client);
  server.registerResource(
    'script_framework',
    'http://${client.host}:${client.port}/script/framework',
    (
      description: 'A Python script framework that provides APIs for writing Reqable scripts.',
      mimeType: 'text/plain',
    ),
    (uri, extra) async {
      return ReadResourceResult(
        contents: [
          TextResourceContents(
            uri: uri.toString(),
            text: await scriptService.getFramework(),
          ),
        ]
      );
    },
  );
  server.registerResource(
    'script_template',
    'http://${client.host}:${client.port}/script/template',
    (
      description: 'A Python script template that provides a starting point for writing Reqable scripts.',
      mimeType: 'text/plain',
    ),
    (uri, extra) async {
      return ReadResourceResult(
        contents: [
          TextResourceContents(
            uri: uri.toString(),
            text: await scriptService.getTemplate(),
          ),
        ]
      );
    },
  );
}