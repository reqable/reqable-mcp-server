import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/collection/collection.dart';
import 'package:reqable_mcp_server/tools/rest/http.dart';
import 'package:reqable_mcp_server/tools/rest/websocket.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureLiveTools(McpServer server, ReqableApiClient client) {
	final _CaptureLiveService service = _CaptureLiveService(
		client: client,
	);
	server.registerTool(
		'capture_live_status',
		title: 'Get Live Capture Status',
		description: 'Get whether Reqable live capture is currently active or inactive.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kCaptureLiveStatusSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getStatus,
				contentBuilder: (jsonMap) {
					return 'Reqable live capture is currently ${jsonMap['status']}.';
				},
			);
		},
	);
	server.registerTool(
		'capture_live_set_enabled',
		title: 'Set Live Capture Enabled State',
		description: 'Start or stop Reqable live capture.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether Reqable live capture should be started or stopped.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to start live capture.',
				),
			},
			required: ['enabled'],
		),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredBoolArgument(
				args,
				key: 'enabled',
			);
			if (validationError != null) {
				return validationError;
			}
			final bool enabled = args['enabled'];
			return buildVoidResult(
				apiCall: () {
					return service.setEnabled(enabled);
				},
				message: 'Successfully ${enabled ? 'started' : 'stopped'} live capture.',
			);
		},
	);
	server.registerTool(
		'capture_live_filter',
		title: 'Filter Live Capture Records',
		description: 'Filter current Reqable live capture records and return only the matching record IDs. Use `capture_live_get` with an ID to fetch the full record details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the live capture filters. Use an empty filters list to return all currently retained live capture record IDs.',
			properties: {
				'filters': JsonArray(
					title: 'Live Capture Filters',
					description: 'The filter definitions applied to current live capture records. Multiple filters are combined with logical AND.',
					items: _kCaptureLiveFilterSchema,
				),
			},
			required: ['filters'],
		),
		outputSchema: _kCaptureLiveFilterResultSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = _validateCaptureLiveFiltersArgument(args);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () {
					return service.filterRecords(args);
				},
				contentBuilder: (jsonList) {
					return 'Matched ${jsonList.length} live capture record${jsonList.length == 1 ? '' : 's'}.';
				},
			);
		},
	);
	server.registerTool(
		'capture_live_get_by_id',
		title: 'Get Live Capture Record By ID',
		description: 'Get the full details of a live capture record by numeric record ID.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the numeric live capture record ID to retrieve.',
			properties: {
				'id': _kCaptureLiveIdSchema,
			},
			required: ['id'],
		),
		outputSchema: _kCaptureLiveRecordSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredIntArgument(
				args,
				key: 'id',
				minimum: 0,
			);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () {
					return service.getRecord(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the live capture record details.';
				},
			);
		},
	);
  server.registerTool(
		'capture_live_clear',
		title: 'Clear Live Capture Records',
    description: 'Clear all currently retained Reqable live capture records.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: true,
    ),
    outputSchema: kMutationResultSchema,
    callback: (args, extra) {
      return buildVoidResult(
        apiCall: service.clearRecords,
        message: 'Successfully cleared all live capture records.',
      );
    },
  );
  server.registerTool(
		'capture_live_generate_curl',
		title: 'Generate cURL Command for A Live Capture Record By ID',
    description: 'Generate a cURL command for a live capture record by numeric record ID.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    inputSchema: const ToolInputSchema(
			description: 'Provide the numeric live capture record ID to retrieve.',
			properties: {
				'id': _kCaptureLiveIdSchema,
			},
			required: ['id'],
		),
    outputSchema: const ToolOutputSchema(
      title: 'cURL Command',
      description: 'The generated cURL command for the live capture record.',
      properties: {
        'curl': JsonString(
          title: 'cURL Command',
          description: 'The generated cURL command string.',
        ),
      },
      required: ['curl'],
    ),
    callback: (args, extra) {
      final CallToolResult? validationError = validateRequiredIntArgument(
				args,
				key: 'id',
				minimum: 0,
			);
			if (validationError != null) {
				return validationError;
			}
      return buildContentResult(
        apiCall: () => service.generateCurl(args),
        contentBuilder: (jsonMap) {
          return jsonMap['curl'];
        },
      );
    },
  );
	server.registerTool(
		'capture_live_compose',
		title: 'Compose Live Capture Record By ID',
		description: 'Compose a completed live capture record into a new HTTP or WebSocket tab in Reqable and return the created API ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the numeric live capture record ID to compose into a new Reqable tab.',
			properties: {
				'id': _kCaptureLiveIdSchema,
			},
			required: ['id'],
		),
		outputSchema: _kCaptureLiveComposeResultSchema,
		callback: (args, extra) {
      final CallToolResult? validationError = validateRequiredIntArgument(
				args,
				key: 'id',
				minimum: 0,
			);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () => service.compose(args),
				contentBuilder: (_) {
					return 'Successfully composed the live capture record into a new Reqable tab.';
				},
			);
		},
	);
  server.registerTool(
		'capture_live_collection_add',
		title: 'Add Live Capture Record to Collection',
		description: 'Add a completed live capture record to an existing collection in Reqable and return the created API.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the numeric live capture record ID to add to an existing collection.',
			properties: {
				'id': _kCaptureLiveIdSchema,
        'collectionId': JsonString(
          title: 'Collection ID',
          description: 'The Reqable unique collection identifier.',
        ),
        'parentId': JsonString(
					title: 'Parent Folder ID',
					description: 'Optional parent folder ID.',
				),
        'name': JsonString(
          title: 'API Name',
          description: 'Optional name for the created API.',
        ),
			},
			required: ['id', 'collectionId'],
		),
    outputSchema: ToolOutputSchema(
      title: 'API Details',
      description: 'The HTTP or WebSocket API details returned by Reqable.',
      properties: {
        'api': kCollectionApiSchema,
      },
      required: ['api'],
    ),
		callback: (args, extra) {
      final CallToolResult? idValidationError = validateRequiredIntArgument(
        args,
        key: 'id',
        minimum: 0,
      );
			if (idValidationError != null) {
				return idValidationError;
			}
      final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
        args,
        key: 'collectionId',
      );
      if (collectionIdValidationError != null) {
        return collectionIdValidationError;
      }
			return buildContentResult(
				apiCall: () => service.addToCollection(args),
				contentBuilder: (_) {
					return 'Successfully added the live capture record to the collection.';
				},
			);
		},
	);
}

