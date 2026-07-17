import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureMirrorTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.captureMirror)) {
		return;
	}
  final _CaptureMirrorService service = _CaptureMirrorService(
    client: client
  );
  server.registerTool(
    'capture_mirror_get_config',
    title: 'Get Mirror Configuration',
    description: 'Get the current Reqable mirror configuration for redirecting matched traffic to a different domain.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: _kMirrorConfigSchema,
    callback: (args, extra) {
      return buildContentResult(
        apiCall: service.getConfig,
      );
    },
  );
  server.registerTool(
    'capture_mirror_set_enabled',
    title: 'Set Mirror Feature Enabled State',
    description: 'Enable or disable the Reqable mirror feature globally without changing any existing mirror definitions.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide whether the Reqable mirror feature should be enabled.',
      properties: {
        'enabled': JsonBoolean(
          title: 'Enabled',
          description: 'Whether to enable the mirror feature.',
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
        message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the mirror feature.',
      );
    },
  );
  server.registerTool(
    'capture_mirror_list',
    title: 'List Mirrors',
    description: 'List all Reqable mirrors as a flat list. Mirror folders are not returned as items.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: ToolOutputSchema(
      title: 'Mirror List',
      description: 'A flat list of all Reqable mirrors currently defined.',
      properties: {
        'items': JsonArray(
          title: 'Mirrors',
          description: 'A flat list of mirror definitions.',
          items: _kMirrorSchema,
        ),
      },
      required: ['items'],
    ),
    callback: (args, extra) {
      return buildContentResult(
        apiCall: service.listMirrors,
        contentBuilder: (String result, dynamic structuredResult) {
          if (structuredResult.isEmpty) {
            return 'There are currently no mirror defined.';
          }
          return result;
        },
      );
    },
  );
  server.registerTool(
    'capture_mirror_set_item_enabled',
    title: 'Set Mirrors Enabled State',
    description: 'Enable or disable one or more mirrors by their IDs without changing their definitions.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more mirror IDs and whether they should be enabled.',
      properties: {
        'ids': JsonArray(
          items: _kMirrorIdSchema,
        ),
        'enabled': JsonBoolean(
          title: 'Enabled',
          description: 'Whether to enable the specified mirrors.',
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
          return service.setMirrorsEnabled(args);
        },
        message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the specified mirrors.',
      );
    },
  );
  server.registerTool(
    'capture_mirror_get_by_id',
    title: 'Get Mirror by ID',
    description: 'Retrieve a mirror by ID and return its full details.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: _kMirrorSchema,
    inputSchema: const ToolInputSchema(
      description: 'Provide a mirror ID to retrieve its latest details from Reqable.',
      properties: {
        'id': _kMirrorIdSchema,
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
          return service.getMirrorById(args);
        },
      );
    },
  );
  server.registerTool(
    'capture_mirror_create',
    title: 'Create Mirror',
    description: 'Create a new Reqable mirror for matching requests or responses and return the created mirror.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the mirror definition to create. The name, pattern, and replacement are required.',
      properties: {
        'name': _kMirrorNameSchema,
        'pattern': _kMirrorPatternSchema,
        'replacement': _kMirrorReplacementSchema,
        'headerStrategy': _kMirrorHeaderStrategySchema,
        'sniStrategy': _kMirrorSniStrategySchema,
        'certStrategy': _kMirrorCertStrategySchema,
        'folderId': _kMirrorFolderIdSchema,
      },
      required: ['name', 'pattern', 'replacement'],
    ),
    outputSchema: _kMirrorSchema,
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
      final CallToolResult? replacementValidationError = validateRequiredStringArgument(
        args,
        key: 'replacement',
      );
      if (replacementValidationError != null) {
        return replacementValidationError;
      }
      return buildContentResult(
        apiCall: () {
          return service.createMirror(args);
        },
      );
    },
  );
  server.registerTool(
    'capture_mirror_create_folder',
    title: 'Create Mirror Folder',
    description: 'Create a new mirror folder for organizing related Reqable mirrors and return the created folder.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the folder name for a new mirror folder.',
      properties: {
        'name': _kMirrorFolderNameSchema,
      },
      required: ['name'],
    ),
    outputSchema: _kMirrorFolderSchema,
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
          return service.createMirrorFolder(args);
        },
      );
    },
  );
  server.registerTool(
    'capture_mirror_delete',
    title: 'Delete Mirrors',
    description: 'Permanently delete one or more mirrors by their IDs.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more mirror IDs to delete permanently.',
      properties: {
        'ids': JsonArray(
          items: _kMirrorIdSchema,
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
          return service.deleteMirrors(args);
        },
        message: 'Successfully deleted the specified mirrors.',
      );
    },
  );
  server.registerTool(
    'capture_mirror_delete_folder',
    title: 'Delete Mirror Folders',
    description: 'Permanently delete one or more mirror folders by their IDs.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more mirror folder IDs to delete permanently.',
      properties: {
        'ids': JsonArray(
          items: _kMirrorFolderIdSchema
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
          return service.deleteMirrorFolders(args);
        },
        message: 'Successfully deleted the specified mirror folders.',
      );
    },
  );
  server.registerTool(
    'capture_mirror_update',
    title: 'Update Mirror',
    description: 'Update an existing mirror by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: _kMirrorSchema,
    outputSchema: kMutationResultSchema,
    callback: (args, extra) {
      return buildVoidResult(
        apiCall: () {
          return service.updateMirror(args);
        },
        message: 'Successfully updated the mirror.',
      );
    },
  );
  server.registerTool(
    'capture_mirror_update_folder_name',
    title: 'Rename Mirror Folder',
    description: 'Rename an existing mirror folder by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the mirror folder ID and the new folder name.',
      properties: {
        'id': _kMirrorFolderIdSchema,
        'name': _kMirrorFolderNameSchema,
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
          return service.updateMirrorFolderName(args);
        },
        message: 'Successfully updated the mirror folder name.',
      );
    },
  );
}

