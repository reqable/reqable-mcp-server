import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/utils/json.dart';
import 'package:reqable_mcp_server/utils/storage.dart';

const String _kDefaultHost = '127.0.0.1';
const int _kDefaultPort = 9000;

class ReqableMcpConfig {

  final String host;
  final int port;
  final ReqableToolScope scope;

  const ReqableMcpConfig({
    required this.host,
    required this.port,
    required this.scope,
  });

  factory ReqableMcpConfig.fromArgs(List<String> arguments) {
    final ArgParser parser = ArgParser();
    parser.addOption('host', abbr: 'h');
    parser.addOption('port', abbr: 'p');
    parser.addOption(
      'scope', abbr: 's',
      defaultsTo: ReqableToolScope.minimal.name,
      allowed: ReqableToolScope.values.map((scope) => scope.name).toList()
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
    return ReqableMcpConfig(
      host: host,
      port: port,
      scope: ReqableToolScope.values.firstWhere(
        (s) => s.name == scope,
        orElse: () => ReqableToolScope.minimal,
      ),
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