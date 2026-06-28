import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/result.dart';

void registerScriptTools(McpServer server, ReqableApiClient client) {
	final ScriptService service = ScriptService(
		client: client
	);
  server.registerTool(
		'script_framework',
		title: 'Get Script Framework',
		description: 'Get the Reqable Python script framework content. Always call this tool before creating or updating script code.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		callback: (args, extra) async {
			return buildContentResult(
				apiCall: service.getFramework,
        contentBuilder: (content) {
          return content.toString();
        },
			);
		},
	);
	server.registerTool(
		'script_template',
		title: 'Get Script Template',
		description: 'Get the Reqable Python script template content. Always call this tool before creating or updating script code.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		callback: (args, extra) async {
			return buildContentResult(
				apiCall: service.getTemplate,
        contentBuilder: (content) {
          return content.toString();
        },
			);
		},
	);
}

class ScriptService {

	final ReqableApiClient client;

	const ScriptService({
		required this.client,
	});

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

}