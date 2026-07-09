import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureGatewayTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
  if (!scope.toolGroups.contains(ReqableToolGroup.captureGateway)) {
    return;
  }
  final _CaptureGatewayService service = _CaptureGatewayService(
    client: client
  );
  server.registerTool(
    'capture_gateway_get_config',
    title: 'Get Gateway Configuration',
    description: 'Get the current Reqable gateway configuration for traffic-control operations such as blocking, bypassing, or suspending traffic.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: _kGatewayConfigSchema,
    callback: (args, extra) {
      return buildContentResult(
        apiCall: service.getConfig,
        contentBuilder: (_) {
          return 'Successfully retrieved gateway configuration.';
        },
      );
    },
  );
  server.registerTool(
    'capture_gateway_set_enabled',
    title: 'Set Gateway Feature Enabled State',
    description: 'Enable or disable the Reqable gateway feature globally.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide whether the Reqable gateway feature should be enabled.',
      properties: {
        'enabled': JsonBoolean(
          title: 'Enabled',
          description: 'Whether to enable the gateway feature.',
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
        message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the gateway feature.',
      );
    },
  );
  server.registerTool(
    'capture_gateway_list',
    title: 'List Gateways',
    description: 'List all Reqable gateways as a flat list. Gateway folders are not returned as items.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: ToolOutputSchema(
      title: 'Gateway List',
      description: 'A flat list of all Reqable gateways currently defined.',
      properties: {
        'items': JsonArray(
          title: 'Gateways',
          description: 'A flat list of gateway definitions.',
          items: _kGatewaySchema,
        ),
      },
      required: ['items'],
    ),
    callback: (args, extra) {
      return buildContentResult(
        apiCall: service.listGateways,
        contentBuilder: (jsonList) {
          return 'There are currently ${jsonList.length} gateways defined.';
        },
      );
    },
  );
  server.registerTool(
    'capture_gateway_set_item_enabled',
    title: 'Set Gateways Enabled State',
    description: 'Enable or disable one or more gateways by their IDs without changing their definitions.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more gateway IDs and whether they should be enabled.',
      properties: {
        'ids': JsonArray(
          items: _kGatewayIdSchema,
        ),
        'enabled': JsonBoolean(
          title: 'Enabled',
          description: 'Whether to enable the specified gateways.',
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
          return service.setGatewaysEnabled(args);
        },
        message: 'Successfully ${enabled ? 'enabled' : 'disabled'} the specified gateways.',
      );
    },
  );
  server.registerTool(
    'capture_gateway_get_by_id',
    title: 'Get Gateway by ID',
    description: 'Retrieve a gateway by ID and return its full details.',
    annotations: ToolAnnotations(
      readOnlyHint: true,
    ),
    outputSchema: _kGatewaySchema,
    inputSchema: const ToolInputSchema(
      description: 'Provide a gateway ID to retrieve its latest details from Reqable.',
      properties: {
        'id': _kGatewayIdSchema,
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
          return service.getGatewayById(args);
        },
        contentBuilder: (_) {
          return 'Successfully retrieved the gateway details.';
        },
      );
    },
  );
  server.registerTool(
    'capture_gateway_create',
    title: 'Create Gateway',
    description: 'Create a new Reqable gateway rule for controlling traffic and return the created gateway.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the gateway definition to create. The name and action are required.',
      properties: {
        'name': _kGatewayNameSchema,
        'action': _kGatewayActionSchema,
        'folderId': _kGatewayFolderIdSchema,
      },
      required: ['name', 'action'],
    ),
    outputSchema: _kGatewaySchema,
    callback: (args, extra) {
      final CallToolResult? nameValidationError = validateRequiredStringArgument(
        args,
        key: 'name',
      );
      if (nameValidationError != null) {
        return nameValidationError;
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
          return service.createGateway(args);
        },
        contentBuilder: (_) {
          return 'Successfully created the gateway.';
        },
      );
    },
  );
  server.registerTool(
    'capture_gateway_create_folder',
    title: 'Create Gateway Folder',
    description: 'Create a new gateway folder for organizing related Reqable gateways and return the created folder.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the folder name for a new gateway folder.',
      properties: {
        'name': _kGatewayFolderNameSchema,
      },
      required: ['name'],
    ),
    outputSchema: _kGatewayFolderSchema,
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
          return service.createGatewayFolder(args);
        },
        contentBuilder: (_) {
          return 'Successfully created the gateway folder.';
        },
      );
    },
  );
  server.registerTool(
    'capture_gateway_delete',
    title: 'Delete Gateways',
    description: 'Permanently delete one or more gateways by their IDs.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more gateway IDs to delete permanently.',
      properties: {
        'ids': JsonArray(
          items: _kGatewayIdSchema,
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
          return service.deleteGateways(args);
        },
        message: 'Successfully deleted the specified gateways.',
      );
    },
  );
  server.registerTool(
    'capture_gateway_delete_folder',
    title: 'Delete Gateway Folders',
    description: 'Permanently delete one or more gateway folders by their IDs.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: false,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide one or more gateway folder IDs to delete permanently.',
      properties: {
        'ids': JsonArray(
          items: _kGatewayFolderIdSchema,
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
          return service.deleteGatewayFolders(args);
        },
        message: 'Successfully deleted the specified gateway folders.',
      );
    },
  );
  server.registerTool(
    'capture_gateway_update',
    title: 'Update Gateway',
    description: 'Update an existing gateway by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: _kGatewaySchema,
    outputSchema: kMutationResultSchema,
    callback: (args, extra) {
      return buildVoidResult(
        apiCall: () {
          return service.updateGateway(args);
        },
        message: 'Successfully updated the gateway.',
      );
    },
  );
  server.registerTool(
    'capture_gateway_update_folder_name',
    title: 'Rename Gateway Folder',
    description: 'Rename an existing gateway folder by ID.',
    annotations: ToolAnnotations(
      readOnlyHint: false,
      destructiveHint: false,
      idempotentHint: true,
    ),
    inputSchema: const ToolInputSchema(
      description: 'Provide the gateway folder ID and the new folder name.',
      properties: {
        'id': _kGatewayFolderIdSchema,
        'name': _kGatewayFolderNameSchema,
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
          return service.updateGatewayFolderName(args);
        },
        message: 'Successfully updated the gateway folder name.',
      );
    },
  );
}

