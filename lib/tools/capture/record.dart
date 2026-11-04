import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/collection/collection.dart';
import 'package:reqable_mcp_server/tools/rest/grpc.dart';
import 'package:reqable_mcp_server/tools/rest/http.dart';
import 'package:reqable_mcp_server/tools/rest/websocket.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureRecordTools(McpServer server, ReqableApiClient client, McpToolScope scope) {
  if (!scope.toolGroups.contains(McpToolGroup.captureRecord)) {
    return;
  }
	final _CaptureRecordService service = _CaptureRecordService(
		client: client,
	);
	server.registerTool(
		'capture_record_filter',
		title: 'Filter Records',
		description: 'Filter records and return only the matching record IDs. Use `capture_record_get_by_id` with an ID to fetch the full record details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the record filters. Use an empty filters list to return all currently retained record IDs.',
			properties: {
        'tabId': _kTabIdSchema,
				'filters': JsonArray(
					title: 'Record Filters',
					description: 'The filter definitions applied to current records. Multiple filters are combined with logical AND.',
					items: _kCaptureRecordFilterSchema,
				),
			},
			required: ['tabId', 'filters'],
		),
		outputSchema: _kCaptureRecordFilterResultSchema,
		callback: (args, extra) {
      final CallToolResult? tabIdValidationError = validateRequiredStringArgument(
        args,
        key: 'tabId',
        allowWhitespace: true,
      );
      if (tabIdValidationError != null) {
        return tabIdValidationError;
      }
			final CallToolResult? filterValidationError = _validateCaptureRecordFiltersArgument(args);
			if (filterValidationError != null) {
				return filterValidationError;
			}
			return buildContentResult(
				apiCall: () {
					return service.filterRecords(args);
				},
				contentBuilder: (String result, dynamic structuredResult) {
          if (structuredResult.isEmpty) {
            return 'There are currently no records that match the provided filters.';
          }
					return result;
				},
			);
		},
	);
	server.registerTool(
		'capture_record_get_by_id',
		title: 'Get Record By ID',
		description: 'Get the full details of a record by tab ID and numeric record ID.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the tab ID and numeric record ID to retrieve.',
			properties: {
        'tabId': _kTabIdSchema,
				'id': _kCaptureRecordIdSchema,
			},
			required: ['tabId', 'id'],
		),
		outputSchema: _kCaptureRecordRecordSchema,
		callback: (args, extra) {
      final CallToolResult? tabIdValidationError = validateRequiredStringArgument(
        args,
        key: 'tabId',
        allowWhitespace: true,
      );
      if (tabIdValidationError != null) {
        return tabIdValidationError;
      }
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
			);
		},
	);
  server.registerTool(
		'capture_record_generate_curl',
		title: 'Generate cURL Command for A Record By ID',
    description: 'Generate a cURL command for a record by numeric record ID.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    inputSchema: const ToolInputSchema(
			description: 'Provide the tab ID and numeric record ID to retrieve.',
			properties: {
        'tabId': _kTabIdSchema,
				'id': _kCaptureRecordIdSchema,
			},
			required: ['tabId', 'id'],
		),
    callback: (args, extra) {
      final CallToolResult? tabIdValidationError = validateRequiredStringArgument(
        args,
        key: 'tabId',
        allowWhitespace: true,
      );
      if (tabIdValidationError != null) {
        return tabIdValidationError;
      }
      final CallToolResult? idValidationError = validateRequiredIntArgument(
				args,
				key: 'id',
				minimum: 0,
			);
			if (idValidationError != null) {
				return idValidationError;
			}
      return buildTextResult(
        apiCall: () => service.generateCurl(args),
      );
    },
  );
	server.registerTool(
		'capture_record_compose',
		title: 'Compose Record By ID',
		description: 'Compose a completed record into a new HTTP or WebSocket tab in Reqable and return the created API ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the tab ID and numeric record ID to compose into a new Reqable tab.',
			properties: {
        'tabId': _kTabIdSchema,
				'id': _kCaptureRecordIdSchema,
			},
			required: ['tabId', 'id'],
		),
		outputSchema: _kCaptureRecordComposeResultSchema,
		callback: (args, extra) {
      final CallToolResult? tabIdValidationError = validateRequiredStringArgument(
        args,
        key: 'tabId',
        allowWhitespace: true,
      );
      if (tabIdValidationError != null) {
        return tabIdValidationError;
      }
      final CallToolResult? idValidationError = validateRequiredIntArgument(
				args,
				key: 'id',
				minimum: 0,
			);
			if (idValidationError != null) {
				return idValidationError;
			}
			return buildContentResult(
				apiCall: () => service.compose(args),
			);
		},
	);
  server.registerTool(
		'capture_record_collection_add',
		title: 'Add Record to Collection',
		description: 'Add a completed record to an existing collection in Reqable and return the created API details.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the numeric record ID to add to an existing collection.',
			properties: {
        'tabId': _kTabIdSchema,
				'id': _kCaptureRecordIdSchema,
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
			required: ['tabId', 'id', 'collectionId'],
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
      final CallToolResult? tabIdValidationError = validateRequiredStringArgument(
        args,
        key: 'tabId',
        allowWhitespace: true,
      );
      if (tabIdValidationError != null) {
        return tabIdValidationError;
      }
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
			);
		},
	);
}