class _CaptureLiveService {

	final ReqableApiClient client;

	const _CaptureLiveService({
		required this.client,
	});

	Future<String> getStatus() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/live/status',
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendGetRequest(
			VoidRequest(
				route: enabled
					? '/capture/live/on'
					: '/capture/live/off',
			),
		);
	}

	Future<String> filterRecords(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/live/filter',
				jsonMap: args,
			),
		);
	}

	Future<String> getRecord(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/live/get',
				jsonMap: args,
			),
		);
	}

  Future<void> clearRecords() {
		return client.sendPostRequest(
      const VoidRequest(
        route: '/capture/live/clear',
      ),
    );
  }

  Future<String> generateCurl(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/live/generate/curl',
        jsonMap: args,
      ),
    );
  }

	Future<String> compose(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/live/compose',
				jsonMap: args,
			),
		);
	}

  Future<String> addToCollection(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/live/collection/add',
        jsonMap: args,
      ),
    );
  }

}

CallToolResult? _validateCaptureLiveFiltersArgument(Map<String, dynamic> args) {
	final dynamic filters = args['filters'];
	if (filters == null) {
		return buildErrorResult(
			message: 'Missing required argument: filters.',
		);
	}
	if (filters is! List) {
		return buildErrorResult(
			message: 'Invalid argument type: filters should be a list of filter objects.',
		);
	}
	for (final dynamic filter in filters) {
		if (filter is! Map) {
			return buildErrorResult(
				message: 'Invalid argument: filters should contain only filter objects.',
			);
		}
		final Map<String, dynamic> jsonMap = filter.cast<String, dynamic>();
		final CallToolResult? filterValidationError = _validateCaptureLiveFilter(jsonMap);
		if (filterValidationError != null) {
			return filterValidationError;
		}
	}
	return null;
}

