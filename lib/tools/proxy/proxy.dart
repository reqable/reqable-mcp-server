
import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerProxyTools(McpServer server, ReqableApiClient client) {
	final ProxyService service = ProxyService(
		client: client
	);
  server.registerTool(
		'proxy_set',
		title: 'Configure Reqable Proxy',
		description: 'Configure the proxy for Reqable, such as turning on/off the system proxy.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the proxy settings for Reqable.',
			properties: {
				'overrideSystem': JsonBoolean(
					title: 'Turn System Proxy On/Off',
					description: 'Whether to override the system proxy settings.',
				),
			},
			required: ['overrideSystem'],
		),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredBoolArgument(
				args,
				key: 'overrideSystem',
			);
			if (validationError != null) {
				return validationError;
			}
			final bool overrideSystem = args['overrideSystem'];
			return buildVoidResult(
				apiCall: () {
					return service.setProxy(args);
				},
				message: 'Successfully turned ${overrideSystem ? 'on' : 'off'} system proxy.',
			);
		},
	);
}

class ProxyService {

  final ReqableApiClient client;

  const ProxyService({
    required this.client,
  });

  Future<void> setProxy(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(
				route: '/proxy/set',
        jsonMap: args,
			),
		);
	}

}