class _CaptureRecordService {

	final ReqableApiClient client;

	const _CaptureRecordService({
		required this.client,
	});

	Future<String> filterRecords(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/record/filter',
				jsonMap: args,
			),
		);
	}

	Future<String> getRecord(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/record/get',
				jsonMap: args,
			),
		);
	}

  Future<String> generateCurl(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/record/generate/curl',
        jsonMap: args,
      ),
    );
  }

	Future<String> compose(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/record/compose',
				jsonMap: args,
			),
		);
	}

  Future<String> addToCollection(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/record/collection/add',
        jsonMap: args,
      ),
    );
  }

}

CallToolResult? _validateCaptureRecordFiltersArgument(Map<String, dynamic> args) {
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
		final CallToolResult? filterValidationError = _validateCaptureRecordFilter(jsonMap);
		if (filterValidationError != null) {
			return filterValidationError;
		}
	}
	return null;
}

CallToolResult? _validateCaptureRecordFilter(Map<String, dynamic> filter) {
	final CallToolResult? typeValidationError = validateRequiredStringArgument(
		filter,
		key: 'type',
		allowedValues: _kCaptureRecordFilterTypeSchema.enumValues,
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

const JsonString _kTabIdSchema = JsonString(
  title: 'Tab ID',
  description: 'The ID of the tab to filter records by, use `tab_list` to get the list of currently open tab IDs.',
);

const JsonInteger _kCaptureRecordIdSchema = JsonInteger(
	title: 'Record ID',
	description: 'A numeric record ID. The ID is incremented for each new record and may be reused in different capture sessions.',
);

const JsonString _kCaptureRecordUidSchema = JsonString(
	title: 'Record UID',
	description: 'A unique record identifier. The UID is generated for each new record and is guaranteed to be unique across all capture sessions.',
);

const JsonString _kCaptureRecordUrlSchema = JsonString(
	title: 'Request URL',
	description: 'The captured request URL.',
);

const JsonString _kCaptureRecordFilterTypeSchema = JsonString(
	title: 'Record Filter Type',
	description: 'The type of record filter to apply.',
	enumValues: ['keyword', 'url', 'host', 'ip', 'method', 'code', 'application'],
);

const JsonOneOf _kCaptureRecordFilterSchema = JsonOneOf(
	[
		_kCaptureRecordKeywordFilterSchema,
		_kCaptureRecordUrlFilterSchema,
		_kCaptureRecordHostFilterSchema,
		_kCaptureRecordIpFilterSchema,
		_kCaptureRecordMethodFilterSchema,
		_kCaptureRecordCodeFilterSchema,
		_kCaptureRecordApplicationFilterSchema,
	],
	title: 'Record Filter',
	description: 'A record filter object. Exactly one filter shape must be used according to its type.',
);

const JsonObject _kCaptureRecordKeywordFilterSchema = JsonObject(
	title: 'Keyword Filter',
	description: 'Match records by keyword across URL, headers, bodies, and addresses.',
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

const JsonObject _kCaptureRecordUrlFilterSchema = JsonObject(
	title: 'URL Filter',
	description: 'Match records by exact request URLs.',
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

const JsonObject _kCaptureRecordHostFilterSchema = JsonObject(
	title: 'Host Filter',
	description: 'Match records by exact host names.',
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

const JsonObject _kCaptureRecordIpFilterSchema = JsonObject(
	title: 'IP Filter',
	description: 'Match records by exact remote IP addresses.',
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

const JsonObject _kCaptureRecordMethodFilterSchema = JsonObject(
	title: 'HTTP Method Filter',
	description: 'Match records by HTTP request methods.',
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

const JsonObject _kCaptureRecordCodeFilterSchema = JsonObject(
	title: 'Response Code Filter',
	description: 'Match records by HTTP response status codes.',
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

const JsonObject _kCaptureRecordApplicationFilterSchema = JsonObject(
	title: 'Application Filter',
	description: 'Match records by captured client application metadata.',
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

const JsonObject _kCaptureRecordFilterResultSchema = ToolOutputSchema(
	title: 'Record Filter Result',
	description: 'The matching record IDs returned by Reqable for the given filters.',
	properties: {
		'items': JsonArray(
			title: 'Matching Record IDs',
			description: 'The numeric IDs of the records that matched the filters.',
			items: _kCaptureRecordIdSchema,
		),
	},
	required: ['items'],
);

const JsonString _kCaptureRecordProtocolSchema = JsonString(
	title: 'Protocol Type',
	description: 'The captured protocol type.',
	enumValues: ['http', 'websocket'],
);

const JsonObject _kCaptureRecordHttpBodySchema = JsonObject(
	title: 'Record HTTP Body',
	description: 'The HTTP body content of the record. Body content is returned as decoded text when possible, otherwise as a base64 string.',
	properties: {
		'text': JsonString(
			title: 'Body Text',
			description: 'The body content, either decoded text or a base64 string or a file path depending on the encoding.',
		),
		'mime': JsonString(
			title: 'MIME Type',
			description: 'The detected MIME type of the body, if available.',
		),
		'encoding': JsonString(
      title: 'Body Encoding',
      description: 'The encoding used for the body text.\n- `utf8` means plain decoded text.\n- `base64` means binary content encoded as base64.\n- `file` means the body is stored in a file.',
      enumValues: ['utf8', 'base64', 'file'],
    ),
	},
	required: ['text', 'encoding'],
);

const JsonObject _kCaptureRecordConnectionSchema = JsonObject(
	title: 'Record Connection Info',
	description: 'The network connection information associated with a record.',
	properties: {
    'id': JsonInteger(
      title: 'Connection ID',
      description: 'The numeric connection ID.',
    ),
    'timestamp': JsonString(
      title: 'Connection Timestamp',
      description: 'The connection start time as an ISO 8601 string.',
    ),
		'remote': JsonObject(
      title: 'Connection Server Address',
      description: 'The remote server address for the connection.',
      properties: {
        'ip': JsonString(
          title: 'IP Address',
          description: 'The IP address.',
        ),
        'port': JsonInteger(
          title: 'Port',
          description: 'The port.',
        ),
      },
      required: ['ip', 'port'],
    ),
		'local': JsonObject(
      title: 'Connection Client Address',
      description: 'The local client address for the connection.',
      properties: {
        'ip': JsonString(
          title: 'IP Address',
          description: 'The IP address.',
        ),
        'port': JsonInteger(
          title: 'Port',
          description: 'The port.',
        ),
      },
      required: ['ip', 'port'],
    ),
	},
	required: ['id', 'timestamp', 'remote', 'local'],
);

const JsonObject _kCaptureRecordApplicationSchema = JsonObject(
	title: 'Record Application Info',
	description: 'The captured client application associated with a record, if available.',
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

const JsonObject _kCaptureRecordHeaderSchema = JsonObject(
	title: 'Record Header',
	description: 'An HTTP header entry included in a record request or response.',
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

const JsonObject _kCaptureRecordRequestSchema = JsonObject(
	title: 'Record Request',
	description: 'The full HTTP request of the record, including headers and an optional body payload.',
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
			items: _kCaptureRecordHeaderSchema,
		),
		'body': JsonAnyOf(
			[
				_kCaptureRecordHttpBodySchema,
				JsonNull(),
			],
			title: 'Request Body',
			description: 'The HTTP request body, or null when the request has no body.',
		),
    'scriptLogs': JsonArray(
      title: 'Python Script Logs',
      description: 'The console logs generated by Python scripts.',
      items: JsonString(),
    ),
	},
	required: ['method', 'path', 'protocol', 'headers', 'body'],
);

const JsonObject _kCaptureRecordResponseSchema = JsonObject(
	title: 'Record Response',
	description: 'The full HTTP response of the record, including headers and an optional body payload.',
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
			items: _kCaptureRecordHeaderSchema,
		),
		'body': JsonAnyOf(
			[
				_kCaptureRecordHttpBodySchema,
				JsonNull(),
			],
			title: 'Response Body',
			description: 'The HTTP response body, or null when the response has no body.',
		),
    'scriptLogs': JsonArray(
      title: 'Python Script Logs',
      description: 'The console logs generated by Python scripts.',
      items: JsonString(),
    ),
	},
	required: ['code', 'status', 'protocol', 'headers', 'body'],
);

const JsonOneOf _kCaptureRecordWebSocketPayloadSchema = JsonOneOf(
	[
		_kCaptureRecordWebSocketTextPayloadSchema,
		_kCaptureRecordWebSocketBinaryPayloadSchema,
		_kCaptureRecordWebSocketPingPayloadSchema,
		_kCaptureRecordWebSocketPongPayloadSchema,
		_kCaptureRecordWebSocketClosePayloadSchema,
	],
	title: 'WebSocket Payload',
	description: 'The WebSocket payload included in a captured frame. Exactly one payload shape is used according to its type.',
);

const JsonObject _kCaptureRecordWebSocketTextPayloadSchema = JsonObject(
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

const JsonObject _kCaptureRecordWebSocketBinaryPayloadSchema = JsonObject(
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

const JsonObject _kCaptureRecordWebSocketPingPayloadSchema = JsonObject(
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

const JsonObject _kCaptureRecordWebSocketPongPayloadSchema = JsonObject(
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

const JsonObject _kCaptureRecordWebSocketClosePayloadSchema = JsonObject(
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

const JsonObject _kCaptureRecordWebSocketMessageSchema = JsonObject(
	title: 'WebSocket Message',
	description: 'A captured WebSocket frame associated with a websocket record.',
	properties: {
		'flow': JsonInteger(
			title: 'Message Flow',
			description: 'The WebSocket frame direction index.',
		),
		'timestamp': JsonInteger(
			title: 'Timestamp',
			description: 'The frame timestamp in Unix milliseconds.',
		),
		'payload': _kCaptureRecordWebSocketPayloadSchema,
	},
	required: ['flow', 'timestamp', 'payload'],
);

const JsonObject _kCaptureRecordRecordSchema = ToolOutputSchema(
	title: 'Capture Record',
	description: 'A current Reqable capture record with full details. Records may represent HTTP or WebSocket traffic.',
	properties: {
		'protocol': _kCaptureRecordProtocolSchema,
		'id': _kCaptureRecordIdSchema,
		'uid': _kCaptureRecordUidSchema,
		'url': _kCaptureRecordUrlSchema,
		'connection': _kCaptureRecordConnectionSchema,
		'application': _kCaptureRecordApplicationSchema,
		'request': _kCaptureRecordRequestSchema,
		'response': JsonAnyOf(
			[
				_kCaptureRecordResponseSchema,
				JsonNull(),
			],
			title: 'Response',
			description: 'The HTTP response for this record, or null if no response has been received.',
		),
		'messages': JsonArray(
			title: 'WebSocket Messages',
			description: 'The WebSocket messages for this record when protocol is `websocket`.',
			items: _kCaptureRecordWebSocketMessageSchema,
		),
	},
	required: ['protocol', 'id', 'uid', 'url', 'connection', 'request'],
);

const JsonObject _kCaptureRecordComposeResultSchema = ToolOutputSchema(
	title: 'Record Compose Result',
	description: 'The created API detail return from Reqable, you can use tool `rest_http_update` or `rest_websocket_update` to update the API.',
	properties: {
		'api': JsonOneOf([
      kRestHttpSchema,
      kRestWebSocketSchema,
      kRestGrpcSchema,
    ]),
	},
	required: ['api'],
);
