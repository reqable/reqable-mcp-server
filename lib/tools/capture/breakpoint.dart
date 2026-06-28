import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureBreakpointTools(McpServer server, ReqableApiClient client) {
  final _CaptureBreakpointService service = _CaptureBreakpointService(
    client: client
  );
  server.registerTool(
    'capture_breakpoint_get_config',
    title: 'Get Breakpoint Configuration',
    description: 'Get the current Reqable breakpoint configuration for pausing matched requests or responses for inspection and modification.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: _kBreakpointConfigSchema,
    callback: (args, extra) {
      return buildContentResult(
        apiCall: service.getConfig,
        contentBuilder: (_) {
          return 'Successfully retrieved breakpoint configuration.';
        },
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_set_enabled',
    title: 'Set Breakpoint Feature Enabled State',
    description: 'Enable or disable the Reqable breakpoint feature globally without changing any existing breakpoint definitions.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide whether the Reqable breakpoint feature should be enabled.',
      properties: {
        'enabled': JsonBoolean(
          title: 'Enabled',
          description: 'Whether to enable the breakpoint feature.',
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
        message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the breakpoint feature.',
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_list',
    title: 'List Breakpoints',
    description: 'List all Reqable breakpoints as a flat list. Breakpoint folders are not returned as items.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: ToolOutputSchema(
      title: 'Breakpoint List',
      description: 'A flat list of all Reqable breakpoints currently defined.',
      properties: {
        'items': JsonArray(
          title: 'Breakpoints',
          description: 'A flat list of breakpoint definitions.',
          items: _kBreakpointSchema,
        ),
      },
      required: ['items'],
    ),
    callback: (args, extra) {
      return buildContentResult(
        apiCall: service.listBreakpoints,
        contentBuilder: (jsonList) {
          return 'There are currently ${jsonList.length} breakpoints defined.';
        },
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_set_item_enabled',
    title: 'Set Breakpoints Enabled State',
    description: 'Enable or disable one or more breakpoints by their IDs without changing their definitions.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more breakpoint IDs and whether they should be enabled.',
      properties: {
        'ids': JsonArray(
          items: _kBreakpointIdSchema,
        ),
        'enabled': JsonBoolean(
          title: 'Enabled',
          description: 'Whether to enable the specified breakpoints.',
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
          return service.setBreakpointsEnabled(args);
        },
        message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the specified breakpoints.',
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_get_by_id',
    title: 'Get Breakpoint by ID',
    description: 'Retrieve a breakpoint by ID and return its full details.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: _kBreakpointSchema,
    inputSchema: const ToolInputSchema(
      description: 'Provide a breakpoint ID to retrieve its latest details from Reqable.',
      properties: {
        'id': _kBreakpointIdSchema,
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
          return service.getBreakpointById(args);
        },
        contentBuilder: (_) {
          return 'Successfully retrieved the breakpoint details.';
        },
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_create',
    title: 'Create Breakpoint',
    description: 'Create a new Reqable breakpoint for matching HTTP requests or responses and return the created breakpoint.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the breakpoint definition to create. The name and HTTP URL pattern are required.',
      properties: {
        'name': _kBreakpointNameSchema,
        'method': _kBreakpointMethodSchema,
        'url': _kBreakpointUrlSchema,
        'folderId': _kBreakpointFolderIdSchema,
        'wildcard': _kBreakpointWildcardSchema,
        'isRequestEnabled': _kBreakpointRequestEnabledSchema,
        'isResponseEnabled': _kBreakpointResponseEnabledSchema,
      },
      required: ['name', 'url'],
    ),
    outputSchema: _kBreakpointSchema,
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
      return buildContentResult(
        apiCall: () {
          return service.createBreakpoint(args);
        },
        contentBuilder: (_) {
          return 'Successfully created the breakpoint.';
        },
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_create_folder',
    title: 'Create Breakpoint Folder',
    description: 'Create a new breakpoint folder for organizing related Reqable breakpoints and return the created folder.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the folder name for a new breakpoint folder.',
      properties: {
        'name': _kBreakpointFolderNameSchema,
      },
      required: ['name'],
    ),
    outputSchema: _kBreakpointFolderSchema,
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
          return service.createBreakpointFolder(args);
        },
        contentBuilder: (_) {
          return 'Successfully created the breakpoint folder.';
        },
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_delete',
    title: 'Delete Breakpoints',
    description: 'Permanently delete one or more breakpoints by their IDs.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more breakpoint IDs to delete permanently.',
      properties: {
        'ids': JsonArray(
          items: _kBreakpointIdSchema,
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
          return service.deleteBreakpoints(args);
        },
        message: 'Successfully deleted the specified breakpoints.',
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_delete_folder',
    title: 'Delete Breakpoint Folders',
    description: 'Permanently delete one or more breakpoint folders by their IDs.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more breakpoint folder IDs to delete permanently.',
      properties: {
        'ids': JsonArray(
          items: _kBreakpointFolderIdSchema
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
          return service.deleteBreakpointFolders(args);
        },
        message: 'Successfully deleted the specified breakpoint folders.',
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_update',
    title: 'Update Breakpoint',
    description: 'Update an existing breakpoint by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: _kBreakpointSchema,
    outputSchema: kMutationResultSchema,
    callback: (args, extra) {
      return buildVoidResult(
        apiCall: () {
          return service.updateBreakpoint(args);
        },
        message: 'Successfully updated the breakpoint.',
      );
    },
  );
  server.registerTool(
    'capture_breakpoint_update_folder_name',
    title: 'Rename Breakpoint Folder',
    description: 'Rename an existing breakpoint folder by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the breakpoint folder ID and the new folder name.',
      properties: {
        'id': _kBreakpointFolderIdSchema,
        'name': _kBreakpointFolderNameSchema,
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
          return service.updateBreakpointFolderName(args);
        },
        message: 'Successfully updated the breakpoint folder name.',
      );
    },
  );
}

class _CaptureBreakpointService {

  final ReqableApiClient client;

  const _CaptureBreakpointService({
    required this.client,
  });

  Future<String> getConfig() {
    return client.sendGetRequest(
      const VoidRequest(
        route: '/capture/breakpoint'
      ),
    );
  }

  Future<void> setEnabled(bool enabled) {
    return client.sendPostRequest(
      VoidRequest(
        route: enabled
            ? '/capture/breakpoint/on'
            : '/capture/breakpoint/off'
      ),
    );
  }

  Future<String> listBreakpoints() {
    return client.sendGetRequest(
      const VoidRequest(
        route: '/capture/breakpoint/list'
      ),
    );
  }

  Future<void> setBreakpointsEnabled(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: args['enabled']
            ? '/capture/breakpoint/enable'
            : '/capture/breakpoint/disable',
        jsonMap: args,
      ),
    );
  }

  Future<String> getBreakpointById(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/breakpoint/lookup',
        jsonMap: args,
      ),
    );
  }

  Future<String> createBreakpoint(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/breakpoint/create',
        jsonMap: args,
      ),
    );
  }

  Future<String> createBreakpointFolder(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/breakpoint/folder/create',
        jsonMap: args,
      ),
    );
  }

  Future<void> deleteBreakpoints(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/breakpoint/delete',
        jsonMap: args,
      ),
    );
  }

  Future<void> deleteBreakpointFolders(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/breakpoint/folder/delete',
        jsonMap: args,
      ),
    );
  }

  Future<void> updateBreakpoint(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/breakpoint/update',
        jsonMap: args,
      ),
    );
  }

  Future<void> updateBreakpointFolderName(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/breakpoint/folder/rename',
        jsonMap: args,
      ),
    );
  }

}

