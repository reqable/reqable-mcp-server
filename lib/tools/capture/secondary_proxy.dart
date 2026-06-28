import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp/api/client.dart';
import 'package:reqable_mcp/tools/result.dart';
import 'package:reqable_mcp/tools/schema.dart';
import 'package:reqable_mcp/tools/validate.dart';

void registerCaptureSecondaryProxyTools(McpServer server, ReqableApiClient client) {
	final _CaptureSecondaryProxyService service = _CaptureSecondaryProxyService(
		client: client
	);
	server.registerTool(
		'capture_secondary_proxy_get_config',
		title: 'Get Secondary Proxy Configuration',
		description: 'Get the current Reqable secondary proxy configuration for forwarding traffic through an upstream proxy with include or exclude rules. Currently, only HTTP and HTTPS upstream proxies are supported.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kSecondaryProxyConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved secondary proxy configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_secondary_proxy_set_enabled',
		title: 'Set Secondary Proxy Feature Enabled State',
		description: 'Enable or disable the Reqable secondary proxy feature globally without changing any existing secondary proxy definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether the Reqable secondary proxy feature should be enabled.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the secondary proxy feature.',
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
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the secondary proxy feature.',
			);
		},
	);
	server.registerTool(
		'capture_secondary_proxy_get_active',
		title: 'Get Active Secondary Proxy',
		description: 'Get the currently active secondary proxy, if any.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
    outputSchema: ToolOutputSchema(
      title: 'Active Secondary Proxy',
      description: 'Return the currently active secondary proxy, if any. If no secondary proxy is active, the proxy property will be null.',
      properties: {
				'proxy': JsonOneOf([
					_kSecondaryProxySchema,
					const JsonNull(),
				]),
      },
    ),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getActiveSecondaryProxy,
				contentBuilder: (jsonMap) {
					if (jsonMap['profile'] == null) {
						return 'There is currently no active secondary proxy.';
					}
					return 'Successfully retrieved the active secondary proxy.';
				},
			);
		},
	);
	server.registerTool(
		'capture_secondary_proxy_lookup',
		title: 'Get Secondary Proxy by ID',
		description: 'Retrieve a secondary proxy by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kSecondaryProxySchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide a secondary proxy ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kSecondaryProxyIdSchema,
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
					return service.getSecondaryProxyById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the secondary proxy details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_secondary_proxy_select',
		title: 'Select Secondary Proxy By ID',
		description: 'Select a secondary proxy by ID as the active secondary proxy configuration.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the secondary proxy ID to activate.',
			properties: {
				'id': _kSecondaryProxyIdSchema,
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
					return service.selectSecondaryProxy(args);
				},
				message: 'Successfully selected the secondary proxy.',
			);
		},
	);
	server.registerTool(
		'capture_secondary_proxy_create',
		title: 'Create Secondary Proxy',
		description: 'Create a new Reqable secondary proxy definition and return the created secondary proxy.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the secondary proxy definition to create. The name, host, and port are required.',
			properties: {
				'name': _kSecondaryProxyNameSchema,
				'host': _kSecondaryProxyHostSchema,
				'port': _kSecondaryProxyPortSchema,
				'username': _kSecondaryProxyUsernameSchema,
				'password': _kSecondaryProxyPasswordSchema,
				'rules': _kSecondaryProxyRulesArraySchema,
				'mode': _kSecondaryProxyModeSchema,
			},
			required: ['name', 'host', 'port'],
		),
		outputSchema: _kSecondaryProxySchema,
		callback: (args, extra) {
			final CallToolResult? nameValidationError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (nameValidationError != null) {
				return nameValidationError;
			}
			final CallToolResult? hostValidationError = validateRequiredStringArgument(
				args,
				key: 'host',
			);
			if (hostValidationError != null) {
				return hostValidationError;
			}
			final CallToolResult? portValidationError = validateRequiredIntArgument(
				args,
				key: 'port',
				minimum: 1,
				maximum: 65535,
			);
			if (portValidationError != null) {
				return portValidationError;
			}
			final dynamic rules = args['rules'];
			if (rules != null) {
				final CallToolResult? rulesValidationError = validateRequiredStringListArgument(
					args,
					key: 'rules',
				);
				if (rulesValidationError != null) {
					return rulesValidationError;
				}
			}
			final dynamic username = args['username'];
			if (username != null) {
				final CallToolResult? usernameValidationError = validateRequiredStringArgument(
					args,
					key: 'username',
					allowEmpty: true,
				);
				if (usernameValidationError != null) {
					return usernameValidationError;
				}
			}
			final dynamic password = args['password'];
			if (password != null) {
				final CallToolResult? passwordValidationError = validateRequiredStringArgument(
					args,
					key: 'password',
					allowEmpty: true,
				);
				if (passwordValidationError != null) {
					return passwordValidationError;
				}
			}
			final dynamic mode = args['mode'];
			if (mode != null) {
				final CallToolResult? modeValidationError = validateRequiredStringArgument(
					args,
					key: 'mode',
					allowedValues: _kSecondaryProxyModeSchema.enumValues,
				);
				if (modeValidationError != null) {
					return modeValidationError;
				}
			}
			return buildContentResult(
				apiCall: () {
					return service.createSecondaryProxy(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the secondary proxy.';
				},
			);
		},
	);
	server.registerTool(
		'capture_secondary_proxy_delete',
		title: 'Delete Secondary Proxies',
		description: 'Permanently delete one or more secondary proxies by their IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more secondary proxy IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kSecondaryProxyIdSchema
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
					return service.deleteSecondaryProxies(args);
				},
				message: 'Successfully deleted the specified secondary proxies.',
			);
		},
	);
	server.registerTool(
		'capture_secondary_proxy_update',
		title: 'Update Secondary Proxy Profile',
		description: 'Update an existing secondary proxy by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: _kSecondaryProxySchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () {
					return service.updateSecondaryProxy(args);
				},
				message: 'Successfully updated the secondary proxy profile.',
			);
		},
	);
}

