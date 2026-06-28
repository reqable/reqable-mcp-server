import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureReportServerTools(McpServer server, ReqableApiClient client) {
	final _CaptureReportServerService service = _CaptureReportServerService(
		client: client
	);
	server.registerTool(
		'capture_report_server_get_config',
		title: 'Get Report Server Configuration',
		description: 'Get the current Reqable report server configuration for reporting matched traffic to external HTTP endpoints.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kReportServerConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved report server configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_report_server_set_enabled',
		title: 'Set Report Server Feature Enabled State',
		description: 'Enable or disable the Reqable report server feature globally without changing any existing report server definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether the Reqable report server feature should be enabled.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the report server feature.',
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
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the report server feature.',
			);
		},
	);
	server.registerTool(
		'capture_report_server_lookup',
		title: 'Get Report Server by ID',
		description: 'Retrieve a report server by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kReportServerSchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide a report server ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kReportServerIdSchema,
			},
			required: ['id'],
		),
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'id',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () {
					return service.getReportServerById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the report server details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_report_server_set_item_enabled',
		title: 'Set Report Servers Enabled State',
		description: 'Enable or disable one or more report servers by their IDs without changing their definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more report server IDs and whether they should be enabled.',
			properties: {
				'ids': JsonArray(
					items: _kReportServerIdSchema
				),
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the specified report servers.',
				),
			},
			required: ['ids', 'enabled'],
		),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			CallToolResult? validationError = validateRequiredStringListArgument(
				args,
				key: 'ids',
			);
			validationError ??= validateRequiredBoolArgument(
				args,
				key: 'enabled',
			);
			if (validationError != null) {
				return validationError;
			}
			final bool enabled = args['enabled'];
			return buildVoidResult(
				apiCall: () {
					return service.setReportServersEnabled(args);
				},
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the specified report servers.',
			);
		},
	);
	server.registerTool(
		'capture_report_server_create',
		title: 'Create Report Server',
		description: 'Create a new Reqable report server definition and return the created report server.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the report server definition to create. The name, pattern, url, and encoding are required.',
			properties: {
				'name': _kReportServerNameSchema,
				'pattern': _kReportServerPatternSchema,
				'url': _kReportServerUrlSchema,
				'wildcard': _kReportServerWildcardSchema,
				'tag': _kReportServerTagSchema,
				'encoding': _kReportServerEncodingSchema,
			},
			required: ['name', 'pattern', 'url', 'encoding'],
		),
		outputSchema: _kReportServerSchema,
		callback: (args, extra) {
			final CallToolResult? nameValidationError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (nameValidationError != null) {
				return nameValidationError;
			}
			final CallToolResult? patternValidationError = validateRequiredStringArgument(
				args,
				key: 'pattern',
			);
			if (patternValidationError != null) {
				return patternValidationError;
			}
			final CallToolResult? urlValidationError = validateRequiredStringArgument(
				args,
				key: 'url',
			);
			if (urlValidationError != null) {
				return urlValidationError;
			}
			final dynamic url = args['url'];
			if (url is String && !url.startsWith('http://') && !url.startsWith('https://')) {
				return buildErrorResult(
					message: 'Invalid argument: url should be a valid http or https URL.',
				);
			}
			final CallToolResult? encodingValidationError = validateRequiredStringArgument(
				args,
				key: 'encoding',
				allowedValues: _kReportServerEncodingSchema.enumValues,
			);
			if (encodingValidationError != null) {
				return encodingValidationError;
			}
			final dynamic wildcard = args['wildcard'];
			if (wildcard != null) {
				final CallToolResult? wildcardValidationError = validateRequiredBoolArgument(
					args,
					key: 'wildcard',
				);
				if (wildcardValidationError != null) {
					return wildcardValidationError;
				}
			}
			final dynamic tag = args['tag'];
			if (tag != null) {
				final CallToolResult? tagValidationError = validateRequiredStringArgument(
					args,
					key: 'tag',
					allowEmpty: true,
				);
				if (tagValidationError != null) {
					return tagValidationError;
				}
			}
			return buildContentResult(
				apiCall: () {
					return service.createReportServer(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the report server.';
				},
			);
		},
	);
	server.registerTool(
		'capture_report_server_delete',
		title: 'Delete Report Servers',
		description: 'Permanently delete one or more report servers by their IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more report server IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kReportServerIdSchema
				),
			},
			required: ['ids'],
		),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringListArgument(
				args,
				key: 'ids',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildVoidResult(
				apiCall: () {
					return service.deleteReportServers(args);
				},
				message: 'Successfully deleted the specified report servers.',
			);
		},
	);
	server.registerTool(
		'capture_report_server_update',
		title: 'Update Report Server',
		description: 'Update an existing report server by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: _kReportServerSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () {
					return service.updateReportServer(args);
				},
				message: 'Successfully updated the report server.',
			);
		},
	);
}

