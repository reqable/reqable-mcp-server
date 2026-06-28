import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp/api/client.dart';
import 'package:reqable_mcp/resources/script.dart';
import 'package:reqable_mcp/tools/capture/breakpoint.dart';
import 'package:reqable_mcp/tools/capture/access_control.dart';
import 'package:reqable_mcp/tools/capture/gateway.dart';
import 'package:reqable_mcp/config.dart';
import 'package:reqable_mcp/tools/capture/live.dart';
import 'package:reqable_mcp/tools/capture/mirror.dart';
import 'package:reqable_mcp/tools/capture/network_throttling.dart';
import 'package:reqable_mcp/tools/capture/report_server.dart';
import 'package:reqable_mcp/tools/capture/reverse_proxy.dart';
import 'package:reqable_mcp/tools/capture/secondary_proxy.dart';
import 'package:reqable_mcp/tools/capture/ssl_proxying.dart';
import 'package:reqable_mcp/tools/capture/rewrite.dart';
import 'package:reqable_mcp/tools/capture/script.dart';
import 'package:reqable_mcp/tools/collection/collection.dart';
import 'package:reqable_mcp/tools/environment/environment.dart';
import 'package:reqable_mcp/tools/rest/http.dart';
import 'package:reqable_mcp/tools/rest/websocket.dart';
import 'package:reqable_mcp/tools/script.dart';
import 'package:reqable_mcp/version.g.dart';

class Application {

  final ReqableMcpConfig config;

  const Application({
    required this.config,
  });

  factory Application.createFromArgs( List<String> arguments) {
    return Application(
      config: ReqableMcpConfig.fromArgs(arguments),
    );
  }

  McpServer createServer() {
    final McpServer server = McpServer(
      const Implementation(
        name: 'reqable-mcp',
        version: kVersionName,
      ),
      options: McpServerOptions(
        capabilities: const ServerCapabilities(
          tools: ServerCapabilitiesTools(),
          resources: ServerCapabilitiesResources(),
        ),
        instructions: 'Reqable MCP server exposing operations over Reqable APIs.',
      ),
    );
    server.onError = (error) {
      stderr.writeln(error);
    };
    final ReqableApiClient apiClient = ReqableApiClient(
      host: config.host,
      port: config.port,
    );
    // Register tools here.
    registerScriptTools(server, apiClient);
    registerCaptureLiveTools(server, apiClient);
    registerCaptureMirrorTools(server, apiClient);
    registerCaptureGatewayTools(server, apiClient);
    registerCaptureBreakpointTools(server, apiClient);
    registerCaptureRewriteTools(server, apiClient);
    registerCaptureScriptTools(server, apiClient);
    registerCaptureAccessControlTools(server, apiClient);
    registerCaptureNetworkThrottlingTools(server, apiClient);
    registerCaptureReportServerTools(server, apiClient);
    registerCaptureReverseProxyTools(server, apiClient);
    registerCaptureSecondaryProxyTools(server, apiClient);
    registerCaptureSSLProxyingTools(server, apiClient);
    registerEnvironmentTools(server, apiClient);
    registerRestCollectionTools(server, apiClient);
    registerRestHttpTools(server, apiClient);
    registerRestWebsocketTools(server, apiClient);
    // Register resources here.
    registerScriptResources(server, apiClient);
    return server;
  }

}