CallToolResult? _validateCaptureLiveFilter(Map<String, dynamic> filter) {
	final CallToolResult? typeValidationError = validateRequiredStringArgument(
		filter,
		key: 'type',
		allowedValues: _kCaptureLiveFilterTypeSchema.enumValues,
	);
	if (typeValidationError != null) {
		return typeValidationError;
	}
	switch (filter['type']) {
		case 'id':
			return _validateRequiredIntListField(filter, key: 'ids');
		case 'uid':
			return validateRequiredStringListArgument(filter, key: 'uids');
		case 'keyword':
			CallToolResult? validationError = validateRequiredStringArgument(
				filter,
				key: 'pattern',
			);
			validationError ??= _validateOptionalBoolField(filter, key: 'caseSensitive');
			validationError ??= _validateOptionalBoolField(filter, key: 'regex');
			return validationError;
		case 'url':
			return validateRequiredStringListArgument(filter, key: 'urls');
		case 'host':
			return validateRequiredStringListArgument(filter, key: 'hosts');
		case 'ip':
			return validateRequiredStringListArgument(filter, key: 'ips');
		case 'method':
			return validateRequiredStringListArgument(filter, key: 'methods');
		case 'code':
			return _validateRequiredIntListField(filter, key: 'codes');
		case 'application':
			return _validateApplicationFilter(filter);
	}
	return null;
}

CallToolResult? _validateOptionalBoolField(
	Map<String, dynamic> args, {
	required String key,
}) {
	final dynamic value = args[key];
	if (value == null) {
		return null;
	}
	if (value is! bool) {
		return buildErrorResult(
			message: 'Invalid argument type: $key should be a boolean.',
		);
	}
	return null;
}

CallToolResult? _validateRequiredIntListField(
	Map<String, dynamic> args, {
	required String key,
}) {
	final dynamic value = args[key];
	if (value == null) {
		return buildErrorResult(
			message: 'Missing required argument: $key.',
		);
	}
	if (value is! List) {
		return buildErrorResult(
			message: 'Invalid argument type: $key should be a list of integers.',
		);
	}
	if (value.isEmpty) {
		return buildErrorResult(
			message: 'Invalid argument: $key list should not be empty.',
		);
	}
	final bool hasInvalidItem = value.any((dynamic item) => item is! int);
	if (hasInvalidItem) {
		return buildErrorResult(
			message: 'Invalid argument: $key should contain only integers.',
		);
	}
	return null;
}

CallToolResult? _validateApplicationFilter(Map<String, dynamic> filter) {
	final dynamic name = filter['name'];
	final dynamic id = filter['id'];
	final dynamic pid = filter['pid'];
	if (name == null && id == null && pid == null) {
		return buildErrorResult(
			message: 'Invalid argument: application filter requires at least one of name, id, or pid.',
		);
	}
	if (name != null) {
		final CallToolResult? validationError = validateRequiredStringArgument(
			filter,
			key: 'name',
		);
		if (validationError != null) {
			return validationError;
		}
	}
	if (id != null) {
		final CallToolResult? validationError = validateRequiredStringArgument(
			filter,
			key: 'id',
		);
		if (validationError != null) {
			return validationError;
		}
	}
	if (pid != null) {
		final dynamic value = filter['pid'];
		if (value is! int) {
			return buildErrorResult(
				message: 'Invalid argument type: pid should be an integer.',
			);
		}
	}
	return null;
}

const JsonObject _kCaptureLiveStatusSchema = ToolOutputSchema(
	title: 'Live Capture Status',
	description: 'The current Reqable live capture engine status.',
	properties: {
		'status': JsonString(
			title: 'Status',
			description: 'The current live capture status.',
			enumValues: ['active', 'inactive'],
		),
	},
	required: ['status'],
);

