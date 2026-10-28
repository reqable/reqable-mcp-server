const List<McpToolGroup> _kScopeMinimal = [
  McpToolGroup.captureLive,
  McpToolGroup.captureBreakpoint,
  McpToolGroup.captureRewrite,
  McpToolGroup.captureScript,
  McpToolGroup.collection,
  McpToolGroup.rest,
];

const List<McpToolGroup> _kScopeAll = McpToolGroup.values;

enum McpToolGroup {
  captureLive,
  captureAccessControl,
  captureBreakpoint,
  captureGateway,
  captureMirror,
  captureRewrite,
  captureScript,
  captureSecondaryProxy,
  captureSSLProxying,
  captureNetworkThrottling,
  captureReportServer,
  captureReverseProxy,
  collection,
  environment,
  rest,
}

enum McpToolScope {
  minimal,
  all,
}

extension McpToolScopeExtension on McpToolScope {
  List<McpToolGroup> get toolGroups {
    switch (this) {
      case McpToolScope.minimal:
        return _kScopeMinimal;
      case McpToolScope.all:
        return _kScopeAll;
    }
  }
}