class _CaptureSecondaryProxyService {

	final ReqableApiClient client;

	const _CaptureSecondaryProxyService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/secondary-proxy'
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/secondary-proxy/on'
					: '/capture/secondary-proxy/off'
			),
		);
	}

	Future<String> getActiveSecondaryProxy() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/secondary-proxy/get-active'
			),
		);
	}

	Future<String> getSecondaryProxyById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/secondary-proxy/lookup',
				jsonMap: args,
			),
		);
	}

	Future<void> selectSecondaryProxy(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/secondary-proxy/select',
				jsonMap: args,
			),
		);
	}

	Future<String> createSecondaryProxy(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/secondary-proxy/create',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteSecondaryProxies(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/secondary-proxy/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateSecondaryProxy(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/secondary-proxy/update',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kSecondaryProxyIdSchema = JsonString(
	title: 'Secondary Proxy ID',
	description: 'The unique ID of a Reqable secondary proxy.',
);

const JsonString _kSecondaryProxyNameSchema = JsonString(
	title: 'Secondary Proxy Name',
	description: 'The human-readable name of a Reqable secondary proxy.',
);

const JsonString _kSecondaryProxyHostSchema = JsonString(
	title: 'Host',
	description: 'The upstream proxy host name or IP address.',
);

const JsonInteger _kSecondaryProxyPortSchema = JsonInteger(
	title: 'Port',
	description: 'The upstream proxy port.',
	minimum: 1,
	maximum: 65535,
);

const JsonString _kSecondaryProxyUsernameSchema = JsonString(
	title: 'Username',
	description: 'The username used for upstream proxy authentication. Empty string is allowed.',
);

const JsonString _kSecondaryProxyPasswordSchema = JsonString(
	title: 'Password',
	description: 'The password used for upstream proxy authentication. Empty string is allowed. Note: the password is desensitized in any API response for security reasons.',
);

const JsonArray _kSecondaryProxyRulesArraySchema = JsonArray(
	title: 'Rules',
	description: 'A list of rule strings used to decide when the secondary proxy should be applied.',
	items: JsonString(
		title: 'Rule',
		description: 'A rule is a string that can be a domain or IP address, or a wildcard pattern. For example, `example.com`, `*.example.com`, or `192.168.*`.',
	),
);

const JsonString _kSecondaryProxyModeSchema = JsonString(
	title: 'Mode',
	description: 'The rule matching mode.\n- `include`: only traffic matching the listed rules can be forwarded through the upstream proxy.\n- `exclude`: traffic matching the listed rules bypasses the upstream proxy.',
	enumValues: ['include', 'exclude'],
);

const JsonObject _kSecondaryProxySchema = ToolOutputSchema(
	title: 'Secondary Proxy',
	description: 'The secondary proxy definition returned by Reqable.',
	properties: {
		'id': _kSecondaryProxyIdSchema,
		'name': _kSecondaryProxyNameSchema,
		'host': _kSecondaryProxyHostSchema,
		'port': _kSecondaryProxyPortSchema,
		'rules': _kSecondaryProxyRulesArraySchema,
		'mode': _kSecondaryProxyModeSchema,
	},
	required: ['id', 'name', 'host', 'port', 'rules', 'mode'],
);

const JsonObject _kSecondaryProxyConfigSchema = ToolOutputSchema(
	title: 'Secondary Proxy Configuration',
	description: 'The full Reqable secondary proxy configuration, including all profiles, the selected index, and the global enabled state.',
	properties: {
		'profiles': JsonArray(
			title: 'Secondary Proxy Profiles',
			description: 'The secondary proxy profiles currently configured in Reqable.',
			items: _kSecondaryProxySchema,
		),
		'index': JsonInteger(
			title: 'Active Proxy Index',
			description: 'The selected secondary proxy index. A negative value means no proxy is selected.',
			minimum: -1,
		),
		'isEnabled': JsonBoolean(
			title: 'Secondary Proxy Feature Enabled',
			description: 'Whether the global Reqable secondary proxy feature is currently enabled.',
		),
	},
	required: ['profiles', 'index', 'isEnabled'],
);
