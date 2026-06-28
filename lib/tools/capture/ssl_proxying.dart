import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureSSLProxyingTools(McpServer server, ReqableApiClient client) {
	final _CaptureSSLProxyingService service = _CaptureSSLProxyingService(
		client: client
	);
	server.registerTool(
		'capture_ssl_proxying_get_config',
		title: 'Get SSL Proxying Configuration',
		description: 'Get the current Reqable SSL proxying configuration to determine which hosts should be intercepted or bypassed during HTTPS capture.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kSSLProxyingConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved SSL proxying configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_ssl_proxying_get_active',
		title: 'Get Active SSL Proxying Profile',
		description: 'Get the currently active SSL proxying profile.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
    outputSchema: ToolOutputSchema(
      title: 'Active SSL Proxying Profile',
      description: 'Return the currently active SSL proxying profile, if any. If no profile is active, the profile property will be null.',
      properties: {
				'profile': JsonOneOf([
					_kSSLProxyingSchema,
					const JsonNull(),
				]),
      },
    ),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getActiveSSLProxying,
				contentBuilder: (jsonMap) {
					if (jsonMap['profile'] == null) {
						return 'There is currently no active SSL proxying profile.';
					}
					return 'Successfully retrieved the active SSL proxying profile.';
				},
			);
		},
	);
	server.registerTool(
		'capture_ssl_proxying_lookup',
		title: 'Get SSL Proxying Profile by ID',
		description: 'Retrieve an SSL proxying profile by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kSSLProxyingSchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide an SSL proxying profile ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kSSLProxyingIdSchema,
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
					return service.getSSLProxyingById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the SSL proxying profile details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_ssl_proxying_select',
		title: 'Select A SSL Proxying Profile By ID',
		description: 'Select a SSL proxying profile by ID as the active HTTPS interception behavior.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the SSL proxying profile ID to activate.',
			properties: {
				'id': _kSSLProxyingIdSchema,
			},
			required: ['id'],
		),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'id',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildVoidResult(
				apiCall: () {
					return service.selectSSLProxying(args);
				},
				message: 'Successfully selected the SSL proxying profile.',
			);
		},
	);
	server.registerTool(
		'capture_ssl_proxying_create',
		title: 'Create SSL Proxying Profile',
		description: 'Create a new Reqable SSL proxying profile and return the created profile.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the SSL proxying profile definition to create. The name and rules are required.',
			properties: {
				'name': _kSSLProxyingNameSchema,
				'rules': _kSSLProxyingRulesArraySchema,
				'mode': _kSSLProxyingModeSchema,
				'silent': _kSSLProxyingSilentSchema,
			},
			required: ['name', 'rules'],
		),
		outputSchema: _kSSLProxyingSchema,
		callback: (args, extra) {
			final CallToolResult? nameValidationError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (nameValidationError != null) {
				return nameValidationError;
			}
			final CallToolResult? rulesValidationError = validateRequiredStringListArgument(
				args,
				key: 'rules',
			);
			if (rulesValidationError != null) {
				return rulesValidationError;
			}
			final dynamic mode = args['mode'];
			if (mode != null) {
				final CallToolResult? modeValidationError = validateRequiredStringArgument(
					args,
					key: 'mode',
					allowedValues: _kSSLProxyingModeSchema.enumValues,
				);
				if (modeValidationError != null) {
					return modeValidationError;
				}
			}
			final dynamic silent = args['silent'];
			if (silent != null) {
				final CallToolResult? silentValidationError = validateRequiredBoolArgument(
					args,
					key: 'silent',
				);
				if (silentValidationError != null) {
					return silentValidationError;
				}
			}
			return buildContentResult(
				apiCall: () {
					return service.createSSLProxying(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the SSL proxying profile.';
				},
			);
		},
	);
	server.registerTool(
		'capture_ssl_proxying_delete',
		title: 'Delete SSL Proxying Profiles',
		description: 'Permanently delete one or more SSL proxying profiles by their IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more SSL proxying profile IDs to delete permanently. Please note that internal built-in profiles cannot be deleted.',
			properties: {
				'ids': JsonArray(
					title: 'SSL Proxying Profile IDs',
					description: 'A list of SSL proxying profile IDs.',
					items: _kSSLProxyingIdSchema,
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
					return service.deleteSSLProxyings(args);
				},
				message: 'Successfully deleted the specified SSL proxying profiles.',
			);
		},
	);
	server.registerTool(
		'capture_ssl_proxying_update',
		title: 'Update SSL Proxying Profile',
		description: 'Update an existing SSL proxying profile by ID. Please note that internal built-in profiles cannot be modified.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: _kSSLProxyingSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () {
					return service.updateSSLProxying(args);
				},
				message: 'Successfully updated the SSL proxying profile.',
			);
		},
	);
}