class _CaptureMirrorService {

  final ReqableApiClient client;

  const _CaptureMirrorService({
    required this.client,
  });

  Future<String> getConfig() {
    return client.sendGetRequest(
      const VoidRequest(
        route: '/capture/mirror'
      ),
    );
  }

  Future<void> setEnabled(bool enabled) {
    return client.sendPostRequest(
      VoidRequest(
        route: enabled
            ? '/capture/mirror/on'
            : '/capture/mirror/off'
      ),
    );
  }

  Future<String> listMirrors() {
    return client.sendGetRequest(
      const VoidRequest(
        route: '/capture/mirror/list'
      ),
    );
  }

  Future<void> setMirrorsEnabled(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: args['enabled']
            ? '/capture/mirror/enable'
            : '/capture/mirror/disable',
        jsonMap: args,
      ),
    );
  }

  Future<String> getMirrorById(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/mirror/lookup',
        jsonMap: args,
      ),
    );
  }

  Future<String> createMirror(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/mirror/create',
        jsonMap: args,
      ),
    );
  }

  Future<String> createMirrorFolder(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/mirror/folder/create',
        jsonMap: args,
      ),
    );
  }

  Future<void> deleteMirrors(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/mirror/delete',
        jsonMap: args,
      ),
    );
  }

  Future<void> deleteMirrorFolders(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/mirror/folder/delete',
        jsonMap: args,
      ),
    );
  }

  Future<void> updateMirror(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/mirror/update',
        jsonMap: args,
      ),
    );
  }

  Future<void> updateMirrorFolderName(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/mirror/folder/rename',
        jsonMap: args,
      ),
    );
  }

}

const JsonString _kMirrorIdSchema = JsonString(
  title: 'Mirror ID',
  description: 'The unique ID of a Reqable mirror.',
);

const JsonString _kMirrorFolderIdSchema = JsonString(
  title: 'Mirror Folder ID',
  description: 'The unique ID of a Reqable mirror folder.',
);

const JsonString _kMirrorNameSchema = JsonString(
  title: 'Mirror Name',
  description: 'The human-readable name of a Reqable mirror.',
);

const JsonString _kMirrorFolderNameSchema = JsonString(
  title: 'Mirror Folder Name',
  description: 'The human-readable name of a Reqable mirror folder.',
);

const JsonString _kMirrorPatternSchema = JsonString(
  title: 'Mirror Pattern',
  description: 'The host or host pattern that a Reqable mirror should match, such as "api.example.com" or "*.example.com".',
);

const JsonString _kMirrorReplacementSchema = JsonString(
  title: 'Mirror Replacement',
  description: 'The new host that matching connections should be redirected to, such as "mirror.example.com".',
);

