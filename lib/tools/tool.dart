const List<ReqableToolGroup> _kScopeMinimal = [
  ReqableToolGroup.captureLive,
  ReqableToolGroup.captureBreakpoint,
  ReqableToolGroup.captureRewrite,
  ReqableToolGroup.captureScript,
  ReqableToolGroup.collection,
  ReqableToolGroup.rest,
];

const List<ReqableToolGroup> _kScopeAll = ReqableToolGroup.values;

enum ReqableToolGroup {
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

enum ReqableToolScope {
  minimal,
  all,
}

extension ReqableToolScopeExtension on ReqableToolScope {
  List<ReqableToolGroup> get toolGroups {
    switch (this) {
      case ReqableToolScope.minimal:
        return _kScopeMinimal;
      case ReqableToolScope.all:
        return _kScopeAll;
    }
  }
}