const JsonInteger _kCaptureLiveIdSchema = JsonInteger(
	title: 'Record ID',
	description: 'A numeric live capture record ID. The ID is incremented for each new record and may be reused in different capture sessions.',
);

const JsonString _kCaptureLiveUidSchema = JsonString(
	title: 'Record UID',
	description: 'A unique live capture record identifier. The UID is generated for each new record and is guaranteed to be unique across all capture sessions.',
);

const JsonString _kCaptureLiveUrlSchema = JsonString(
	title: 'Request URL',
	description: 'The captured request URL.',
);

const JsonString _kCaptureLiveFilterTypeSchema = JsonString(
	title: 'Live Capture Filter Type',
	description: 'The type of live capture filter to apply.',
	enumValues: ['keyword', 'url', 'host', 'ip', 'method', 'code', 'application'],
);

const JsonOneOf _kCaptureLiveFilterSchema = JsonOneOf(
	[
		_kCaptureLiveKeywordFilterSchema,
		_kCaptureLiveUrlFilterSchema,
		_kCaptureLiveHostFilterSchema,
		_kCaptureLiveIpFilterSchema,
		_kCaptureLiveMethodFilterSchema,
		_kCaptureLiveCodeFilterSchema,
		_kCaptureLiveApplicationFilterSchema,
	],
	title: 'Live Capture Filter',
	description: 'A live capture filter object. Exactly one filter shape must be used according to its type.',
);

const JsonObject _kCaptureLiveKeywordFilterSchema = JsonObject(
	title: 'Keyword Filter',
	description: 'Match live capture records by keyword across URL, headers, bodies, and addresses.',
	properties: {
		'type': JsonString(
			title: 'Filter Type',
			description: 'The filter type.',
			enumValues: ['keyword'],
		),
		'pattern': JsonString(
			title: 'Keyword Pattern',
			description: 'The keyword pattern to search.',
		),
		'caseSensitive': JsonBoolean(
			title: 'Case Sensitive',
			description: 'Whether keyword matching is case-sensitive.',
			defaultValue: false,
		),
		'regex': JsonBoolean(
			title: 'Use Regular Expression',
			description: 'Whether the keyword pattern is treated as a regular expression.',
			defaultValue: false,
		),
	},
	required: ['type', 'pattern'],
);

const JsonObject _kCaptureLiveUrlFilterSchema = JsonObject(
	title: 'URL Filter',
	description: 'Match live capture records by exact request URLs.',
	properties: {
		'type': JsonString(
			title: 'Filter Type',
			description: 'The filter type.',
			enumValues: ['url'],
		),
		'urls': JsonArray(
			title: 'Record URLs',
			description: 'The exact URLs to match.',
			items: JsonString(),
		),
	},
	required: ['type', 'urls'],
);

const JsonObject _kCaptureLiveHostFilterSchema = JsonObject(
	title: 'Host Filter',
	description: 'Match live capture records by exact host names.',
	properties: {
		'type': JsonString(
			title: 'Filter Type',
			description: 'The filter type.',
			enumValues: ['host'],
		),
		'hosts': JsonArray(
			title: 'Record Hosts',
			description: 'The exact hosts to match.',
			items: JsonString(),
		),
	},
	required: ['type', 'hosts'],
);

const JsonObject _kCaptureLiveIpFilterSchema = JsonObject(
	title: 'IP Filter',
	description: 'Match live capture records by exact remote IP addresses.',
	properties: {
		'type': JsonString(
			title: 'Filter Type',
			description: 'The filter type.',
			enumValues: ['ip'],
		),
		'ips': JsonArray(
			title: 'Record IP Addresses',
			description: 'The exact remote IP addresses to match.',
			items: JsonString(),
		),
	},
	required: ['type', 'ips'],
);

