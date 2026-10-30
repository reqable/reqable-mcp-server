import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/utils/json.dart';
import 'package:reqable_mcp_server/utils/storage.dart';

const String _kDefaultHost = '127.0.0.1';
const int _kDefaultPort = 9000;

class McpServerConfig {

  final String host;
  final int port;
  final String? token;
  final McpToolScope scope;

  const McpServerConfig({
    required this.host,
    required this.port,
    required this.token,
    required this.scope,
  });

  factory McpServerConfig.fromArgs(List<String> arguments) {
    final ArgParser parser = ArgParser();
    parser.addOption('host', abbr: 'h');
    parser.addOption('port', abbr: 'p');
    parser.addOption('token', abbr: 't');
    parser.addOption(
      'scope', abbr: 's',
      defaultsTo: McpToolScope.minimal.name,
      allowed: McpToolScope.values.map((scope) => scope.name).toList()
    );
    final ArgResults argResults = parser.parse(arguments);
    final String host;
    final String? hostArg = argResults.option('host');
    if (hostArg != null) {
      if (hostArg.isEmpty) {
        throw ArgumentError('Host cannot be empty');
      }
      host = hostArg;
    } else {
      host = _kDefaultHost;
    }
    final int port;
    final String? portArg = argResults.option('port');
    if (portArg != null) {
      final int? parsedPort = int.tryParse(portArg);
      if (parsedPort == null) {
        throw ArgumentError('Port must be a valid integer');
      }
      if (parsedPort <= 0 || parsedPort >= 65535) {
        throw ArgumentError('Port must be between 1 and 65534');
      }
      port = parsedPort;
    } else {
      final int? appPort = _resolveAppPort();
      if (appPort != null) {
        port = appPort;
      } else {
        port = _kDefaultPort;
      }
    }
    final String? scope = argResults.option('scope');
    return McpServerConfig(
      host: host,
      port: port,
      scope: McpToolScope.values.firstWhere(
        (s) => s.name == scope,
        orElse: () => McpToolScope.minimal,
      ),
      token: argResults.option('token') ?? Platform.environment['REQABLE_TOKEN'] ?? Platform.environment['ACCESS_TOKEN'],
    );
  }

}

int? _resolveAppPort() {
  final String? configFile = Storage.getFilePath([
    'config',
    'capture_config'
  ]);
  if (configFile == null) {
    return null;
  }
  final File file = File(configFile);
  if (!file.existsSync()) {
    return null;
  }
  return json.tryDecodeFile(configFile)?['proxyPort'];
}