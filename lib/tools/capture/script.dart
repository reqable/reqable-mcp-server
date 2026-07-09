import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureScriptTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.captureScript)) {
		return;
	}
	final _CaptureScriptService service = _CaptureScriptService(
		client: client
	);
	server.registerTool(
		'capture_script_get_config',
		title: 'Get Script Configuration',
		description: 'Get the current Reqable script configuration for executing custom logic on matched HTTP requests or responses.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kScriptConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved script configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_script_set_enabled',
		title: 'Set Script Feature Enabled State',
		description: 'Enable or disable the Reqable script feature globally without changing any existing script definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether the Reqable script feature should be enabled.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the script feature.',
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
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the script feature.',
			);
		},
	);
  if (scope == ReqableToolScope.all) {
    server.registerTool(
      'capture_script_list',
      title: 'List Scripts',
      description: 'List all Reqable scripts as a flat list. Script folders are not returned as items.',
      annotations: ToolAnnotations(
        readOnlyHint: true,
      ),
      outputSchema: ToolOutputSchema(
        title: 'Script List',
        description: 'A flat list of all Reqable scripts currently defined.',
        properties: {
          'items': JsonArray(
            title: 'Scripts',
            description: 'A flat list of script definitions.',
            items: _kScriptSchema,
          ),
        },
        required: ['items'],
      ),
      callback: (args, extra) {
        return buildContentResult(
          apiCall: service.listScripts,
          contentBuilder: (jsonList) {
            return 'There are currently ${jsonList.length} scripts defined.';
          },
        );
      },
    );
  }
  if (scope == ReqableToolScope.all) {
    server.registerTool(
      'capture_script_set_item_enabled',
      title: 'Set Scripts Enabled State',
      description: 'Enable or disable one or more scripts by their IDs without changing their definitions.',
      annotations: ToolAnnotations(
        readOnlyHint: false,
        destructiveHint: false,
        idempotentHint: true,
      ),
      inputSchema: const ToolInputSchema(
        description: 'Provide one or more script IDs and whether they should be enabled.',
        properties: {
          'ids': JsonArray(
            items: _kScriptIdSchema
          ),
          'enabled': JsonBoolean(
            title: 'Enabled',
            description: 'Whether to enable the specified scripts.',
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
            return service.setScriptsEnabled(args);
          },
          message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the specified scripts.',
        );
      },
    );
  }
	server.registerTool(
		'capture_script_get_by_id',
		title: 'Get Script by ID',
		description: 'Retrieve a script by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kScriptSchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide a script ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kScriptIdSchema
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
					return service.getScriptById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the script details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_script_create',
		title: 'Create Script',
		description: 'Create a new Reqable Python script rule for matching traffic and return the created script. Before generating script code, always call tools or resources `script_framework` and script_template`.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the script definition to create. The name, url, and code are required.',
			properties: {
				'name': _kScriptNameSchema,
				'method': _kScriptMethodSchema,
				'url': _kScriptUrlSchema,
				'folderId': _kScriptFolderIdSchema,
				'wildcard': _kScriptWildcardSchema,
				'code': _kScriptCodeSchema,
			},
			required: ['name', 'url', 'code'],
		),
		outputSchema: _kScriptSchema,
		callback: (args, extra) {
			final CallToolResult? nameValidationError = validateRequiredStringArgument(
        args,
        key: 'name',
      );
      if (nameValidationError != null) {
        return nameValidationError;
      }
      final CallToolResult? urlValidationError = validateRequiredStringArgument(
        args,
        key: 'url',
      );
      if (urlValidationError != null) {
        return urlValidationError;
      }
      final CallToolResult? codeValidationError = validateRequiredStringArgument(
        args,
        key: 'code',
      );
      if (codeValidationError != null) {
        return codeValidationError;
      }
			return buildContentResult(
				apiCall: () {
					return service.createScript(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the script.';
				},
			);
		},
	);
  if (scope == ReqableToolScope.all) {
    server.registerTool(
      'capture_script_create_folder',
      title: 'Create Script Folder',
      description: 'Create a new script folder for organizing related Reqable scripts and return the created folder.',
      annotations: ToolAnnotations(
        readOnlyHint: false,
        destructiveHint: false,
        idempotentHint: false,
      ),
      inputSchema: const ToolInputSchema(
        description: 'Provide the folder name for a new script folder.',
        properties: {
          'name': _kScriptFolderNameSchema,
        },
        required: ['name'],
      ),
      outputSchema: _kScriptFolderSchema,
      callback: (args, extra) {
        final CallToolResult? validationError = validateRequiredStringArgument(
          args,
          key: 'name',
        );
        if (validationError != null) {
          return validationError;
        }
        return buildContentResult(
          apiCall: () {
            return service.createScriptFolder(args);
          },
          contentBuilder: (_) {
            return 'Successfully created the script folder.';
          },
        );
      },
    );
  }
	server.registerTool(
		'capture_script_delete',
		title: 'Delete Scripts',
		description: 'Permanently delete one or more scripts by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more script IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kScriptIdSchema
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
					return service.deleteScripts(args);
				},
				message: 'Successfully deleted the specified scripts.',
			);
		},
	);
  if (scope == ReqableToolScope.all) {
    server.registerTool(
      'capture_script_delete_folder',
      title: 'Delete Script Folders',
      description: 'Permanently delete one or more script folders by ID.',
      annotations: ToolAnnotations(
        readOnlyHint: false,
        destructiveHint: true,
        idempotentHint: false,
      ),
      inputSchema: const ToolInputSchema(
        description: 'Provide one or more script folder IDs to delete permanently.',
        properties: {
          'ids': JsonArray(
            items: _kScriptFolderIdSchema
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
            return service.deleteScriptFolders(args);
          },
          message: 'Successfully deleted the specified script folders.',
        );
      },
    );
  }
	server.registerTool(
    'capture_script_update',
    title: 'Update Script',
    description: 'Update an existing script by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: _kScriptSchema,
    outputSchema: kMutationResultSchema,
    callback: (args, extra) {
      return buildVoidResult(
        apiCall: () {
          return service.updateScript(args);
        },
        message: 'Successfully updated the script.',
      );
    },
  );
  if (scope == ReqableToolScope.all) {
    server.registerTool(
      'capture_script_update_folder_name',
      title: 'Rename Script Folder',
      description: 'Rename an existing script folder by ID.',
      annotations: ToolAnnotations(
        readOnlyHint: false,
        destructiveHint: false,
        idempotentHint: true,
      ),
      inputSchema: const ToolInputSchema(
        description: 'Provide the script folder ID and the new folder name.',
        properties: {
          'id': _kScriptFolderIdSchema,
          'name': _kScriptFolderNameSchema,
        },
        required: ['id', 'name'],
      ),
      outputSchema: kMutationResultSchema,
      callback: (args, extra) {
        final CallToolResult? idValidationError = validateRequiredStringArgument(
          args,
          key: 'id',
        );
        if (idValidationError != null) {
          return idValidationError;
        }
        final CallToolResult? nameValidationError = validateRequiredStringArgument(
          args,
          key: 'name',
        );
        if (nameValidationError != null) {
          return nameValidationError;
        }
        return buildVoidResult(
          apiCall: () {
            return service.updateScriptFolderName(args);
          },
          message: 'Successfully updated the script folder name.',
        );
      },
    );
  }
}

