import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/rest/base.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerRestHttpTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.rest)) {
		return;
	}
	final _RestHttpService service = _RestHttpService(
		client: client,
	);
	server.registerTool(
		'rest_http_create_from_url',
		title: 'Create HTTP API From URL',
		description: 'Create a new Reqable HTTP API tab from a URL and a display name.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the HTTP API name and the target URL.',
			properties: {
				'name': JsonString(
					title: 'Name',
					description: 'The display name for the new HTTP API tab.',
				),
				'url': JsonString(
					title: 'URL',
					description: 'The request URL used to initialize the HTTP API.',
				),
			},
			required: ['name', 'url'],
		),
		outputSchema: kRestHttpSchema,
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
					return 'Successfully created the HTTP API from URL.';
				},
			);
		},
	);
	server.registerTool(
		'rest_http_create_from_curl',
		title: 'Create HTTP API From cURL',
		description: 'Create a new Reqable HTTP API tab from a cURL command and a display name.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the HTTP API name and a cURL command.',
			properties: {
				'name': JsonString(
					title: 'Name',
					description: 'The display name for the new HTTP API tab.',
				),
				'curl': JsonString(
					title: 'cURL Command',
					description: 'The cURL command used to initialize the HTTP API.',
				),
			},
			required: ['name', 'curl'],
		),
		outputSchema: kRestHttpSchema,
		callback: (args, extra) {
			final CallToolResult? nameError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (nameError != null) {
				return nameError;
			}
			final CallToolResult? curlError = validateRequiredStringArgument(
				args,
				key: 'curl',
			);
			if (curlError != null) {
				return curlError;
			}
			return buildContentResult(
				apiCall: () => service.createFromCurl(args),
				contentBuilder: (_) {
					return 'Successfully created the HTTP API from cURL.';
				},
			);
		},
	);
	server.registerTool(
		'rest_http_update',
		title: 'Update HTTP API',
		description: 'Update an existing Reqable HTTP API using a complete JSON payload.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: kRestHttpSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () => service.update(args),
				message: 'Successfully updated the HTTP API.',
			);
		},
	);
}

class _RestHttpService {

	final ReqableApiClient client;

	const _RestHttpService({
		required this.client,
	});

	Future<String> createFromUrl(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/rest/http/create/from-url',
				jsonMap: args,
			),
		);
	}

	Future<String> createFromCurl(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/rest/http/create/from-curl',
				jsonMap: args,
			),
		);
	}

	Future<void> update(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(
				route: '/rest/http/update',
				jsonMap: args,
			),
		);
	}

}

const JsonObject kRestHttpSchema = ToolInputSchema(
	title: 'HTTP API Payload',
	description: 'The complete Reqable RestHttp object used to create or update an HTTP API tab.',
	properties: {
		'id': JsonString(
			title: 'ID',
			description: 'The unique API identifier.',
		),
    'type': JsonString(
      title: 'API Type',
      description: 'The API type, which must be "api" for HTTP APIs.',
      enumValues: ['api'],
    ),
		'name': JsonString(
			title: 'Name',
			description: 'The display name of the HTTP API.',
		),
		'method': JsonString(
			title: 'HTTP Method',
			description: 'The HTTP request method.',
		),
		'url': _kRestRequestUrlSchema,
		'headers': JsonArray(
			title: 'Headers',
			description: 'The HTTP request headers, including optional internal headers.',
			items: _kRestRequestHeaderSchema,
		),
		'body': _kRestHttpRequestBodySchema,
		'script': kRestHttpScriptSchema,
		'authorization': kRestRequestAuthorizationSchema,
		'documentation': kRestDocumentationSchema,
	},
	required: [
		'id',
    'type',
		'name',
		'method',
		'url',
		'headers',
		'body',
		'script',
		'authorization',
		'documentation',
	],
	additionalProperties: true,
);

const JsonObject _kRestRequestHeaderSchema = JsonObject(
	title: 'Request Header',
	description: 'A request header entry, optionally marked as internal.',
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

const JsonObject _kRestRequestUrlSchema = JsonObject(
	title: 'Request URL',
	description: 'The structured request URL used by Reqable.',
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
			items: kSelectableStringEntrySchema,
		),
	},
	required: ['base'],
	additionalProperties: true,
);