const JsonString _kBreakpointIdSchema = JsonString(
  title: 'Breakpoint ID',
  description: 'The unique ID of a Reqable breakpoint.',
);

const JsonString _kBreakpointFolderIdSchema = JsonString(
  title: 'Breakpoint Folder ID',
  description: 'The unique ID of a Reqable breakpoint folder.',
);

const JsonString _kBreakpointNameSchema = JsonString(
  title: 'Breakpoint Name',
  description: 'The human-readable name of a Reqable breakpoint.',
);

const JsonString _kBreakpointFolderNameSchema = JsonString(
  title: 'Breakpoint Folder Name',
  description: 'The human-readable name of a Reqable breakpoint folder.',
);

const JsonString _kBreakpointMethodSchema = JsonString(
  title: 'HTTP Method',
  description: 'The HTTP method filter for the breakpoint, such as GET, POST, PUT, or DELETE. An empty string means any method.',
);

const JsonString _kBreakpointUrlSchema = JsonString(
  title: 'HTTP URL Pattern',
  description: 'The HTTP URL or URL pattern matched by the breakpoint.',
);

const JsonBoolean _kBreakpointWildcardSchema = JsonBoolean(
  title: 'Use Wildcard Matching',
  description: 'Whether the HTTP URL pattern is interpreted as a wildcard pattern.',
  defaultValue: true,
);

