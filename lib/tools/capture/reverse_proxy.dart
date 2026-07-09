import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureReverseProxyTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.captureReverseProxy)) {
		return;
	}
	final _CaptureReverseProxyService service = _CaptureReverseProxyService(
		client: client
	);
	server.registerTool(
		'capture_reverse_proxy_get_config',
		title: 'Get Reverse Proxy Configuration',
		description: 'Get the current Reqable reverse proxy configuration for exposing local ports that forward traffic to remote destinations.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kReverseProxyConfigSchema,
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getConfig,
				contentBuilder: (_) {
					return 'Successfully retrieved reverse proxy configuration.';
				},
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_set_enabled',
		title: 'Set Reverse Proxy Feature Enabled State',
		description: 'Enable or disable the Reqable reverse proxy feature globally without changing any existing reverse proxy definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether the Reqable reverse proxy feature should be enabled.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the reverse proxy feature.',
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
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the reverse proxy feature.',
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_list',
		title: 'List Reverse Proxies',
		description: 'List all Reqable reverse proxies as a flat list. Reverse proxy folders are not returned as items.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: ToolOutputSchema(
			title: 'Reverse Proxy List',
			description: 'A flat list of all Reqable reverse proxies currently defined.',
			properties: {
				'items': JsonArray(
					title: 'Reverse Proxies',
					description: 'A flat list of reverse proxy definitions.',
					items: _kReverseProxySchema,
				),
			},
			required: ['items'],
		),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.listReverseProxies,
				contentBuilder: (jsonList) {
					return 'There are currently ${jsonList.length} reverse proxies defined.';
				},
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_set_item_enabled',
		title: 'Set Reverse Proxies Enabled State',
		description: 'Enable or disable one or more reverse proxies by their IDs without changing their definitions.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more reverse proxy IDs and whether they should be enabled.',
			properties: {
				'ids': JsonArray(
					items: _kReverseProxyIdSchema
				),
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to enable the specified reverse proxies.',
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
					return service.setReverseProxiesEnabled(args);
				},
				message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the specified reverse proxies.',
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_lookup',
		title: 'Get Reverse Proxy by ID',
		description: 'Retrieve a reverse proxy by ID and return its full details.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: _kReverseProxySchema,
		inputSchema: const ToolInputSchema(
			description: 'Provide a reverse proxy ID to retrieve its latest details from Reqable.',
			properties: {
				'id': _kReverseProxyIdSchema,
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
					return service.getReverseProxyById(args);
				},
				contentBuilder: (_) {
					return 'Successfully retrieved the reverse proxy details.';
				},
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_create',
		title: 'Create Reverse Proxy',
		description: 'Create a new Reqable reverse proxy definition and return the created reverse proxy.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the reverse proxy definition to create. The name and host are required.',
			properties: {
				'name': _kReverseProxyNameSchema,
				'localPort': _kReverseProxyLocalPortSchema,
				'host': _kReverseProxyHostSchema,
				'security': _kReverseProxySecuritySchema,
				'preserveHost': _kReverseProxyPreserveHostSchema,
				'folderId': _kReverseProxyFolderIdSchema,
			},
			required: ['name', 'host'],
		),
		outputSchema: _kReverseProxySchema,
		callback: (args, extra) {
			final CallToolResult? nameValidationError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (nameValidationError != null) {
				return nameValidationError;
			}
			final dynamic localPort = args['localPort'];
			if (localPort != null) {
				final CallToolResult? localPortValidationError = validateRequiredIntArgument(
					args,
					key: 'localPort',
					minimum: 1024,
					maximum: 65535,
				);
				if (localPortValidationError != null) {
					return localPortValidationError;
				}
			}
			final CallToolResult? hostValidationError = validateRequiredStringArgument(
				args,
				key: 'host',
			);
			if (hostValidationError != null) {
				return hostValidationError;
			}
			final dynamic security = args['security'];
			if (security != null) {
				final CallToolResult? securityValidationError = validateRequiredBoolArgument(
					args,
					key: 'security',
				);
				if (securityValidationError != null) {
					return securityValidationError;
				}
			}
			final dynamic preserveHost = args['preserveHost'];
			if (preserveHost != null) {
				final CallToolResult? preserveHostValidationError = validateRequiredBoolArgument(
					args,
					key: 'preserveHost',
				);
				if (preserveHostValidationError != null) {
					return preserveHostValidationError;
				}
			}
			final dynamic folderId = args['folderId'];
			if (folderId != null) {
				final CallToolResult? folderIdValidationError = validateRequiredStringArgument(
					args,
					key: 'folderId',
				);
				if (folderIdValidationError != null) {
					return folderIdValidationError;
				}
			}
			return buildContentResult(
				apiCall: () {
					return service.createReverseProxy(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the reverse proxy.';
				},
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_create_folder',
		title: 'Create Reverse Proxy Folder',
		description: 'Create a new reverse proxy folder for organizing related Reqable reverse proxies and return the created folder.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the folder name for a new reverse proxy folder.',
			properties: {
				'name': _kReverseProxyFolderNameSchema,
			},
			required: ['name'],
		),
		outputSchema: _kReverseProxyFolderSchema,
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
					return service.createReverseProxyFolder(args);
				},
				contentBuilder: (_) {
					return 'Successfully created the reverse proxy folder.';
				},
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_delete',
		title: 'Delete Reverse Proxies',
		description: 'Permanently delete one or more reverse proxies by their IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more reverse proxy IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kReverseProxyIdSchema
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
					return service.deleteReverseProxies(args);
				},
				message: 'Successfully deleted the specified reverse proxies.',
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_delete_folder',
		title: 'Delete Reverse Proxy Folders',
		description: 'Permanently delete one or more reverse proxy folders by their IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide one or more reverse proxy folder IDs to delete permanently.',
			properties: {
				'ids': JsonArray(
					items: _kReverseProxyFolderIdSchema
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
					return service.deleteReverseProxyFolders(args);
				},
				message: 'Successfully deleted the specified reverse proxy folders.',
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_update',
		title: 'Update Reverse Proxy',
		description: 'Update an existing reverse proxy by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: _kReverseProxySchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () {
					return service.updateReverseProxy(args);
				},
				message: 'Successfully updated the reverse proxy.',
			);
		},
	);
	server.registerTool(
		'capture_reverse_proxy_update_folder_name',
		title: 'Rename Reverse Proxy Folder',
		description: 'Rename an existing reverse proxy folder by ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the reverse proxy folder ID and the new folder name.',
			properties: {
				'id': _kReverseProxyFolderIdSchema,
				'name': _kReverseProxyFolderNameSchema,
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
					return service.updateReverseProxyFolderName(args);
				},
				message: 'Successfully updated the reverse proxy folder name.',
			);
		},
	);
}

