import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCaptureLiveTools(McpServer server, ReqableApiClient client, McpToolScope scope) {
  if (!scope.toolGroups.contains(McpToolGroup.captureLive)) {
    return;
  }
	final _CaptureLiveService service = _CaptureLiveService(
		client: client,
	);
  if (scope == McpToolScope.all) {
    server.registerTool(
      'capture_live_status',
      title: 'Get Live Capture Status',
      description: 'Get whether Reqable live capture is currently active or inactive.',
      annotations: ToolAnnotations(
        readOnlyHint: true,
      ),
      outputSchema: _kCaptureLiveStatusSchema,
      callback: (args, extra) {
        return buildContentResult(
          apiCall: service.getStatus,
          contentBuilder: (String result, dynamic structuredResult) {
            return 'Reqable live capture is currently ${structuredResult['status']}.';
          },
        );
      },
    );
  }
	server.registerTool(
		'capture_live_set_enabled',
		title: 'Set Live Capture Enabled State',
		description: 'Start or stop Reqable live capture.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide whether Reqable live capture should be started or stopped.',
			properties: {
				'enabled': JsonBoolean(
					title: 'Enabled',
					description: 'Whether to start live capture.',
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
				message: 'Successfully ${enabled ? 'started' : 'stopped'} live capture.',
			);
		},
	);
  if (scope == McpToolScope.all) {
    server.registerTool(
      'capture_live_clear',
      title: 'Clear Live Capture Records',
      description: 'Clear all currently retained Reqable live capture records.',
      annotations: ToolAnnotations(
        readOnlyHint: false,
        destructiveHint: true,
        idempotentHint: true,
      ),
      outputSchema: kMutationResultSchema,
      callback: (args, extra) {
        return buildVoidResult(
          apiCall: service.clearRecords,
          message: 'Successfully cleared all live capture records.',
        );
      },
    );
  }
}

class _CaptureLiveService {

	final ReqableApiClient client;

	const _CaptureLiveService({
		required this.client,
	});

	Future<String> getStatus() {
		return client.sendGetRequest(
			const VoidRequest(
				route: '/capture/live/status',
			),
		);
	}

	Future<void> setEnabled(bool enabled) {
		return client.sendPostRequest(
			VoidRequest(
				route: enabled
					? '/capture/live/on'
					: '/capture/live/off',
			),
		);
	}

  Future<void> clearRecords() {
		return client.sendPostRequest(
      const VoidRequest(
        route: '/capture/live/clear',
      ),
    );
  }

}

const JsonObject _kCaptureLiveStatusSchema = ToolOutputSchema(
	title: 'Live Capture Status',
	description: 'The current Reqable live capture engine status.',
	properties: {
		'status': JsonString(
			title: 'Status',
			description: 'The current live capture status.',
			enumValues: ['active', 'inactive'],
		),
	},
	required: ['status'],
);