class _CaptureReportServerService {

	final ReqableApiClient client;

	const _CaptureReportServerService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/report-server'
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/report-server/on'
					: '/capture/report-server/off'
			),
		);
	}

	Future<String> getReportServerById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/report-server/lookup',
				jsonMap: args,
			),
		);
	}

	Future<void> setReportServersEnabled(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: args['enabled']
					? '/capture/report-server/enable'
					: '/capture/report-server/disable',
				jsonMap: args,
			),
		);
	}

	Future<String> createReportServer(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/report-server/create',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteReportServers(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/report-server/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateReportServer(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/report-server/update',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kReportServerIdSchema = JsonString(
	title: 'Report Server ID',
	description: 'The unique ID of a Reqable report server.',
);

const JsonString _kReportServerNameSchema = JsonString(
	title: 'Report Server Name',
	description: 'The human-readable name of a Reqable report server.',
);

const JsonString _kReportServerPatternSchema = JsonString(
	title: 'Traffic URL Pattern',
	description: 'The URL or URL pattern, the matched traffic will be reported to the external endpoint.',
);

const JsonBoolean _kReportServerWildcardSchema = JsonBoolean(
	title: 'Use Wildcard Matching',
	description: 'Whether the traffic URL pattern is interpreted as a wildcard pattern.',
	defaultValue: true,
);

const JsonString _kReportServerUrlSchema = JsonString(
	title: 'Server Endpoint URL',
	description: 'The HTTP or HTTPS endpoint URL used to receive reported traffic. The traffic data will be sent as a HTTP Archive (HAR) in the request body.',
);

const JsonString _kReportServerTagSchema = JsonString(
	title: 'Tag',
	description: 'An optional tag value included in request header `x-reqable-reporter-tag`.',
);

const JsonString _kReportServerEncodingSchema = JsonString(
	title: 'Payload Encoding',
	description: 'The encoding used when sending traffic data to the report server endpoint.\n - `none`: No encoding, the request body will be sent as-is.\n - `gzip`: Gzip compression.\n - `br`: Brotli compression.\n - `zstd`: Zstandard compression.',
	enumValues: ['none', 'gzip', 'br', 'zstd'],
  defaultValue: 'none',
);

const JsonObject _kReportServerSchema = ToolOutputSchema(
	title: 'Report Server',
	description: 'The report server definition returned by Reqable.',
	properties: {
		'id': _kReportServerIdSchema,
		'name': _kReportServerNameSchema,
		'pattern': _kReportServerPatternSchema,
		'wildcard': _kReportServerWildcardSchema,
		'url': _kReportServerUrlSchema,
		'tag': _kReportServerTagSchema,
		'encoding': _kReportServerEncodingSchema,
		'isEnabled': JsonBoolean(
			title: 'Is Enabled',
			description: 'Whether the report server itself is currently enabled.',
		),
	},
	required: ['id', 'name', 'pattern', 'wildcard', 'url', 'tag', 'encoding', 'isEnabled'],
);

const JsonObject _kReportServerConfigSchema = ToolOutputSchema(
	title: 'Report Server Configuration',
	description: 'The full Reqable report server configuration, including all report servers and the global enabled state.',
	properties: {
		'servers': JsonArray(
			title: 'Report Servers',
			description: 'The report servers currently configured in Reqable.',
			items: _kReportServerSchema,
		),
		'isEnabled': JsonBoolean(
			title: 'Report Server Feature Enabled',
			description: 'Whether the global Reqable report server feature is currently enabled.',
		),
	},
	required: ['servers', 'isEnabled'],
);