class _CaptureReverseProxyService {

	final ReqableApiClient client;

	const _CaptureReverseProxyService({
		required this.client,
	});

	Future<String> getConfig() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/reverse-proxy'
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/reverse-proxy/on'
					: '/capture/reverse-proxy/off'
			),
		);
	}

	Future<String> listReverseProxies() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/reverse-proxy/list'
			),
		);
	}

	Future<void> setReverseProxiesEnabled(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: args['enabled']
					? '/capture/reverse-proxy/enable'
					: '/capture/reverse-proxy/disable',
				jsonMap: args,
			),
		);
	}

	Future<String> getReverseProxyById(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/reverse-proxy/lookup',
				jsonMap: args,
			),
		);
	}

	Future<String> createReverseProxy(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/reverse-proxy/create',
				jsonMap: args,
			),
		);
	}

	Future<String> createReverseProxyFolder(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/reverse-proxy/folder/create',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteReverseProxies(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/reverse-proxy/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> deleteReverseProxyFolders(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/reverse-proxy/folder/delete',
				jsonMap: args,
			),
		);
	}

	Future<void> updateReverseProxy(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/reverse-proxy/update',
				jsonMap: args,
			),
		);
	}

	Future<void> updateReverseProxyFolderName(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/capture/reverse-proxy/folder/rename',
				jsonMap: args,
			),
		);
	}

}

const JsonString _kReverseProxyIdSchema = JsonString(
	title: 'Reverse Proxy ID',
	description: 'The unique ID of a Reqable reverse proxy.',
);

const JsonString _kReverseProxyFolderIdSchema = JsonString(
	title: 'Reverse Proxy Folder ID',
	description: 'The unique ID of a Reqable reverse proxy folder.',
);

const JsonString _kReverseProxyNameSchema = JsonString(
	title: 'Reverse Proxy Name',
	description: 'The human-readable name of a Reqable reverse proxy.',
);

const JsonString _kReverseProxyFolderNameSchema = JsonString(
	title: 'Reverse Proxy Folder Name',
	description: 'The human-readable name of a Reqable reverse proxy folder.',
);

const JsonInteger _kReverseProxyLocalPortSchema = JsonInteger(
	title: 'Local Port',
	description: 'The local listening port, Reqable will listen on this port and forward traffic to the remote host.',
	minimum: 1024,
	maximum: 65535,
);

