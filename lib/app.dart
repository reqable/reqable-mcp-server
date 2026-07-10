import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/resources/script.dart';
import 'package:reqable_mcp_server/tools/capture/breakpoint.dart';
import 'package:reqable_mcp_server/tools/capture/access_control.dart';
import 'package:reqable_mcp_server/tools/capture/gateway.dart';
import 'package:reqable_mcp_server/config.dart';
import 'package:reqable_mcp_server/tools/capture/live.dart';
import 'package:reqable_mcp_server/tools/capture/mirror.dart';
import 'package:reqable_mcp_server/tools/capture/network_throttling.dart';
import 'package:reqable_mcp_server/tools/capture/report_server.dart';
import 'package:reqable_mcp_server/tools/capture/reverse_proxy.dart';
import 'package:reqable_mcp_server/tools/capture/secondary_proxy.dart';
import 'package:reqable_mcp_server/tools/capture/ssl_proxying.dart';
import 'package:reqable_mcp_server/tools/capture/rewrite.dart';
import 'package:reqable_mcp_server/tools/capture/script.dart';
import 'package:reqable_mcp_server/tools/collection/collection.dart';
import 'package:reqable_mcp_server/tools/environment/environment.dart';
import 'package:reqable_mcp_server/tools/proxy/proxy.dart';
import 'package:reqable_mcp_server/tools/rest/http.dart';
import 'package:reqable_mcp_server/tools/rest/websocket.dart';
import 'package:reqable_mcp_server/tools/script.dart';
import 'package:reqable_mcp_server/version.g.dart';

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
    registerCaptureLiveTools(server, apiClient, config.scope);
    registerCaptureMirrorTools(server, apiClient, config.scope);
    registerCaptureGatewayTools(server, apiClient, config.scope);
    registerCaptureBreakpointTools(server, apiClient, config.scope);
    registerCaptureRewriteTools(server, apiClient, config.scope);
    registerCaptureScriptTools(server, apiClient, config.scope);
    registerCaptureAccessControlTools(server, apiClient, config.scope);
    registerCaptureNetworkThrottlingTools(server, apiClient, config.scope);
    registerCaptureReportServerTools(server, apiClient, config.scope);
    registerCaptureReverseProxyTools(server, apiClient, config.scope);
    registerCaptureSecondaryProxyTools(server, apiClient, config.scope);
    registerCaptureSSLProxyingTools(server, apiClient, config.scope);
    registerCollectionTools(server, apiClient, config.scope);
    registerEnvironmentTools(server, apiClient, config.scope);
    registerRestHttpTools(server, apiClient, config.scope);
    registerRestWebsocketTools(server, apiClient, config.scope);
    registerScriptTools(server, apiClient);
    registerProxyTools(server, apiClient);
    // Register resources here.
    registerScriptResources(server, apiClient);
    return server;
  }

}