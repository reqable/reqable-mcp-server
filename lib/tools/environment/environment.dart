import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp/api/client.dart';
import 'package:reqable_mcp/tools/result.dart';
import 'package:reqable_mcp/tools/schema.dart';
import 'package:reqable_mcp/tools/validate.dart';

void registerEnvironmentTools(McpServer server, ReqableApiClient client) {
	final _EnvironmentService service = _EnvironmentService(client: client);
	server.registerTool(
		'environment_list',
		title: 'List All Environments',
		description: 'List all Reqable environments, including the global environment and user-defined environments, and indicate which environment is currently active.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kEnvironmentListSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.listEnvironments,
				contentBuilder: (jsonMap) {
					return 'Successfully retrieved the environments.';
				},
			);
		},
	);
	server.registerTool(
		'environment_get_by_id',
		title: 'Get Environment By ID',
		description: 'Get a Reqable environment by environment ID.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: _kEnvironmentIdInputSchema,
		outputSchema: _kEnvironmentSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'id',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () => service.getEnvironment(args),
				contentBuilder: (_) {
					return 'Successfully retrieved the environment.';
				},
			);
		},
	);
	server.registerTool(
		'environment_get_active',
		title: 'Get Active Environment',
		description: 'Get the currently active Reqable environment.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kActiveEnvironmentSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getActiveEnvironment,
				contentBuilder: (jsonObject) {
					return jsonObject['environment'] == null
						? 'No active environment is currently selected.'
						: 'Successfully retrieved the active environment.';
				},
			);
		},
	);
	server.registerTool(
		'environment_create',
		title: 'Create Environment',
		description: 'Create a new Reqable environment.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: _kEnvironmentCreateInputSchema,
		outputSchema: _kIdResultSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () => service.createEnvironment(args),
				contentBuilder: (_) {
					return 'Successfully created the environment.';
				},
			);
		},
	);
	server.registerTool(
		'environment_update',
		title: 'Update Environment',
		description: 'Update a Reqable environment payload.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: _kEnvironmentSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () => service.updateEnvironment(args),
				message: 'Successfully updated the environment.',
			);
		},
	);
	server.registerTool(
		'environment_delete',
		title: 'Delete Environment',
		description: 'Delete a Reqable environment by environment ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: _kEnvironmentIdInputSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'id',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildVoidResult(
				apiCall: () => service.deleteEnvironment(args),
				message: 'Successfully deleted the environment.',
			);
		},
	);
  server.registerTool(
		'environment_select',
		title: 'Select Environment',
		description: 'Select a Reqable environment by environment ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: _kEnvironmentIdInputSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'id',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildVoidResult(
				apiCall: () => service.selectEnvironment(args),
				message: 'Successfully selected the environment.',
			);
		},
	);
	server.registerTool(
		'environment_builtin_variables',
		title: 'List Built-in Variables',
		description: 'List built-in environment variables exposed by Reqable.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kBuiltInVariablesSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.listBuiltInVariables,
				contentBuilder: (jsonList) {
					return 'Found ${jsonList.length} built-in variables.';
				},
			);
		},
	);
}

class _EnvironmentService {

	final ReqableApiClient client;

	const _EnvironmentService({
		required this.client,
	});

	Future<String> listEnvironments() {
		return client.sendGetRequest(
			const VoidRequest(route: '/environment'),
		);
	}

	Future<String> getEnvironment(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/environment/get', jsonMap: args),
		);
	}

	Future<String> getActiveEnvironment() {
		return client.sendGetRequest(
			const VoidRequest(route: '/environment/get-active'),
		);
	}

	Future<String> createEnvironment(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/environment/create', jsonMap: {
				'name': args['name'],
			}),
		);
	}

	Future<void> updateEnvironment(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/environment/update', jsonMap: args),
		);
	}

	Future<void> deleteEnvironment(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/environment/delete', jsonMap: args),
		);
	}

  Future<void> selectEnvironment(Map<String, dynamic> args) async {
    await client.sendPostRequest(
      JsonRequest(route: '/environment/select', jsonMap: args),
    );
  }

	Future<String> listBuiltInVariables() {
		return client.sendGetRequest(
			const VoidRequest(route: '/environment/built-in-variables'),
		);
	}

}

