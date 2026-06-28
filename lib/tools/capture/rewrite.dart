import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp/api/client.dart';
import 'package:reqable_mcp/tools/result.dart';
import 'package:reqable_mcp/tools/schema.dart';
import 'package:reqable_mcp/tools/validate.dart';

void registerCaptureRewriteTools(McpServer server, ReqableApiClient client) {
	final _CaptureRewriteService service = _CaptureRewriteService(
		client: client,
	);
	server.registerTool(
		'capture_rewrite_get_config',
		title: 'Get Rewrite Configuration',
		description: 'Get the current Reqable rewrite configuration for redirecting, replacing, or modifying matched HTTP requests or responses.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kRewriteConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved rewrite configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_rewrite_set_enabled',
		title: 'Set Rewrite Feature Enabled State',
		description: 'Enable or disable the Reqable rewrite feature globally without changing any existing rewrite definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether the Reqable rewrite feature should be enabled.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the rewrite feature.',
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
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the rewrite feature.',
			);
		},
	);
	server.registerTool(
		'capture_rewrite_list',
		title: 'List Rewrites',
		description: 'List all Reqable rewrites as a flat list. Rewrite folders are not returned as items.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: ToolOutputSchema(
			title: 'Rewrite List',
			description: 'A flat list of all Reqable rewrites currently defined.',
			properties: {
				'items': JsonArray(
					title: 'Rewrites',
					description: 'A flat list of rewrite definitions.',
					items: _kRewriteSchema,
				),
			},
			required: ['items'],
		),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.listRewrites,
				contentBuilder: (jsonList) {
					return 'There are currently ${jsonList.length} rewrites defined.';
				},
			);
		},
	);
	server.registerTool(
		'capture_rewrite_set_item_enabled',
		title: 'Set Rewrites Enabled State',
		description: 'Enable or disable one or more rewrites by their IDs without changing their definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more rewrite IDs and whether they should be enabled.',
			properties: {
				'ids': JsonArray(
					items: _kRewriteIdSchema,
				),
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the specified rewrites.',
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
					return service.setRewritesEnabled(args);
				},
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the specified rewrites.',
			);
		},
	);
	server.registerTool(
		'capture_rewrite_get_by_id',
		title: 'Get Rewrite by ID',
		description: 'Retrieve a rewrite by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kRewriteSchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide a rewrite ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kRewriteIdSchema,
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
					return service.getRewriteById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the rewrite details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_rewrite_create',
		title: 'Create Rewrite',
		description: 'Create a new Reqable rewrite rule and return the created rewrite.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the rewrite definition to create. The name, url, and action are required.',
			properties: {
				'name': _kRewriteNameSchema,
				'method': _kRewriteMethodSchema,
				'url': _kRewriteUrlSchema,
				'folderId': _kRewriteFolderIdSchema,
				'wildcard': _kRewriteWildcardSchema,
				'action': _kRewriteActionSchema,
			},
			required: ['name', 'url', 'action'],
		),
		outputSchema: _kRewriteSchema,
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
      final CallToolResult? actionValidationError = validateRequiredObjectArgument(
        args,
        key: 'action',
      );
      if (actionValidationError != null) {
        return actionValidationError;
      }
			return buildContentResult(
				apiCall: () {
					return service.createRewrite(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the rewrite.';
				},
			);
		},
	);
	server.registerTool(
		'capture_rewrite_create_folder',
		title: 'Create Rewrite Folder',
		description: 'Create a new rewrite folder for organizing related Reqable rewrites and return the created folder.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the folder name for a new rewrite folder.',
			properties: {
				'name': _kRewriteFolderNameSchema,
			},
			required: ['name'],
		),
		outputSchema: _kRewriteFolderSchema,
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
					return service.createRewriteFolder(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the rewrite folder.';
				},
			);
		},
	);
	server.registerTool(
		'capture_rewrite_delete',
		title: 'Delete Rewrites',
		description: 'Permanently delete one or more rewrites by their IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more rewrite IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kRewriteIdSchema,
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
					return service.deleteRewrites(args);
				},
				message: 'Successfully deleted the specified rewrites.',
			);
		},
	);
	server.registerTool(
		'capture_rewrite_delete_folder',
		title: 'Delete Rewrite Folders',
		description: 'Permanently delete one or more rewrite folders by their IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more rewrite folder IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kRewriteFolderIdSchema,
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
					return service.deleteRewriteFolders(args);
				},
				message: 'Successfully deleted the specified rewrite folders.',
			);
		},
	);
	server.registerTool(
    'capture_rewrite_update',
    title: 'Update Rewrite',
    description: 'Update an existing rewrite by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: _kRewriteSchema,
    outputSchema: kMutationResultSchema,
    callback: (args, extra) {
      return buildVoidResult(
        apiCall: () {
          return service.updateRewrite(args);
        },
        message: 'Successfully updated the rewrite.',
      );
    },
  );
	server.registerTool(
		'capture_rewrite_update_folder_name',
		title: 'Rename Rewrite Folder',
		description: 'Rename an existing rewrite folder by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the rewrite folder ID and the new folder name.',
			properties: {
				'id': _kRewriteFolderIdSchema,
				'name': _kRewriteFolderNameSchema,
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
					return service.updateRewriteFolderName(args);
				},
				message: 'Successfully updated the rewrite folder name.',
			);
		},
	);
}

