import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureNetworkThrottlingTools(McpServer server, ReqableApiClient client) {
	final _CaptureNetworkThrottlingService service = _CaptureNetworkThrottlingService(
		client: client
	);
	server.registerTool(
		'capture_network_throttling_get_config',
		title: 'Get Network Throttling Configuration',
		description: 'Get the current Reqable network throttling configuration for simulating different network conditions for matched traffic.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kNetworkThrottlingConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved network throttling configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_network_throttling_set_enabled',
		title: 'Set Network Throttling Feature Enabled State',
		description: 'Enable or disable the Reqable network throttling feature globally without changing any existing throttling profiles.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether the Reqable network throttling feature should be enabled.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the network throttling feature.',
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
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the network throttling feature.',
			);
		},
	);
	server.registerTool(
		'capture_network_throttling_get_active',
		title: 'Get Active Network Throttling Profile',
		description: 'Get the currently active network throttling profile, if any.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
    outputSchema: ToolOutputSchema(
      title: 'Active Network Throttling Profile',
      description: 'Return the currently active network throttling profile, if any. If no profile is active, the profile property will be null.',
      properties: {
				'profile': JsonOneOf([
          _kNetworkThrottlingSchema,
          const JsonNull(),
        ]),
      },
    ),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getActiveNetworkThrottling,
				contentBuilder: (jsonMap) {
					if (jsonMap['profile'] == null) {
						return 'There is currently no active network throttling profile.';
					}
					return 'Successfully retrieved the active network throttling profile.';
				},
			);
		},
	);
	server.registerTool(
		'capture_network_throttling_lookup',
		title: 'Get Network Throttling Profile by ID',
		description: 'Retrieve a network throttling profile by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kNetworkThrottlingSchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide a network throttling profile ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kNetworkThrottlingIdSchema,
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
					return service.getNetworkThrottlingById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the network throttling profile details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_network_throttling_select',
		title: 'Select Network Throttling Profile By ID',
		description: 'Select a network throttling profile by ID as the active network throttling configuration.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the network throttling profile ID to activate.',
			properties: {
				'id': _kNetworkThrottlingIdSchema,
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
					return service.selectNetworkThrottling(args);
				},
				message: 'Successfully selected the network throttling profile.',
			);
		},
	);
	server.registerTool(
		'capture_network_throttling_create',
		title: 'Create Network Throttling Profile',
		description: 'Create a new Reqable network throttling profile and return the created network throttling profile.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the network throttling profile definition to create. The name, host, and mode are required.',
			properties: {
				'name': _kNetworkThrottlingNameSchema,
				'host': _kNetworkThrottlingHostSchema,
				'mode': _kNetworkThrottlingModeSchema,
			},
			required: ['name', 'host', 'mode'],
		),
		outputSchema: _kNetworkThrottlingSchema,
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
			final CallToolResult? modeValidationError = validateRequiredStringArgument(
				args,
				key: 'mode',
        allowedValues: _kNetworkThrottlingModeSchema.enumValues,
			);
			if (modeValidationError != null) {
				return modeValidationError;
			}
			return buildContentResult(
				apiCall: () {
					return service.createNetworkThrottling(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the network throttling profile.';
				},
			);
		},
	);
	server.registerTool(
		'capture_network_throttling_delete',
		title: 'Delete Network Throttling Profiles',
		description: 'Permanently delete one or more network throttling profiles by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more network throttling profile IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kNetworkThrottlingIdSchema
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
					return service.deleteNetworkThrottlingProfiles(args);
				},
				message: 'Successfully deleted the specified network throttling profiles.',
			);
		},
	);
	server.registerTool(
		'capture_network_throttling_update',
		title: 'Update Network Throttling Profile',
		description: 'Update an existing network throttling profile by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: _kNetworkThrottlingSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () {
					return service.updateNetworkThrottling(args);
				},
				message: 'Successfully updated the network throttling profile.',
			);
		},
	);
}

class _CaptureNetworkThrottlingService {

	final ReqableApiClient client;

	const _CaptureNetworkThrottlingService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/network-throttling'
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/network-throttling/on'
					: '/capture/network-throttling/off'
			),
		);
	}

	Future<String> getActiveNetworkThrottling() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/network-throttling/get-active'
			),
		);
	}

	Future<String> getNetworkThrottlingById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/network-throttling/lookup',
				jsonMap: args,
			),
		);
	}

	Future<void> selectNetworkThrottling(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/network-throttling/select',
				jsonMap: args,
			),
		);
	}

	Future<String> createNetworkThrottling(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/network-throttling/create',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteNetworkThrottlingProfiles(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/network-throttling/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateNetworkThrottling(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/network-throttling/update',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kNetworkThrottlingIdSchema = JsonString(
	title: 'Network Throttling Profile ID',
	description: 'The unique ID of a Reqable network throttling profile.',
);

const JsonString _kNetworkThrottlingNameSchema = JsonString(
	title: 'Network Throttling Profile Name',
	description: 'The human-readable name of a Reqable network throttling profile.',
);

const JsonString _kNetworkThrottlingHostSchema = JsonString(
	title: 'Host Pattern',
	description: 'The host or host pattern matched by the network throttling profile. Supports wildcards `*` and `?`, such as `*.example.com`.',
);

const JsonString _kNetworkThrottlingModeSchema = JsonString(
	title: 'Network Throttling Mode',
	description: 'The Reqable network throttling mode name.\n- `offline`: Simulate no network connectivity.\n- `bad`: Simulate a very poor network connection.\n- `slow`: Simulate a slow network connection.\n- `fast`: Simulate a fast network connection.\n- `m2G`: Simulate a 2G mobile network connection.\n- `m3G`: Simulate a 3G mobile network connection.\n- `m4G`: Simulate a 4G mobile network connection.\n- `m5G`: Simulate a 5G mobile network connection.\n- `wifi`: Simulate a Wi-Fi network connection.',
  enumValues: ['offline', 'bad', 'slow', 'fast', 'm2G', 'm3G', 'm4G', 'm5G', 'wifi'],
);

const JsonObject _kNetworkThrottlingSchema = ToolOutputSchema(
	title: 'Network Throttling Profile',
	description: 'The network throttling profile returned by Reqable.',
	properties: {
		'id': _kNetworkThrottlingIdSchema,
		'name': _kNetworkThrottlingNameSchema,
		'host': _kNetworkThrottlingHostSchema,
		'mode': _kNetworkThrottlingModeSchema,
	},
	required: ['id', 'name', 'host', 'mode'],
);

const JsonObject _kNetworkThrottlingConfigSchema = ToolOutputSchema(
	title: 'Network Throttling Configuration',
	description: 'The full Reqable network throttling configuration, including all profiles, the selected index, and the global enabled state.',
	properties: {
		'profiles': JsonArray(
			title: 'Network Throttling Profiles',
			description: 'The network throttling profiles currently configured in Reqable.',
			items: _kNetworkThrottlingSchema,
		),
		'index': JsonInteger(
			title: 'Active Profile Index',
			description: 'The selected network throttling profile index. A negative value means no profile is selected.',
			minimum: -1,
		),
		'isEnabled': JsonBoolean(
			title: 'Network Throttling Feature Enabled',
			description: 'Whether the global Reqable network throttling feature is currently enabled.',
		),
	},
	required: ['profiles', 'index', 'isEnabled'],
);