const JsonObject _kCaptureLiveMethodFilterSchema = JsonObject(
	title: 'HTTP Method Filter',
	description: 'Match live capture records by HTTP request methods.',
	properties: {
		'type': JsonString(
			title: 'Filter Type',
			description: 'The filter type.',
			enumValues: ['method'],
		),
		'methods': JsonArray(
			title: 'HTTP Methods',
			description: 'The HTTP methods to match.',
			items: JsonString(),
		),
	},
	required: ['type', 'methods'],
);

const JsonObject _kCaptureLiveCodeFilterSchema = JsonObject(
	title: 'Response Code Filter',
	description: 'Match live capture records by HTTP response status codes.',
	properties: {
		'type': JsonString(
			title: 'Filter Type',
			description: 'The filter type.',
			enumValues: ['code'],
		),
		'codes': JsonArray(
			title: 'Response Status Codes',
			description: 'The response status codes to match.',
			items: JsonInteger(),
		),
	},
	required: ['type', 'codes'],
);

const JsonObject _kCaptureLiveApplicationFilterSchema = JsonObject(
	title: 'Application Filter',
	description: 'Match live capture records by captured client application metadata.',
	properties: {
		'type': JsonString(
			title: 'Filter Type',
			description: 'The filter type.',
			enumValues: ['application'],
		),
		'name': JsonString(
			title: 'Application Name',
			description: 'The application name substring to match.',
		),
		'id': JsonString(
			title: 'Application ID',
			description: 'The application identifier to match. For example, the bundle ID on macOS/iOS or the package name on Android.',
		),
		'pid': JsonInteger(
			title: 'Application PID',
			description: 'The application process ID to match.',
		),
	},
	required: ['type'],
);

const JsonObject _kCaptureLiveFilterResultSchema = ToolOutputSchema(
	title: 'Live Capture Filter Result',
	description: 'The matching live capture record IDs returned by Reqable for the given filters.',
	properties: {
		'items': JsonArray(
			title: 'Matching Record IDs',
			description: 'The numeric IDs of the live capture records that matched the filters.',
			items: _kCaptureLiveIdSchema,
		),
	},
	required: ['items'],
);

const JsonString _kCaptureLiveProtocolSchema = JsonString(
	title: 'Protocol Type',
	description: 'The captured protocol type.',
	enumValues: ['http', 'websocket'],
);

const JsonObject _kCaptureLiveHttpBodySchema = JsonObject(
	title: 'Live Capture HTTP Body',
	description: 'The HTTP body content returned by Reqable. Body content is returned as decoded text when possible, otherwise as a base64 string.',
	properties: {
		'text': JsonString(
			title: 'Body Text',
			description: 'The body content, either decoded text or a base64 string depending on the encoding.',
		),
		'mime': JsonString(
			title: 'MIME Type',
			description: 'The detected MIME type of the body, if available.',
		),
		'encoding': JsonString(
      title: 'Body Encoding',
      description: 'The encoding used for the body text. `utf8` means plain decoded text, `base64` means binary content encoded as base64.',
      enumValues: ['utf8', 'base64'],
    ),
	},
	required: ['text', 'encoding'],
);

const JsonObject _kCaptureLiveAddressSchema = JsonObject(
	title: 'Live Capture Address',
	description: 'A network endpoint address associated with a live capture record.',
	properties: {
		'ip': JsonString(
			title: 'IP Address',
			description: 'The endpoint IP address.',
		),
		'port': JsonInteger(
			title: 'Port',
			description: 'The endpoint port.',
		),
	},
	required: ['ip', 'port'],
);

const JsonObject _kCaptureLiveApplicationSchema = JsonObject(
	title: 'Live Capture Application',
	description: 'The captured client application associated with a live capture record, if available.',
	properties: {
		'name': JsonString(
			title: 'Application Name',
			description: 'The application display name.',
		),
		'id': JsonString(
			title: 'Application ID',
			description: 'The application identifier.',
		),
		'path': JsonString(
			title: 'Application Path',
			description: 'The application executable path.',
		),
		'pid': JsonInteger(
			title: 'Application PID',
			description: 'The application process ID.',
		),
	},
	required: ['name'],
);