class _CaptureRewriteService {

	final ReqableApiClient client;

	const _CaptureRewriteService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/rewrite',
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/rewrite/on'
					: '/capture/rewrite/off'
			),
		);
	}

	Future<String> listRewrites() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/rewrite/list',
			),
		);
	}

	Future<void> setRewritesEnabled(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: args['enabled']
					? '/capture/rewrite/enable'
					: '/capture/rewrite/disable',
				jsonMap: args,
			),
		);
	}

	Future<String> getRewriteById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/rewrite/lookup',
				jsonMap: args,
			),
		);
	}

	Future<String> createRewrite(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/rewrite/create',
				jsonMap: args,
			),
		);
	}

	Future<String> createRewriteFolder(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/rewrite/folder/create',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteRewrites(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/rewrite/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteRewriteFolders(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/rewrite/folder/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateRewrite(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/rewrite/update',
				jsonMap: args,
			),
		);
	}

	Future<void> updateRewriteFolderName(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/rewrite/folder/rename',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kRewriteIdSchema = JsonString(
  title: 'Rewrite ID',
  description: 'The unique ID of a Reqable rewrite.',
);

const JsonString _kRewriteFolderIdSchema = JsonString(
  title: 'Rewrite Folder ID',
  description: 'The unique ID of a Reqable rewrite folder.',
);

const JsonString _kRewriteNameSchema = JsonString(
  title: 'Rewrite Name',
  description: 'The human-readable name of a Reqable rewrite.',
);

const JsonString _kRewriteFolderNameSchema = JsonString(
  title: 'Rewrite Folder Name',
  description: 'The human-readable name of a Reqable rewrite folder.',
);

const JsonString _kRewriteMethodSchema = JsonString(
  title: 'HTTP Method',
  description: 'The HTTP method filter for the rewrite, such as GET, POST, PUT, or DELETE. An empty string means any method.',
);

const JsonString _kRewriteUrlSchema = JsonString(
  title: 'HTTP URL Pattern',
  description: 'The HTTP URL or HTTP URL pattern matched by the rewrite.',
);

const JsonBoolean _kRewriteWildcardSchema = JsonBoolean(
  title: 'Use Wildcard Matching',
  description: 'Whether the HTTP URL pattern is interpreted as a wildcard pattern.',
  defaultValue: true,
);