class _CaptureScriptService {

	final ReqableApiClient client;

	const _CaptureScriptService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/script'
			),
		);
	}

	Future<String> getFramework() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/script/framework'
			),
		);
	}

	Future<String> getTemplate() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/script/template'
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/script/on'
					: '/capture/script/off'
			),
		);
	}

	Future<String> listScripts() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/script/list'
			),
		);
	}

	Future<void> setScriptsEnabled(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: args['enabled']
					? '/capture/script/enable'
					: '/capture/script/disable',
				jsonMap: args,
			),
		);
	}

	Future<String> getScriptById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/script/lookup',
				jsonMap: args,
			),
		);
	}

	Future<String> createScript(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/script/create',
				jsonMap: args,
			),
		);
	}

	Future<String> createScriptFolder(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/script/folder/create',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteScripts(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/script/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteScriptFolders(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/script/folder/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateScript(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/script/update',
				jsonMap: args,
			),
		);
	}

	Future<void> updateScriptFolderName(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/script/folder/rename',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kScriptIdSchema = JsonString(
  title: 'Script ID',
  description: 'The unique ID of a Reqable script.',
);

const JsonString _kScriptFolderIdSchema = JsonString(
  title: 'Script Folder ID',
  description: 'The unique ID of a Reqable script folder.',
);