const JsonBoolean _kBreakpointRequestEnabledSchema = JsonBoolean(
  title: 'Break on Request',
  description: 'Whether the breakpoint pauses matching HTTP requests.',
);

const JsonBoolean _kBreakpointResponseEnabledSchema = JsonBoolean(
  title: 'Break on Response',
  description: 'Whether the breakpoint pauses matching HTTP responses.',
);

const JsonObject _kBreakpointSchema = ToolOutputSchema(
  title: 'Breakpoint',
  description: 'The breakpoint definition returned by Reqable.',
  properties: {
    'id': _kBreakpointIdSchema,
    'name': _kBreakpointNameSchema,
    'method': _kBreakpointMethodSchema,
    'url': _kBreakpointUrlSchema,
    'wildcard': _kBreakpointWildcardSchema,
    'isRequestEnabled': _kBreakpointRequestEnabledSchema,
    'isResponseEnabled': _kBreakpointResponseEnabledSchema,
    'isEnabled': JsonBoolean(
      title: 'Is Enabled',
      description: 'Whether the breakpoint itself is currently enabled.',
    ),
  },
  required: [
    'id',
    'name',
    'method',
    'url',
    'wildcard',
    'isRequestEnabled',
    'isResponseEnabled',
    'isEnabled',
  ],
);

const JsonObject _kBreakpointFolderSchema = ToolOutputSchema(
  title: 'Breakpoint Folder',
  description: 'A folder containing multiple breakpoints.',
  properties: {
    'id': _kBreakpointFolderIdSchema,
    'name': _kBreakpointFolderNameSchema,
    'items': JsonArray(
      title: 'Breakpoints',
      description: 'The breakpoints contained within this folder.',
      items: _kBreakpointSchema,
    ),
  },
  required: ['id', 'name', 'items'],
);

const JsonObject _kBreakpointConfigSchema = ToolOutputSchema(
  title: 'Breakpoint Configuration',
  description: 'The full Reqable breakpoint configuration, including top-level breakpoints, folders, and the global enabled state.',
  properties: {
    'breakpoints': JsonArray(
      title: 'Breakpoint Entries',
      description: 'Top-level breakpoint entries. Each entry is either a breakpoint or a folder containing breakpoints.',
      items: JsonObject(
        title: 'Breakpoint Configuration Item',
        description: 'A top-level breakpoint entry, which can be a breakpoint or a folder containing breakpoints.',
        properties: {
          'id': JsonString(
            title: 'Item ID',
            description: 'The unique ID of the breakpoint or breakpoint folder.',
          ),
          'name': JsonString(
            title: 'Item Name',
            description: 'The human-readable name of the breakpoint or breakpoint folder.',
          ),
          'method': _kBreakpointMethodSchema,
          'url': _kBreakpointUrlSchema,
          'wildcard': _kBreakpointWildcardSchema,
          'isRequestEnabled': _kBreakpointRequestEnabledSchema,
          'isResponseEnabled': _kBreakpointResponseEnabledSchema,
          'isEnabled': JsonBoolean(
            title: 'Is Enabled',
            description: 'Whether the breakpoint item is currently enabled.',
          ),
          'items': JsonArray(
            title: 'Folder Breakpoints',
            description: 'The breakpoints contained in this folder. Folders do not contain nested folders.',
            items: _kBreakpointSchema,
          ),
          'collapsed': JsonBoolean(
            title: 'Is Collapsed',
            description: 'Whether the breakpoint folder is currently collapsed in the UI.',
          ),
        },
        required: ['id', 'name'],
      ),
    ),
    'isEnabled': JsonBoolean(
      title: 'Breakpoint Feature Enabled',
      description: 'Whether the global Reqable breakpoint feature is currently enabled.',
    ),
  },
  required: ['breakpoints', 'isEnabled'],
);