const List<String> _kEnvironmentTagValues = [
	'unset',
	'green',
	'teal',
	'blue',
	'indigo',
	'yellow',
	'orange',
	'purple',
	'pink',
	'red',
];

const JsonObject _kEnvironmentIdInputSchema = ToolInputSchema(
	title: 'Environment Identifier',
	description: 'The identifier of the environment.',
	properties: {
		'id': JsonString(
			title: 'Environment ID',
			description: 'The environment ID.',
		),
	},
	required: ['id'],
);

const JsonObject _kEnvironmentCreateInputSchema = ToolInputSchema(
	title: 'Create Environment Payload',
	description: 'The payload used to create a new environment.',
	properties: {
		'name': JsonString(
			title: 'Environment Name',
			description: 'The new environment name.',
		),
	},
	required: ['name'],
);

const JsonObject _kIdResultSchema = ToolOutputSchema(
	title: 'Identifier Result',
	description: 'The identifier returned by Reqable.',
	properties: {
		'id': JsonString(
			title: 'ID',
			description: 'The environment identifier.',
		),
	},
	required: ['id'],
);

const JsonObject _kEnvironmentListSchema = ToolOutputSchema(
	title: 'Environment List',
	description: 'The environments returned by Reqable.',
	properties: {
		'environments': JsonArray(
			title: 'Environments',
			description: 'The environment list.',
			items: _kEnvironmentSchema,
		),
    'activatedId': JsonString(
      title: 'Activated Environment ID',
      description: 'The currently activated environment ID, or an empty string if no environment is selected.',
    ),
	},
	required: ['environments', 'activatedId'],
);

const JsonObject _kActiveEnvironmentSchema = ToolOutputSchema(
	title: 'Active Environment',
	description: 'The currently active environment, if one is selected.',
	properties: {
		'environment': JsonOneOf(
			[
				_kEnvironmentSchema,
				JsonNull(),
			],
			title: 'Environment',
			description: 'The active environment or null when nothing is selected.',
		),
	},
	required: ['environment'],
);

const JsonObject _kEnvironmentSchema = ToolInputSchema(
	title: 'Environment',
	description: 'A Reqable environment payload.',
	properties: {
		'id': JsonString(
			title: 'Environment ID',
			description: 'The environment identifier. `environment-global` is the ID of the global environment.',
		),
		'name': JsonString(
			title: 'Name',
			description: 'The environment name. The global environment uses an empty name.',
		),
		'tag': JsonString(
			title: 'Tag',
			description: 'The display tag color for the environment.',
			enumValues: _kEnvironmentTagValues,
		),
		'variables': JsonArray(
			title: 'Variables',
			description: 'The environment variables.',
			items: _kEnvironmentVariableSchema,
		),
	},
	required: ['id', 'name', 'variables'],
	additionalProperties: true,
);

const JsonObject _kEnvironmentVariableSchema = JsonObject(
	title: 'Environment Variable',
	description: 'A user-defined environment variable. The variable can be used in Reqable with the syntax `<<name>>`.',
	properties: {
		'name': JsonString(
			title: 'Variable Name',
			description: 'The variable name.',
		),
		'value': JsonString(
			title: 'Variable Value',
			description: 'The variable value.',
		),
		'secret': JsonBoolean(
			title: 'Secret',
			description: 'Whether the variable value should be treated as a secret.',
		),
		'enabled': JsonBoolean(
			title: 'Enabled',
			description: 'Whether the variable is enabled.',
		),
	},
	required: ['name', 'value', 'secret', 'enabled'],
	additionalProperties: true,
);

const JsonObject _kBuiltInVariablesSchema = ToolOutputSchema(
	title: 'Built-in Variables',
	description: 'The built-in dynamic variables available in Reqable.',
	properties: {
		'items': JsonArray(
			title: 'Variables',
			description: 'The built-in dynamic variables.',
			items: _kBuiltInVariableSchema,
		),
	},
	required: ['items'],
);

const JsonObject _kBuiltInVariableSchema = JsonObject(
	title: 'Built-in Variable',
	description: 'A built-in dynamic variable definition. The variable can be used in Reqable with the syntax `<<\$name>>`.',
	properties: {
		'name': JsonString(
			title: 'Name',
			description: 'The built-in variable name.',
		),
		'description': JsonString(
			title: 'Description',
			description: 'The built-in variable description.',
		),
	},
	required: ['name', 'description'],
);