const JsonString _kScriptNameSchema = JsonString(
  title: 'Script Name',
  description: 'The human-readable name of a Reqable script.',
);

const JsonString _kScriptFolderNameSchema = JsonString(
  title: 'Script Folder Name',
  description: 'The human-readable name of a Reqable script folder.',
);

const JsonString _kScriptMethodSchema = JsonString(
  title: 'HTTP Method',
  description: 'The HTTP method filter for the script, such as GET, POST, PUT, or DELETE. An empty string means any method.',
);

const JsonString _kScriptUrlSchema = JsonString(
  title: 'HTTP URL Pattern',
  description: 'The HTTP URL or HTTP URL pattern matched by the script.',
);

const JsonBoolean _kScriptWildcardSchema = JsonBoolean(
  title: 'Use Wildcard Matching',
  description: 'Whether the HTTP URL pattern is interpreted as a wildcard pattern.',
  defaultValue: true,
);

const JsonString _kScriptCodeSchema = JsonString(
  title: 'Script Code',
  description: 'The Python script code.',
);

const JsonObject _kScriptSchema = ToolOutputSchema(
	title: 'Script',
	description: 'The script definition returned by Reqable.',
	properties: {
		'id': _kScriptIdSchema,
		'name': _kScriptNameSchema,
		'method': _kScriptMethodSchema,
		'url': _kScriptUrlSchema,
		'wildcard': _kScriptWildcardSchema,
    'code': _kScriptCodeSchema,
		'isEnabled': JsonBoolean(
			title: 'Is Enabled',
			description: 'Whether the script itself is currently enabled.',
		),
	},
	required: ['id', 'name', 'method', 'url', 'wildcard', 'code', 'isEnabled'],
);


const JsonObject _kScriptFolderSchema = ToolOutputSchema(
	title: 'Script Folder',
	description: 'A folder containing multiple scripts.',
	properties: {
		'id': _kScriptFolderIdSchema,
		'name': _kScriptFolderNameSchema,
		'items': JsonArray(
			title: 'Scripts',
			description: 'The scripts contained within this folder.',
			items: _kScriptSchema,
		),
	},
	required: ['id', 'name', 'items'],
);

const JsonObject _kScriptConfigSchema = ToolOutputSchema(
	title: 'Script Configuration',
	description: 'The full Reqable script configuration, including top-level scripts, folders, and the global enabled state.',
	properties: {
		'scripts': JsonArray(
			title: 'Script Entries',
			description: 'Top-level script entries. Each entry is either a script or a folder containing scripts.',
			items: JsonObject(
				title: 'Script Configuration Item',
				description: 'A top-level script entry, which can be a script or a folder containing scripts.',
				properties: {
					'id': JsonString(
						title: 'Item ID',
						description: 'The unique ID of the script or script folder.',
					),
					'name': JsonString(
						title: 'Item Name',
						description: 'The human-readable name of the script or script folder.',
					),
					'method': _kScriptMethodSchema,
					'url': _kScriptUrlSchema,
					'wildcard': _kScriptWildcardSchema,
					'code': _kScriptCodeSchema,
					'isEnabled': JsonBoolean(
						title: 'Is Enabled',
						description: 'Whether the script item is currently enabled.',
					),
					'items': JsonArray(
						title: 'Folder Scripts',
						description: 'The scripts contained in this folder. Folders do not contain nested folders.',
						items: _kScriptSchema,
					),
					'collapsed': JsonBoolean(
						title: 'Is Collapsed',
						description: 'Whether the script folder is currently collapsed in the UI.',
					),
				},
				required: ['id', 'name'],
			),
		),
		'isEnabled': JsonBoolean(
			title: 'Script Feature Enabled',
			description: 'Whether the global Reqable script feature is currently enabled.',
		),
	},
	required: ['scripts', 'isEnabled'],
);
