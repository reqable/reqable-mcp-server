import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/rest/base.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerRestWebsocketTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.rest)) {
		return;
	}
	final _RestWebsocketService service = _RestWebsocketService(
		client: client,
	);
	server.registerTool(
		'rest_websocket_create_from_url',
		title: 'Create WebSocket API From URL',
		description: 'Create a new Reqable WebSocket API tab from a URL and a display name.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the WebSocket API name and the target URL.',
			properties: {
				'name': JsonString(
					title: 'Name',
					description: 'The display name for the new WebSocket API tab.',
				),
				'url': JsonString(
					title: 'URL',
					description: 'The request URL used to initialize the WebSocket API.',
				),
			},
			required: ['name', 'url'],
		),
		outputSchema: kRestWebSocketSchema,
		callback: (args, extra) {
			final CallToolResult? nameError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (nameError != null) {
				return nameError;
			}
			final CallToolResult? urlError = validateRequiredStringArgument(
				args,
				key: 'url',
			);
			if (urlError != null) {
				return urlError;
			}
			return buildContentResult(
				apiCall: () => service.createFromUrl(args),
				contentBuilder: (_) {
					return 'Successfully created the WebSocket API from URL.';
				},
			);
		},
	);
	server.registerTool(
		'rest_websocket_update',
		title: 'Update WebSocket API',
		description: 'Update an existing Reqable WebSocket API using a complete JSON payload.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: kRestWebSocketSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () => service.update(args),
				message: 'Successfully updated the WebSocket API.',
			);
		},
	);
}

class _RestWebsocketService {

	final ReqableApiClient client;

	const _RestWebsocketService({
		required this.client,
	});

	Future<String> createFromUrl(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/rest/websocket/create/from-url',
				jsonMap: args,
			),
		);
	}

	Future<void> update(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(
				route: '/rest/websocket/update',
				jsonMap: args,
			),
		);
	}

}

const JsonObject kRestWebSocketSchema = ToolInputSchema(
	title: 'WebSocket API Payload',
	description: 'The complete Reqable RestWebSocket object used to create or update a WebSocket API tab.',
	properties: {
		'id': JsonString(
			title: 'ID',
			description: 'The unique WebSocket API identifier.',
		),
    'type': JsonString(
      title: 'API Type',
      description: 'The API type, which must be "websocket" for WebSocket APIs.',
      enumValues: ['websocket'],
    ),
		'name': JsonString(
			title: 'Name',
			description: 'The display name of the WebSocket API.',
		),
		'url': _kRestWebSocketRequestUrlSchema,
		'headers': JsonArray(
			title: 'Headers',
			description: 'The WebSocket handshake request headers, including optional internal headers.',
			items: _kRestWebSocketHeaderSchema,
		),
		'sendType': JsonString(
			title: 'Default Send Type',
			description: 'The default message editor mode used when sending WebSocket messages.',
			enumValues: ['text', 'json', 'xml', 'binaryBase64', 'binaryHex', 'binaryFile'],
		),
		'documentation': kRestDocumentationSchema,
	},
	required: [
		'id',
    'type',
		'name',
		'url',
		'headers',
		'sendType',
		'documentation',
	],
	additionalProperties: true,
);

const JsonObject _kRestWebSocketSelectableStringEntrySchema = JsonObject(
	title: 'Selectable String Entry',
	description: 'A key-value entry with an optional disabled flag.',
	properties: {
		'key': JsonString(
			title: 'Key',
			description: 'The entry key.',
		),
		'value': JsonString(
			title: 'Value',
			description: 'The entry value.',
		),
		'disabled': JsonBoolean(
			title: 'Disabled',
			description: 'Whether this entry is disabled.',
		),
	},
	required: ['key', 'value'],
);

const JsonObject _kRestWebSocketHeaderSchema = JsonObject(
	title: 'WebSocket Header',
	description: 'A WebSocket handshake request header entry.',
	properties: {
		'key': JsonString(
			title: 'Header Name',
			description: 'The request header name.',
		),
		'value': JsonString(
			title: 'Header Value',
			description: 'The request header value.',
		),
		'disabled': JsonBoolean(
			title: 'Disabled',
			description: 'Whether this header is disabled.',
		),
		'internal': JsonBoolean(
			title: 'Internal',
			description: 'Whether this is an internal Reqable-managed header.',
		),
	},
	required: ['key', 'value'],
);

const JsonObject _kRestWebSocketRequestUrlSchema = JsonObject(
	title: 'Request URL',
	description: 'The structured WebSocket request URL used by Reqable.',
	properties: {
		'base': JsonString(
			title: 'Base URL',
			description: 'The base URL without query string or fragment.',
		),
		'fragment': JsonString(
			title: 'Fragment',
			description: 'The URL fragment without the leading hash.',
		),
		'query': JsonArray(
			title: 'Query Entries',
			description: 'The request query parameters.',
			items: _kRestWebSocketSelectableStringEntrySchema,
		),
	},
	required: ['base'],
	additionalProperties: true,
);