const JsonObject _kCaptureLiveHeaderSchema = JsonObject(
	title: 'Live Capture Header',
	description: 'An HTTP header entry included in a live capture request or response.',
	properties: {
		'name': JsonString(
			title: 'Header Name',
			description: 'The HTTP header name.',
		),
		'value': JsonString(
			title: 'Header Value',
			description: 'The HTTP header value.',
		),
	},
	required: ['name', 'value'],
);

const JsonObject _kCaptureLiveRequestSchema = JsonObject(
	title: 'Live Capture Request',
	description: 'The full HTTP request captured by Reqable, including headers and an optional body payload.',
	properties: {
		'method': JsonString(
			title: 'Method',
			description: 'The HTTP request method.',
		),
		'path': JsonString(
			title: 'Path',
			description: 'The HTTP request path.',
		),
		'protocol': JsonString(
			title: 'Protocol',
			description: 'The HTTP protocol version string.',
		),
		'headers': JsonArray(
			title: 'Headers',
			description: 'The HTTP request headers.',
			items: _kCaptureLiveHeaderSchema,
		),
		'body': JsonAnyOf(
			[
				_kCaptureLiveHttpBodySchema,
				JsonNull(),
			],
			title: 'Request Body',
			description: 'The HTTP request body, or null when the request has no body.',
		),
	},
	required: ['method', 'path', 'protocol', 'headers', 'body'],
);

const JsonObject _kCaptureLiveResponseSchema = JsonObject(
	title: 'Live Capture Response',
	description: 'The full HTTP response captured by Reqable, including headers and an optional body payload.',
	properties: {
		'code': JsonInteger(
			title: 'Status Code',
			description: 'The HTTP response status code.',
		),
		'status': JsonString(
			title: 'Status Text',
			description: 'The HTTP response status text.',
		),
		'protocol': JsonString(
			title: 'Protocol',
			description: 'The HTTP protocol version string.',
		),
		'headers': JsonArray(
			title: 'Headers',
			description: 'The HTTP response headers.',
			items: _kCaptureLiveHeaderSchema,
		),
		'body': JsonAnyOf(
			[
				_kCaptureLiveHttpBodySchema,
				JsonNull(),
			],
			title: 'Response Body',
			description: 'The HTTP response body, or null when the response has no body.',
		),
	},
	required: ['code', 'status', 'protocol', 'headers', 'body'],
);

const JsonOneOf _kCaptureLiveWebSocketPayloadSchema = JsonOneOf(
	[
		_kCaptureLiveWebSocketTextPayloadSchema,
		_kCaptureLiveWebSocketBinaryPayloadSchema,
		_kCaptureLiveWebSocketPingPayloadSchema,
		_kCaptureLiveWebSocketPongPayloadSchema,
		_kCaptureLiveWebSocketClosePayloadSchema,
	],
	title: 'WebSocket Payload',
	description: 'The WebSocket payload included in a captured frame. Exactly one payload shape is used according to its type.',
);

const JsonObject _kCaptureLiveWebSocketTextPayloadSchema = JsonObject(
	title: 'WebSocket Text Payload',
	description: 'A text WebSocket payload.',
	properties: {
		'type': JsonConst(
			2,
			title: 'Payload Type',
			description: 'The payload type index for a text frame.',
		),
		'text': JsonString(
			title: 'Payload Text',
			description: 'The decoded UTF-8 text payload.',
		),
	},
	required: ['type', 'text'],
);

const JsonObject _kCaptureLiveWebSocketBinaryPayloadSchema = JsonObject(
	title: 'WebSocket Binary Payload',
	description: 'A binary WebSocket payload encoded as base64.',
	properties: {
		'type': JsonConst(
			3,
			title: 'Payload Type',
			description: 'The payload type index for a binary frame.',
		),
		'buffer': JsonString(
			title: 'Payload Buffer',
			description: 'The raw binary payload encoded as a base64 string. This field is omitted when the payload is empty.',
		),
	},
	required: ['type'],
);