const JsonObject _kRewriteModifyItemSchema = JsonObject(
	title: 'Rewrite Modify Item',
	description: 'A single enabled or disabled modify operation inside a rewrite modify action.',
	properties: {
		'id': JsonString(
			title: 'Modify Item ID',
			description: 'The unique ID of the modify item.',
		),
		'type': JsonInteger(
			title: 'Modify Type',
			description: 'The modify type index.\n- Modify Body(0): modify the request body.\n- Add Query(1): add a query parameter.\n- Modify Query(2): modify a query parameter.\n- Remove Query(3): remove a query parameter.\n- Add Header(4): add a header.\n- Modify Header(5): modify a header.\n- Remove Header(6): remove a header.',
			minimum: 0,
			maximum: 6,
		),
		'modify': JsonObject(
      title: 'Rewrite Modify Payload',
      description: 'The modify payload for a single modify item. The exact structure depends on the `type` value.',
      properties: {
        'pattern': JsonString(
          title: 'Match Pattern',
          description: 'Used by Modify Body(0), Modify Query(2) and Modify Header(5) types. The pattern to match in the request body for modification.',
        ),
        'replacement': JsonString(
          title: 'Replacement',
          description: 'Used by Modify Body(0), Modify Query(2) and Modify Header(5) types. The text to replace the matched pattern with.',
        ),
        'regex': JsonBoolean(
          title: 'Pattern Is Regex',
          description: 'Used by Modify Body(0), Modify Query(2) and Modify Header(5) types. Whether the match pattern is a regular expression.',
        ),
        'caseSensitive': JsonBoolean(
          title: 'Case Sensitive',
          description: 'Used by Modify Body(0), Modify Query(2) and Modify Header(5) types. Whether the match is case-sensitive.',
        ),
        'name': JsonString(
          title: 'Name',
          description: 'Used by Add Query(1) and Add Header(4) types. The name of the query parameter or header to add.',
        ),
        'value': JsonString(
          title: 'Value',
          description: 'Used by Add Query(1) and Add Header(4) types. The value of the query parameter or header to add.',
        ),
        'pattern1': JsonString(
          title: 'Name Match Pattern',
          description: 'Used by Remove Query(3) and Remove Header(6) types. The pattern to match for the name of the query parameter or header to remove.',
        ),
        'pattern2': JsonString(
          title: 'Value Match Pattern',
          description: 'Used by Remove Query(3) and Remove Header(6) types. The pattern to match for the value of the query parameter or header to remove.',
        ),
        'regex1': JsonBoolean(
          title: 'Name Pattern Is Regex',
          description: 'Used by Remove Query(3) and Remove Header(6) types. Whether the name pattern is a regular expression.',
        ),
        'regex2': JsonBoolean(
          title: 'Value Pattern Is Regex',
          description: 'Used by Remove Query(3) and Remove Header(6) types. Whether the value pattern is a regular expression.',
        ),
        'caseSensitive1': JsonBoolean(
          title: 'Name Pattern Is Case Sensitive',
          description: 'Used by Remove Query(3) and Remove Header(6) types. Whether the name pattern is case sensitive.',
        ),
        'caseSensitive2': JsonBoolean(
          title: 'Value Pattern Is Case Sensitive',
          description: 'Used by Remove Query(3) and Remove Header(6) types. Whether the value pattern is case sensitive.',
        ),
      },
    ),
		'isEnabled': JsonBoolean(
			title: 'Is Enabled',
			description: 'Whether this modify item is currently enabled.',
		),
	},
	required: ['id', 'type', 'modify', 'isEnabled'],
);

const JsonObject _kRewriteActionSchema = JsonObject(
	title: 'Rewrite Action',
	description: 'The action performed when a rewrite rule matches. The exact fields used depend on the action type.',
	properties: {
		'type': JsonInteger(
			title: 'Action Type',
			description: 'The rewrite action type index.\n- Redirect(0): Redirect matching HTTP requests to a different URL.\n- Replace Request(1): Replace the HTTP request path, headers and body with the preset values.\n- Replace Response(2): Replace the HTTP response code, headers and body with the preset values.\n- Modify Request(3): Dynamically modify HTTP request parameters, headers and body with matchers such as regular expressions.\n- Modify Response(4): Dynamically modify HTTP response headers and body with matchers such as regular expressions.',
			minimum: 0,
			maximum: 4,
		),
		'redirectUrl': JsonString(
			title: 'Redirect URL',
			description: 'Used by Redirect(0) actions. The new URL to redirect to.',
		),
		'preserveHost': JsonBoolean(
			title: 'Preserve Host',
			description: 'Used by Redirect(0) actions. Whether to preserve the original Host header.',
		),
		'excludeUrl': JsonString(
			title: 'Exclude URL Pattern',
			description: 'Used by Redirect(0) actions. Matching URLs are excluded from redirect processing.',
		),
		'excludeWildcard': JsonBoolean(
			title: 'Use Wildcard Exclusion',
			description: 'Used by Redirect(0) actions. Whether excludeUrl should be treated as a wildcard pattern.',
		),
    'headers': JsonArray(
			title: 'Headers',
			description: 'Used by Replace Request(1) and Replace Response(2) actions. A list of HTTP header key-value pairs.',
			items: kStringEntrySchema,
		),
		'body': JsonObject(
      title: 'Rewrite Replace Body',
      description: 'A body payload used by replace HTTP request or replace HTTP response actions.',
      properties: {
        'type': JsonInteger(
          title: 'Body Type',
          description: 'The body type index.\n- None(0): No body.\n- Text(1): A text body.\n- Binary(2): A binary file body.',
          minimum: 0,
          maximum: 2,
          defaultValue: 0,
        ),
        'payload': JsonString(
          title: 'Payload',
          description: 'The body content.\n- None(0): Should be empty.\n- Text(1): The text content of the body.\n- Binary(2): The file path of the binary body content.',
        ),
      },
      required: ['type', 'payload'],
    ),
		'method': JsonString(
			title: 'Replacement Request Method',
			description: 'Used by Replace Request(1) actions. The new request method to send.',
		),
		'path': JsonString(
			title: 'Replacement Request Path',
			description: 'Used by Replace Request(1) actions. The new request path to send.',
		),
    'requestLineEnabled': JsonBoolean(
			title: 'Request Line Enabled',
			description: 'Used by Replace Request(1) actions. Whether the request line rewrite is enabled.',
		),
		'code': JsonInteger(
			title: 'Replacement Response Status Code',
			description: 'Used by Replace Response(2) actions. The new HTTP status code to return.',
		),
    'statusLineEnabled': JsonBoolean(
			title: 'Status Line Enabled',
			description: 'Used by Replace Response(2) actions. Whether the status code rewrite is enabled.',
		),
    'headersEnabled': JsonBoolean(
			title: 'Headers Enabled',
			description: 'Used by Replace Request(1) and Replace Response(2) actions. Whether header replacement is enabled.',
		),
		'bodyEnabled': JsonBoolean(
			title: 'Body Enabled',
			description: 'Used by Replace Request(1) and Replace Response(2) actions. Whether body replacement is enabled.',
		),
		'modifies': JsonArray(
			title: 'Modify Items',
			description: 'Used by Modify Request(3) and Modify Response(4) actions. The list of modify operations to apply.',
			items: _kRewriteModifyItemSchema,
		),
	},
	required: ['type'],
);