const JsonInteger _kMirrorHeaderStrategySchema = JsonInteger(
  title: 'Header Strategy',
  description: 'Host header strategy to apply to the mirrored requests.\n- 0 means preserve the origin `Host` header.\n- 1 means use proxy CONNECT `Host` header.\n- 2 means use the replacement value in the `Host` header.',
  minimum: 0,
  maximum: 2,
  defaultValue: 0,
);

const JsonInteger _kMirrorSniStrategySchema = JsonInteger(
  title: 'SNI Strategy',
  description: 'SNI (Server Name Indication) strategy to apply to the mirrored SSL/TLS requests.\n- 0 means preserve the origin SNI.\n- 1 means use proxy CONNECT `Host` header value as the SNI.\n- 2 means use the replacement value as the SNI.',
  minimum: 0,
  maximum: 2,
  defaultValue: 0,
);

const JsonInteger _kMirrorCertStrategySchema = JsonInteger(
  title: 'Certificate Strategy',
  description: 'SSL certificate generation strategy to apply to the mirrored SSL/TLS requests.\n- 0 means preserve the origin certificate server name.\n- 1 means use proxy CONNECT `Host` header value as the certificate server name.\n- 2 means use the replacement value as the certificate server name.',
  minimum: 0,
  maximum: 2,
  defaultValue: 0,
);

const JsonObject _kMirrorSchema = ToolOutputSchema(
  title: 'Mirror',
  description: 'The mirror definition returned by Reqable.',
  properties: {
    'id': _kMirrorIdSchema,
    'name': _kMirrorNameSchema,
    'pattern': _kMirrorPatternSchema,
    'replacement': _kMirrorReplacementSchema,
    'headerStrategy': _kMirrorHeaderStrategySchema,
    'sniStrategy': _kMirrorSniStrategySchema,
    'certStrategy': _kMirrorCertStrategySchema,
    'isEnabled': JsonBoolean(
      title: 'Is Enabled',
      description: 'Whether the mirror itself is currently enabled.',
    ),
  },
  required: [
    'id',
    'name',
    'pattern',
    'replacement',
    'headerStrategy',
    'sniStrategy',
    'certStrategy',
    'isEnabled',
  ],
);

const JsonObject _kMirrorFolderSchema = ToolOutputSchema(
  title: 'Mirror Folder',
  description: 'A folder containing multiple mirrors.',
  properties: {
    'id': _kMirrorFolderIdSchema,
    'name': _kMirrorFolderNameSchema,
    'items': JsonArray(
      title: 'Mirrors',
      description: 'The mirrors contained within this folder.',
      items: _kMirrorSchema,
    ),
  },
  required: ['id', 'name', 'items'],
);

const JsonObject _kMirrorConfigSchema = ToolOutputSchema(
  title: 'Mirror Configuration',
  description: 'The full Reqable mirror configuration, including top-level mirrors, folders, and the global enabled state.',
  properties: {
    'mirrors': JsonArray(
      title: 'Mirror Entries',
      description: 'Top-level mirror entries. Each entry is either a mirror or a folder containing mirrors.',
      items: JsonObject(
        title: 'Mirror Configuration Item',
        description: 'A top-level mirror entry, which can be a mirror or a folder containing mirrors.',
        properties: {
          'id': JsonString(
            title: 'Item ID',
            description: 'The unique ID of the mirror or mirror folder.',
          ),
          'name': JsonString(
            title: 'Item Name',
            description: 'The human-readable name of the mirror or mirror folder.',
          ),
          'pattern': _kMirrorPatternSchema,
          'replacement': _kMirrorReplacementSchema,
          'headerStrategy': _kMirrorHeaderStrategySchema,
          'sniStrategy': _kMirrorSniStrategySchema,
          'certStrategy': _kMirrorCertStrategySchema,
          'isEnabled': JsonBoolean(
            title: 'Is Enabled',
            description: 'Whether the mirror item is currently enabled.',
          ),
          'items': JsonArray(
            title: 'Folder Mirrors',
            description: 'The mirrors contained in this folder. Folders do not contain nested folders.',
            items: _kMirrorSchema,
          ),
          'collapsed': JsonBoolean(
            title: 'Is Collapsed',
            description: 'Whether the mirror folder is currently collapsed in the UI.',
          ),
        },
        required: ['id', 'name'],
      ),
    ),
    'isEnabled': JsonBoolean(
      title: 'Mirror Feature Enabled',
      description: 'Whether the global Reqable mirror feature is currently enabled.',
    ),
  },
  required: ['mirrors', 'isEnabled'],
);