class _CaptureGatewayService {

  final ReqableApiClient client;

  const _CaptureGatewayService({
    required this.client,
  });

  Future<String> getConfig() {
    return client.sendGetRequest(
      const VoidRequest(
        route: '/capture/gateway'
      ),
    );
  }

  Future<void> setEnabled(bool enabled) {
    return client.sendPostRequest(
      VoidRequest(
        route: enabled
            ? '/capture/gateway/on'
            : '/capture/gateway/off'
      ),
    );
  }

  Future<String> listGateways() {
    return client.sendGetRequest(
      const VoidRequest(
        route: '/capture/gateway/list'
      ),
    );
  }

  Future<void> setGatewaysEnabled(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: args['enabled']
            ? '/capture/gateway/enable'
            : '/capture/gateway/disable',
        jsonMap: args,
      ),
    );
  }

  Future<String> getGatewayById(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/gateway/lookup',
        jsonMap: args,
      ),
    );
  }

  Future<String> createGateway(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/gateway/create',
        jsonMap: args,
      ),
    );
  }

  Future<String> createGatewayFolder(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/gateway/folder/create',
        jsonMap: args,
      ),
    );
  }

  Future<void> deleteGateways(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/gateway/delete',
        jsonMap: args,
      ),
    );
  }

  Future<void> deleteGatewayFolders(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/gateway/folder/delete',
        jsonMap: args,
      ),
    );
  }

  Future<void> updateGateway(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/gateway/update',
        jsonMap: args,
      ),
    );
  }

  Future<void> updateGatewayFolderName(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(
        route: '/capture/gateway/folder/rename',
        jsonMap: args,
      ),
    );
  }

}

const JsonString _kGatewayIdSchema = JsonString(
  title: 'Gateway ID',
  description: 'The unique ID of a Reqable gateway.',
);

const JsonString _kGatewayFolderIdSchema = JsonString(
  title: 'Gateway Folder ID',
  description: 'The unique ID of a Reqable gateway folder.',
);

const JsonString _kGatewayNameSchema = JsonString(
  title: 'Gateway Name',
  description: 'The human-readable name of a Reqable gateway.',
);

const JsonString _kGatewayFolderNameSchema = JsonString(
  title: 'Gateway Folder Name',
  description: 'The human-readable name of a Reqable gateway folder.',
);