const JsonOneOf _kRestHttpRequestBodySchema = JsonOneOf(
	[
		_kRestHttpRequestBodyNoneSchema,
		_kRestHttpRequestBodyTextSchema,
		_kRestHttpRequestBodyJsonSchema,
		_kRestHttpRequestBodyXmlSchema,
		_kRestHttpRequestBodyRawSchema,
		_kRestHttpRequestBodyMultipartSchema,
		_kRestHttpRequestBodyUrlencodeSchema,
		_kRestHttpRequestBodyBinarySchema,
	],
	title: 'HTTP Request Body',
	description: 'The request body, expressed in exactly one body mode.',
);

const JsonObject _kRestHttpRequestBodyNoneSchema = JsonObject(
	title: 'No Body',
	description: 'A request body with no payload.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['none'],
		),
	},
	required: ['mode'],
);

const JsonObject _kRestHttpRequestBodyTextSchema = JsonObject(
	title: 'Text Body',
	description: 'A plain text request body.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['text'],
		),
		'text': JsonString(
			title: 'Text',
			description: 'The plain text payload.',
		),
	},
	required: ['mode', 'text'],
);

const JsonObject _kRestHttpRequestBodyJsonSchema = JsonObject(
	title: 'JSON Body',
	description: 'A JSON request body stored as text.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['json'],
		),
		'text': JsonString(
			title: 'JSON Text',
			description: 'The JSON payload text.',
		),
	},
	required: ['mode', 'text'],
);

const JsonObject _kRestHttpRequestBodyXmlSchema = JsonObject(
	title: 'XML Body',
	description: 'An XML request body stored as text.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['xml'],
		),
		'text': JsonString(
			title: 'XML Text',
			description: 'The XML payload text.',
		),
	},
	required: ['mode', 'text'],
);

const JsonObject _kRestHttpRequestBodyRawSchema = JsonObject(
	title: 'Raw Body',
	description: 'A raw request body stored as text.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['raw'],
		),
		'text': JsonString(
			title: 'Raw Text',
			description: 'The raw payload text.',
		),
	},
	required: ['mode', 'text'],
);

const JsonObject _kRestHttpRequestBodyMultipartSchema = JsonObject(
	title: 'Multipart Body',
	description: 'A multipart form request body.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['multipart'],
		),
		'multiparts': JsonArray(
			title: 'Multipart Parts',
			description: 'The multipart payload entries.',
			items: _kRestHttpRequestBodyMultipartItemSchema,
		),
	},
	required: ['mode', 'multiparts'],
);

const JsonObject _kRestHttpRequestBodyMultipartItemSchema = JsonObject(
	title: 'Multipart Item',
	description: 'A single multipart form item.',
	properties: {
		'type': JsonInteger(
			title: 'Multipart Type',
			description: 'The multipart type index: 0 text, 1 multiline, 2 file.',
			minimum: 0,
			maximum: 2,
		),
		'name': JsonString(
			title: 'Part Name',
			description: 'The multipart field name.',
		),
		'payload': JsonString(
			title: 'Payload',
			description: 'The part payload text or file path.',
		),
		'headers': JsonArray(
			title: 'Part Headers',
			description: 'The multipart part headers.',
			items: kSelectableStringEntrySchema,
		),
		'themeType': JsonInteger(
			title: 'Theme Type',
			description: 'The editor theme type index used for multiline text parts.',
			minimum: 0,
		),
		'disabled': JsonBoolean(
			title: 'Disabled',
			description: 'Whether this multipart item is disabled.',
		),
	},
	required: ['type', 'name', 'payload', 'themeType', 'disabled'],
	additionalProperties: true,
);

const JsonObject _kRestHttpRequestBodyUrlencodeSchema = JsonObject(
	title: 'URL Encoded Body',
	description: 'An application/x-www-form-urlencoded request body.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['urlencode'],
		),
		'urlencodes': JsonArray(
			title: 'URL Encoded Entries',
			description: 'The URL encoded form entries.',
			items: kSelectableStringEntrySchema,
		),
	},
	required: ['mode', 'urlencodes'],
);

const JsonObject _kRestHttpRequestBodyBinarySchema = JsonObject(
	title: 'Binary Body',
	description: 'A binary request body loaded from a file path.',
	properties: {
		'mode': JsonString(
			title: 'Body Mode',
			description: 'The request body mode.',
			enumValues: ['binary'],
		),
		'path': JsonString(
			title: 'File Path',
			description: 'The local file path for the binary body payload.',
		),
	},
	required: ['mode', 'path'],
);