class _CaptureSSLProxyingService {

	final ReqableApiClient client;

	const _CaptureSSLProxyingService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/ssl-proxying'
			),
		);
	}

	Future<String> getActiveSSLProxying() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/ssl-proxying/get-active'
			),
		);
	}

	Future<String> getSSLProxyingById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/ssl-proxying/lookup',
				jsonMap: args,
			),
		);
	}

	Future<void> selectSSLProxying(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/ssl-proxying/select',
				jsonMap: args,
			),
		);
	}

	Future<void> selectInterceptAll() {
		return client.sendPostRequest(
			const VoidRequest(
				route: '/capture/ssl-proxying/select-intercept-all'
			),
		);
	}

	Future<void> selectBypassAll() {
		return client.sendPostRequest(
			const VoidRequest(
				route: '/capture/ssl-proxying/select-bypass-all'
			),
		);
	}

	Future<String> createSSLProxying(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/ssl-proxying/create',
				jsonMap: args,
			),
		);
		}

	Future<void> deleteSSLProxyings(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/ssl-proxying/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateSSLProxying(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/ssl-proxying/update',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kSSLProxyingIdSchema = JsonString(
	title: 'SSL Proxying Profile ID',
	description: 'The unique ID of a Reqable SSL proxying profile. A profile ID that starts with `reqable-internal-` is an internal built-in profile that cannot be modified or deleted.',
);

const JsonString _kSSLProxyingNameSchema = JsonString(
	title: 'SSL Proxying Profile Name',
	description: 'The human-readable name of a Reqable SSL proxying profile.',
);

const JsonArray _kSSLProxyingRulesArraySchema = JsonArray(
	title: 'Rules',
	description: 'A list of rule strings used to decide whether traffic should be intercepted or bypassed.',
	items: JsonString(
		title: 'Rule',
		description: 'A rule is a string that can be a domain or IP address, or a wildcard pattern. For example, `example.com`, `*.example.com`, or `192.168.*`.',
	),
);

const JsonString _kSSLProxyingModeSchema = JsonString(
	title: 'Mode',
	description: 'The SSL proxying rule matching mode.\n- `include`: only matching traffic is intercepted.\n- `exclude`: matching traffic is bypassed.',
	enumValues: ['include', 'exclude'],
);

const JsonBoolean _kSSLProxyingSilentSchema = JsonBoolean(
	title: 'Silent Mode',
	description: 'Whether the bypassed traffic should display in the traffic live list.',
);

const JsonObject _kSSLProxyingSchema = ToolOutputSchema(
	title: 'SSL Proxying Profile',
	description: 'The SSL proxying profile definition returned by Reqable. ID `reqable-internal-include-all` and `reqable-internal-exclude-all` are internal built-in profiles that cannot be modified or deleted.',
	properties: {
		'id': _kSSLProxyingIdSchema,
		'name': _kSSLProxyingNameSchema,
		'rules': _kSSLProxyingRulesArraySchema,
		'mode': _kSSLProxyingModeSchema,
		'silent': _kSSLProxyingSilentSchema,
	},
	required: ['id', 'name', 'rules', 'mode', 'silent'],
);

const JsonObject _kSSLProxyingConfigSchema = ToolOutputSchema(
	title: 'SSL Proxying Configuration',
	description: 'The full Reqable SSL proxying configuration, including all profiles and the selected profile index.',
	properties: {
		'profiles': JsonArray(
			title: 'SSL Proxying Profiles',
			description: 'The SSL proxying profiles currently configured in Reqable.',
			items: _kSSLProxyingSchema,
		),
		'index': JsonInteger(
			title: 'Active Profile Index',
			description: 'The selected SSL proxying profile index.',
			minimum: 0,
		),
	},
	required: ['profiles', 'index'],
);