const JsonObject _kGatewayActionSchema = JsonObject(
  title: 'Gateway Action',
  description: 'The action definition of a gateway, describing how matching traffic is handled.',
  properties: {
    'layer': JsonInteger(
      title: 'Layer',
      description: 'The network layer: 0 for L4, 1 for L7. L4 gateways control traffic based on host and IP rules, while L7 gateways control traffic based on HTTP and WebSocket rules.',
      minimum: 0,
      maximum: 1,
    ),
    'type': JsonInteger(
      title: 'Action Type',
      description: 'Describes how traffic matching the gateway rules is handled. \nFor L4 gateways:\n- Allow(0): traffic is allowed to proceed as normal. \n- Bypass(1): traffic is allowed but does not go through any of Reqable\'s processing modules. \n- Block(2): traffic is blocked outright. \nFor L7 gateways:\n- Allow(0): traffic is allowed to proceed as normal. \n- Bypass(1): traffic is allowed but does not go through any of Reqable\'s processing modules. \n- Block Request(2): incoming requests matching the gateway rules are blocked outright, responses are unaffected. \n- Block Response(3): outgoing responses matching the gateway rules are blocked outright, requests are unaffected. \n- Suspend Request(4): incoming requests matching the gateway rules are suspended/paused indefinitely, responses are unaffected. \n- Suspend Response(5): outgoing responses matching the gateway rules are suspended/paused indefinitely, requests are unaffected.',
      minimum: 0,
      maximum: 5,
    ),
    'ruleType': JsonInteger(
      title: 'Rule Type',
      description: 'Describes the type of rules used for matching traffic. \n- Host(0): rules match based on host and port combinations. Applicable for both L4 and L7 gateways. \n- IP/CIDR(1): rules match based on IP/CIDR address and port combinations. Applicable for both L4 and L7 gateways. \n- HTTP(2): rules match based on HTTP method and URL patterns. Applicable only for L7 gateways. \n- WebSocket(3): rules match based on WebSocket URL patterns. Applicable only for L7 gateways.',
      minimum: 0,
      maximum: 3,
    ),
    'rules': JsonArray(
      title: 'Rules',
      description: 'Array of rule objects that define the matching criteria.',
      items: JsonObject(
        title: 'Rule',
        description: 'A single gateway rule entry. The exact structure depends on the `ruleType` value.',
        properties: {
          'host': JsonString(
            title: 'Host',
            description: 'Used by rule type Host(0). A host supports wildcard patterns like *.example.com to match subdomains.',
          ),
          'address': JsonString(
            title: 'IP/CIDR',
            description: 'Used by rule type IP/CIDR(1). The IP or CIDR address, such as 192.168.1.1 or 192.168.1.0/24.',
          ),
          'port': JsonString(
            title: 'Port',
            description: 'Used by rule types Host(0) and IP/CIDR(1). The port, use comma to separate multiple ports, or use a range like 8080-8090. If not specified, the rule matches all ports.',
          ),
          'method': JsonString(
            title: 'HTTP Method',
            description: 'Used by rule type HTTP(2). The HTTP method, such as GET or POST.',
          ),
          'url': JsonString(
            title: 'URL Pattern',
            description: 'Used by rule types HTTP(2) and WebSocket(3). The URL pattern, such as `http://example.com/*`.',
          ),
          'wildcard': JsonBoolean(
            title: 'Is Wildcard',
            description: 'Used by rule types HTTP(2) and WebSocket(3). Whether the URL pattern is a wildcard pattern.',
          ),
          'isEnabled': JsonBoolean(
            title: 'Is Enabled',
            description: 'Whether this specific rule is currently enabled. If false, the rule is ignored for traffic matching.',
          ),
        },
        required: ['isEnabled']
      ),
    ),
  },
  required: ['layer', 'type', 'ruleType', 'rules'],
);

const JsonObject _kGatewaySchema = ToolOutputSchema(
  title: 'Gateway',
  description: 'The gateway definition returned by Reqable.',
  properties: {
    'id': _kGatewayIdSchema,
    'name': _kGatewayNameSchema,
    'action': _kGatewayActionSchema,
    'isEnabled': JsonBoolean(
      title: 'Is Enabled',
      description: 'Whether the gateway itself is currently enabled.',
    ),
  },
  required: ['id', 'name', 'action', 'isEnabled'],
);

const JsonObject _kGatewayFolderSchema = ToolOutputSchema(
  title: 'Gateway Folder',
  description: 'A folder containing multiple gateways.',
  properties: {
    'id': _kGatewayFolderIdSchema,
    'name': _kGatewayFolderNameSchema,
    'items': JsonArray(
      title: 'Gateways',
      description: 'The gateways contained within this folder.',
      items: _kGatewaySchema,
    ),
  },
  required: ['id', 'name', 'items'],
);

const JsonObject _kGatewayConfigSchema = ToolOutputSchema(
  title: 'Gateway Configuration',
  description: 'The full Reqable gateway configuration, including top-level gateways, folders, and the global enabled state.',
  properties: {
    'gateways': JsonArray(
      title: 'Gateway Entries',
      description: 'Top-level gateway entries. Each entry is either a gateway or a folder containing gateways.',
      items: JsonObject(
        title: 'Gateway Configuration Item',
        description: 'A top-level gateway entry, which can be a gateway or a folder containing gateways.',
        properties: {
          'id': JsonString(
            title: 'Item ID',
            description: 'The unique ID of the gateway or gateway folder.',
          ),
          'name': JsonString(
            title: 'Item Name',
            description: 'The human-readable name of the gateway or gateway folder.',
          ),
          'action': _kGatewayActionSchema,
          'isEnabled': JsonBoolean(
            title: 'Is Enabled',
            description: 'Whether the gateway item is currently enabled.',
          ),
          'items': JsonArray(
            title: 'Folder Gateways',
            description: 'The gateways contained in this folder. Folders do not contain nested folders.',
            items: _kGatewaySchema,
          ),
          'collapsed': JsonBoolean(
            title: 'Is Collapsed',
            description: 'Whether the gateway folder is currently collapsed in the UI.',
          ),
        },
        required: ['id', 'name'],
      ),
    ),
    'isEnabled': JsonBoolean(
      title: 'Gateway Feature Enabled',
      description: 'Whether the global Reqable gateway feature is currently enabled.',
    ),
  },
  required: ['gateways', 'isEnabled'],
);
