import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';

void registerTabTools(McpServer server, ReqableApiClient client) {
  final _TabService service = _TabService(
    client: client,
  );
  server.registerTool(
    'tab_list',
    title: 'List Tabs',
    description: 'List all open Reqable tabs, including their IDs, types, and display names.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: ToolOutputSchema(
      title: 'Tab List',
      description: 'The open tabs returned by Reqable.',
      properties: {
        'tabs': JsonArray(
          title: 'Tabs',
          description: 'The list of open Reqable tabs.',
          items: JsonObject(
            title: 'Tab',
            description: 'An open Reqable tab.',
            properties: {
              'id': JsonString(
                title: 'Tab ID',
                description: 'The unique tab identifier.',
              ),
              'type': JsonString(
                title: 'Tab Type',
                description: 'The exact WorkType enum name, serialized as a case-sensitive string. '
                  'captureLive: live traffic capture; '
                  'captureTemporarySession: a temporary capture session; '
                  'captureReviewFile: a capture file, such as a HAR/Charles file; '
                  'captureReviewHistory: capture history; '
                  'captureReviewFavorite: capture favorite; '
                  'apiCollection: an API collection; '
                  'apiFolder: an API collection folder; '
                  'apiHttp: an HTTP API; '
                  'apiRaw: a raw API; '
                  'apiWebsocket: a WebSocket API; '
                  'apiGrpc: a gRPC API; '
                  'environment: environment variable; '
                  'collaborativeDevice: a collaborative device; '
                  'specFile: an API specification file. ',
                enumValues: [
                  'captureLive',
                  'captureTemporarySession',
                  'captureReviewFile',
                  'captureReviewHistory',
                  'captureReviewFavorite',
                  'apiCollection',
                  'apiFolder',
                  'apiHttp',
                  'apiRaw',
                  'apiWebsocket',
                  'apiGrpc',
                  'environment',
                  'collaborativeDevice',
                  'specFile',
                ],
              ),
              'name': JsonString(
                title: 'Tab Name',
                description: 'The display name of the tab.',
              ),
            },
            required: ['id', 'type', 'name'],
          ),
        ),
      },
      required: ['tabs'],
    ),
    callback: (args, extra) {
      return buildContentResult(
        apiCall: service.listTabs,
      );
    },
  );
}

class _TabService {

  final ReqableApiClient client;

  const _TabService({
    required this.client,
  });

  Future<String> listTabs() {
    return client.sendGetRequest(
      const VoidRequest(
        route: '/tab/list',
      ),
    );
  }

}