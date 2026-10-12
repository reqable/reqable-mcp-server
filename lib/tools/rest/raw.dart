import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/rest/base.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';

void registerRestRawTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.rest)) {
		return;
	}
	final _RestRawService service = _RestRawService(
		client: client,
	);
	server.registerTool(
		'rest_raw_update',
		title: 'Update HTTP Raw API',
		description: 'Update an existing Reqable Raw API using a complete JSON payload.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: kRestRawSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () => service.update(args),
				message: 'Successfully updated the HTTP Raw API.',
			);
		},
	);
}

class _RestRawService {

	final ReqableApiClient client;

	const _RestRawService({
		required this.client,
	});

	Future<void> update(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(
				route: '/rest/raw/update',
				jsonMap: args,
			),
		);
	}

}

const Map<String, JsonSchema> kRestRawProperties = {
  'type': JsonString(
    title: 'API Type',
    description: 'The API type, which must be "raw" for HTTP Raw APIs.',
    enumValues: ['raw'],
  ),
  'name': JsonString(
    title: 'Name',
    description: 'The display name of the HTTP Raw API.',
  ),
  'url': JsonString(
    title: 'URL',
    description: 'The base URL of the HTTP Raw API.',
  ),
  'message': JsonString(
    title: 'HTTP request protocol message, including method, path, headers, and body.',
    description: 'The HTTP protocol message.',
  ),
  'script': kRestHttpScriptSchema,
  'authorization': kRestRequestAuthorizationSchema,
  'documentation': kRestDocumentationSchema,
};

const JsonObject kRestRawSchema = ToolInputSchema(
	title: 'HTTP Raw API Payload',
	description: 'The complete Reqable HTTP Raw object.',
	properties: {
    'id': JsonString(
      title: 'ID',
      description: 'The unique API identifier.',
    ),
    ...kRestRawProperties,
  },
	required: [
		'id',
    'type',
		'name',
		'url',
		'message',
    'script',
		'authorization',
		'documentation',
	],
	additionalProperties: true,
);

const JsonObject kRestRawWithoutIdSchema = ToolInputSchema(
	title: 'HTTP Raw API Payload',
	description: 'The Reqable HTTP Raw object used to create an HTTP Raw API.',
	properties: kRestRawProperties,
	required: [
    'type',
		'name',
		'url',
		'message',
    'script',
		'authorization',
		'documentation',
	],
	additionalProperties: true,
);