const JsonString _kReverseProxyHostSchema = JsonString(
	title: 'Remote Host',
	description: 'Host or host:port, such as `example.com` or `example.com:8443`. If port is not specified, the default port will be used, which is 443 for HTTPS and 80 for HTTP.',
);

const JsonBoolean _kReverseProxySecuritySchema = JsonBoolean(
	title: 'Use HTTPS',
	description: 'Whether the connection to the remote host should use HTTPS.',
	defaultValue: true,
);

const JsonBoolean _kReverseProxyPreserveHostSchema = JsonBoolean(
	title: 'Preserve Host Header',
	description: 'Whether to preserve the original Host header when forwarding requests.',
	defaultValue: false,
);

const JsonString _kReverseProxyRemoteHostSchema = JsonString(
  title: 'Remote Host Name',
  description: 'The remote host name or IP address without the port.',
);

const JsonInteger _kReverseProxyRemotePortSchema = JsonInteger(
  title: 'Remote Port',
  description: 'The remote port.',
  minimum: 1024,
  maximum: 65535,
);

const JsonObject _kReverseProxySchema = ToolOutputSchema(
	title: 'Reverse Proxy',
	description: 'The reverse proxy definition returned by Reqable.',
	properties: {
		'id': _kReverseProxyIdSchema,
		'name': _kReverseProxyNameSchema,
		'localPort': _kReverseProxyLocalPortSchema,
		'remoteHost': _kReverseProxyRemoteHostSchema,
		'remotePort': _kReverseProxyRemotePortSchema,
		'security': _kReverseProxySecuritySchema,
		'preserveHost': _kReverseProxyPreserveHostSchema,
		'isEnabled': JsonBoolean(
			title: 'Is Enabled',
			description: 'Whether the reverse proxy itself is currently enabled.',
		),
	},
	required: ['id', 'name', 'localPort', 'remoteHost', 'remotePort', 'security', 'preserveHost', 'isEnabled'],
);

const JsonObject _kReverseProxyFolderSchema = ToolOutputSchema(
	title: 'Reverse Proxy Folder',
	description: 'A folder containing multiple reverse proxies.',
	properties: {
		'id': _kReverseProxyFolderIdSchema,
		'name': _kReverseProxyFolderNameSchema,
		'items': JsonArray(
			title: 'Reverse Proxies',
			description: 'The reverse proxies contained within this folder.',
			items: _kReverseProxySchema,
		),
		'collapsed': JsonBoolean(
			title: 'Is Collapsed',
			description: 'Whether the reverse proxy folder is currently collapsed in the UI.',
		),
	},
	required: ['id', 'name', 'items'],
);

const JsonObject _kReverseProxyConfigSchema = ToolOutputSchema(
	title: 'Reverse Proxy Configuration',
	description: 'The full Reqable reverse proxy configuration, including top-level proxies, folders, and the global enabled state.',
	properties: {
		'proxies': JsonArray(
			title: 'Reverse Proxy Entries',
			description: 'Top-level reverse proxy entries. Each entry is either a reverse proxy or a folder containing reverse proxies.',
			items: JsonObject(
				title: 'Reverse Proxy Configuration Item',
				description: 'A top-level reverse proxy entry, which can be a reverse proxy or a folder containing reverse proxies.',
				properties: {
					'id': JsonString(
						title: 'Item ID',
						description: 'The unique ID of the reverse proxy or reverse proxy folder.',
					),
					'name': JsonString(
						title: 'Item Name',
						description: 'The human-readable name of the reverse proxy or reverse proxy folder.',
					),
					'localPort': _kReverseProxyLocalPortSchema,
					'remoteHost': _kReverseProxyRemoteHostSchema,
		      'remotePort': _kReverseProxyRemotePortSchema,
					'security': _kReverseProxySecuritySchema,
					'preserveHost': _kReverseProxyPreserveHostSchema,
					'isEnabled': JsonBoolean(
						title: 'Is Enabled',
						description: 'Whether the reverse proxy item is currently enabled.',
					),
					'items': JsonArray(
						title: 'Folder Reverse Proxies',
						description: 'The reverse proxies contained in this folder.',
						items: _kReverseProxySchema,
					),
					'collapsed': JsonBoolean(
						title: 'Is Collapsed',
						description: 'Whether the reverse proxy folder is currently collapsed in the UI.',
					),
				},
				required: ['id', 'name'],
			),
		),
		'isEnabled': JsonBoolean(
			title: 'Reverse Proxy Feature Enabled',
			description: 'Whether the global Reqable reverse proxy feature is currently enabled.',
		),
	},
	required: ['proxies', 'isEnabled'],
);