const JsonObject _kCaptureLiveWebSocketPingPayloadSchema = JsonObject(
	title: 'WebSocket Ping Payload',
	description: 'A ping WebSocket payload encoded as base64.',
	properties: {
		'type': JsonConst(
			4,
			title: 'Payload Type',
			description: 'The payload type index for a ping frame.',
		),
		'buffer': JsonString(
			title: 'Payload Buffer',
			description: 'The ping payload encoded as a base64 string. This field is omitted when the payload is empty.',
		),
	},
	required: ['type'],
);

const JsonObject _kCaptureLiveWebSocketPongPayloadSchema = JsonObject(
	title: 'WebSocket Pong Payload',
	description: 'A pong WebSocket payload encoded as base64.',
	properties: {
		'type': JsonConst(
			5,
			title: 'Payload Type',
			description: 'The payload type index for a pong frame.',
		),
		'buffer': JsonString(
			title: 'Payload Buffer',
			description: 'The pong payload encoded as a base64 string. This field is omitted when the payload is empty.',
		),
	},
	required: ['type'],
);

const JsonObject _kCaptureLiveWebSocketClosePayloadSchema = JsonObject(
	title: 'WebSocket Close Payload',
	description: 'A close WebSocket payload containing a close code and reason.',
	properties: {
		'type': JsonConst(
			6,
			title: 'Payload Type',
			description: 'The payload type index for a close frame.',
		),
		'code': JsonInteger(
			title: 'Close Code',
			description: 'The WebSocket close code.',
		),
		'reason': JsonString(
			title: 'Close Reason',
			description: 'The WebSocket close reason.',
		),
	},
	required: ['type', 'code', 'reason'],
);

const JsonObject _kCaptureLiveWebSocketMessageSchema = JsonObject(
	title: 'WebSocket Message',
	description: 'A captured WebSocket frame associated with a live capture websocket record.',
	properties: {
		'flow': JsonInteger(
			title: 'Message Flow',
			description: 'The WebSocket frame direction index.',
		),
		'timestamp': JsonInteger(
			title: 'Timestamp',
			description: 'The frame timestamp in Unix milliseconds.',
		),
		'payload': _kCaptureLiveWebSocketPayloadSchema,
	},
	required: ['flow', 'timestamp', 'payload'],
);

const JsonObject _kCaptureLiveRecordSchema = ToolOutputSchema(
	title: 'Live Capture Record',
	description: 'A current Reqable live capture record with full details. Records may represent HTTP or WebSocket traffic.',
	properties: {
		'protocol': _kCaptureLiveProtocolSchema,
		'id': _kCaptureLiveIdSchema,
		'uid': _kCaptureLiveUidSchema,
		'url': _kCaptureLiveUrlSchema,
		'address': _kCaptureLiveAddressSchema,
		'application': _kCaptureLiveApplicationSchema,
		'request': _kCaptureLiveRequestSchema,
		'response': JsonAnyOf(
			[
				_kCaptureLiveResponseSchema,
				JsonNull(),
			],
			title: 'Response',
			description: 'The HTTP response for this record, or null if no response has been received.',
		),
		'messages': JsonArray(
			title: 'WebSocket Messages',
			description: 'The WebSocket messages for this record when protocol is `websocket`.',
			items: _kCaptureLiveWebSocketMessageSchema,
		),
	},
	required: ['protocol', 'id', 'uid', 'url', 'address', 'request'],
);

const JsonObject _kCaptureLiveComposeResultSchema = ToolOutputSchema(
	title: 'Live Capture Compose Result',
	description: 'The created API detail return from Reqable, you can use tool `rest_http_update` or `rest_websocket_update` to update the API.',
	properties: {
		'api': JsonOneOf([
      kRestHttpSchema,
      kRestWebSocketSchema
    ]),
	},
	required: ['api'],
);