const JsonObject _kRewriteSchema = ToolOutputSchema(
	title: 'Rewrite',
	description: 'The rewrite definition returned by Reqable.',
	properties: {
		'id': _kRewriteIdSchema,
		'name': _kRewriteNameSchema,
		'method': _kRewriteMethodSchema,
		'url': _kRewriteUrlSchema,
		'wildcard': _kRewriteWildcardSchema,
		'action': _kRewriteActionSchema,
		'isEnabled': JsonBoolean(
			title: 'Is Enabled',
			description: 'Whether the rewrite itself is currently enabled.',
		),
	},
	required: ['id', 'name', 'method', 'url', 'wildcard', 'action', 'isEnabled'],
);

const JsonObject _kRewriteFolderSchema = ToolOutputSchema(
	title: 'Rewrite Folder',
	description: 'A folder containing multiple rewrites.',
	properties: {
		'id': _kRewriteFolderIdSchema,
		'name': _kRewriteFolderNameSchema,
		'items': JsonArray(
			title: 'Rewrites',
			description: 'The rewrites contained within this folder.',
			items: _kRewriteSchema,
		),
	},
	required: ['id', 'name', 'items'],
);

const JsonObject _kRewriteConfigSchema = ToolOutputSchema(
	title: 'Rewrite Configuration',
	description: 'The full Reqable rewrite configuration, including top-level rewrites, folders, and the global enabled state.',
	properties: {
		'rewrites': JsonArray(
			title: 'Rewrite Entries',
			description: 'Top-level rewrite entries. Each entry is either a rewrite or a folder containing rewrites.',
			items: JsonObject(
				title: 'Rewrite Configuration Item',
				description: 'A top-level rewrite entry, which can be a rewrite or a folder containing rewrites.',
				properties: {
					'id': JsonString(
						title: 'Item ID',
						description: 'The unique ID of the rewrite or rewrite folder.',
					),
					'name': JsonString(
						title: 'Item Name',
						description: 'The human-readable name of the rewrite or rewrite folder.',
					),
					'method': _kRewriteMethodSchema,
					'url': _kRewriteUrlSchema,
					'wildcard': _kRewriteWildcardSchema,
					'action': _kRewriteActionSchema,
					'isEnabled': JsonBoolean(
						title: 'Is Enabled',
						description: 'Whether the rewrite item is currently enabled.',
					),
					'items': JsonArray(
						title: 'Folder Rewrites',
						description: 'The rewrites contained in this folder. Folders do not contain nested folders.',
						items: _kRewriteSchema,
					),
					'collapsed': JsonBoolean(
						title: 'Is Collapsed',
						description: 'Whether the rewrite folder is currently collapsed in the UI.',
					),
				},
				required: ['id', 'name'],
			),
		),
		'isEnabled': JsonBoolean(
			title: 'Rewrite Feature Enabled',
			description: 'Whether the global Reqable rewrite feature is currently enabled.',
		),
	},
	required: ['rewrites', 'isEnabled'],
);
