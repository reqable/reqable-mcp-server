import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureAccessControlTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.captureAccessControl)) {
		return;
	}
	final _CaptureAccessControlService service = _CaptureAccessControlService(
		client: client
	);
	server.registerTool(
		'capture_access_control_get_config',
		title: 'Get Access Control Configuration',
		description: 'Get the current Reqable access control configuration for controlling which clients can access the Reqable server and APIs.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kAccessControlConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved access control configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_access_control_set_enabled',
		title: 'Set Access Control Feature Enabled State',
		description: 'Enable or disable the Reqable access control feature globally without changing any existing access control definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether the Reqable access control feature should be enabled.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the access control feature.',
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
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the access control feature.',
			);
		},
	);
	server.registerTool(
		'capture_access_control_get_active',
		title: 'Get Active Access Control Profile',
		description: 'Get the currently active access control profile, if any.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: ToolOutputSchema(
      title: 'Active Access Control Profile',
      description: 'Return the currently active access control profile, if any. If no profile is active, the profile property will be null.',
      properties: {
				'profile': JsonOneOf([
					_kAccessControlSchema,
					const JsonNull(),
				]),
      },
    ),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getActiveAccessControl,
				contentBuilder: (jsonMap) {
					if (jsonMap['profile'] == null) {
						return 'There is currently no active access control profile.';
					}
					return 'Successfully retrieved the active access control profile.';
				},
			);
		},
	);
	server.registerTool(
		'capture_access_control_lookup',
		title: 'Get Access Control Profile by ID',
		description: 'Retrieve an access control profile by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kAccessControlSchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide an access control profile ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kAccessControlIdSchema,
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
					return service.getAccessControlById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the access control profile details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_access_control_select',
		title: 'Select Access Control Profile By ID',
		description: 'Select an access control profile by ID as the active access control.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the access control profile ID to activate.',
			properties: {
				'id': _kAccessControlIdSchema
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
					return service.selectAccessControl(args);
				},
				message: 'Successfully selected the access control profile.',
			);
		},
	);
	server.registerTool(
		'capture_access_control_create',
		title: 'Create Access Control Profile',
		description: 'Create a new Reqable access control profile and return the created access control profile.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the access control profile definition to create. The name and rules are required.',
			properties: {
				'name': _kAccessControlNameSchema,
				'rules': _kAccessControlRulesArraySchema,
		    'mode': _kAccessControlMode,
			},
			required: ['name', 'rules'],
		),
		outputSchema: _kAccessControlSchema,
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
      final CallToolResult? modeValidationError = validateRequiredStringArgument(
        args,
        key: 'mode',
        allowedValues: _kAccessControlMode.enumValues,
      );
      if (modeValidationError != null) {
        return modeValidationError;
      }
			return buildContentResult(
				apiCall: () {
					return service.createAccessControl(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the access control profile.';
				},
			);
		},
	);
	server.registerTool(
		'capture_access_control_delete',
		title: 'Delete Access Control Profiles',
		description: 'Permanently delete one or more access control profiles by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more access control profile IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
          title: 'Access Control Profile IDs',
          description: 'A list of access control profile IDs.',
					items: _kAccessControlIdSchema,
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
					return service.deleteAccessControls(args);
				},
				message: 'Successfully deleted the specified access control profiles.',
			);
		},
	);
	server.registerTool(
		'capture_access_control_update',
		title: 'Update Access Control Profile',
		description: 'Update an existing access control profile by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: _kAccessControlSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () {
					return service.updateAccessControl(args);
				},
				message: 'Successfully updated the access control profile.',
			);
		},
	);
}

class _CaptureAccessControlService {

	final ReqableApiClient client;

	const _CaptureAccessControlService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/access-control'
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/access-control/on'
					: '/capture/access-control/off'
			),
		);
	}

	Future<String> getActiveAccessControl() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/access-control/get-active'
			),
		);
	}

	Future<String> getAccessControlById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/access-control/lookup',
				jsonMap: args,
			),
		);
	}

	Future<void> selectAccessControl(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/access-control/select',
				jsonMap: args,
			),
		);
	}

	Future<String> createAccessControl(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/access-control/create',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteAccessControls(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/access-control/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateAccessControl(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/access-control/update',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kAccessControlIdSchema = JsonString(
  title: 'Access Control Profile ID',
  description: 'The unique ID of the access control profile.',
);

const JsonString _kAccessControlNameSchema = JsonString(
  title: 'Access Control Profile Name',
  description: 'The human-readable name of the access control profile.',
);

const JsonArray _kAccessControlRulesArraySchema = JsonArray(
  title: 'Rules',
  description: 'A list of access control rules.',
  items: JsonString(
    title: 'Rule',
    description: 'A rule is a string that matches one or more IP addresses (both IPv4 and IPv6), supports wildcards. For example, 192.168.0.* matches all IPs in the 192.168.0.x range.',
  ),
);

const JsonString _kAccessControlMode = JsonString(
  title: 'Mode',
  description: 'The access control mode.\n- Include: only allow the listed rules, block all others.\n- Exclude: block the listed rules, allow all others.',
  enumValues: ['include', 'exclude']
);

const JsonObject _kAccessControlSchema = ToolOutputSchema(
	title: 'Access Control Profile',
	description: 'The access control profile definition returned by Reqable.',
	properties: {
		'id': _kAccessControlIdSchema,
		'name': _kAccessControlNameSchema,
		'rules': _kAccessControlRulesArraySchema,
		'mode': _kAccessControlMode,
	},
	required: ['id', 'name', 'rules', 'mode'],
);

const JsonObject _kAccessControlConfigSchema = ToolOutputSchema(
	title: 'Access Control Configuration',
	description: 'The full Reqable access control configuration, including all access control profiles and the global enabled state.',
	properties: {
		'profiles': JsonArray(
			title: 'Access Control Profiles',
			description: 'The configured access control entries.',
			items: _kAccessControlSchema,
		),
		'index': JsonInteger(
			title: 'Active Index',
			description: 'The index of the currently active access control profile, or -1 when none is selected.',
			minimum: -1,
		),
		'isEnabled': JsonBoolean(
			title: 'Access Control Feature Enabled',
			description: 'Whether the global Reqable access control feature is currently enabled.',
		),
	},
	required: ['profiles', 'index', 'isEnabled'],
);