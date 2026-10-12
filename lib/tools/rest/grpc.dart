import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/rest/base.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';

void registerRestGrpcTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.rest)) {
		return;
	}
	final _RestGrpcService service = _RestGrpcService(
		client: client,
	);
	server.registerTool(
		'rest_grpc_update',
		title: 'Update gRPC API',
		description: 'Update an existing Reqable gRPC API using a complete JSON payload.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: kRestGrpcSchema,
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () => service.update(args),
				message: 'Successfully updated the gRPC API.',
			);
		},
	);
}

class _RestGrpcService {

	final ReqableApiClient client;

	const _RestGrpcService({
		required this.client,
	});

	Future<void> update(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(
				route: '/rest/grpc/update',
				jsonMap: args,
			),
		);
	}

}

const Map<String, JsonSchema> kRestGrpcProperties = {
  'type': JsonString(
    title: 'API Type',
    description: 'The API type, which must be "grpc" for gRPC APIs.',
    enumValues: ['grpc'],
  ),
  'name': JsonString(
    title: 'Name',
    description: 'The display name of the gRPC API.',
  ),
  'url': JsonString(
    title: 'URL',
    description: 'The base URL of the gRPC API.',
  ),
  'method': JsonObject(
    title: 'gRPC Method',
    description: 'The gRPC method to invoke, including its service, name, and type.',
    properties: {
      'service': JsonObject(
        title: 'Service',
        description: 'The gRPC service that contains the method.',
        properties: {
          'package': JsonString(
            title: 'Package',
            description: 'The proto package name.',
          ),
          'name': JsonString(
            title: 'Service Name',
            description: 'The proto service name.',
          ),
        },
        required: ['package', 'name'],
      ),
      'name': JsonString(
        title: 'Method Name',
        description: 'The gRPC method name.',
      ),
      'type': JsonString(
        title: 'Method Type',
        description: 'The gRPC method type.',
        enumValues: ['unary', 'clientStreaming', 'serverStreaming', 'bidirectionalStreaming'],
      ),
    },
    required: ['service', 'name', 'type'],
  ),
  'metadata': JsonArray(
    title: 'Metadata',
    description: 'The gRPC metadata list',
    items: _kRestRequestMetadataSchema,
  ),
  'message': JsonString(
    title: 'gRPC message payload',
    description: 'The gRPC message payload.',
  ),
  'definition': _kRestGrpcDefinitionSchema,
  'authorization': kRestRequestAuthorizationSchema,
  'documentation': kRestDocumentationSchema,
};

const JsonOneOf _kRestGrpcDefinitionSchema = JsonOneOf(
	[
		_kRestGrpcServerReflectionDefinitionSchema,
		_kRestGrpcLocalFileDefinitionSchema,
		_kRestGrpcSpecFileDefinitionSchema,
	],
	title: 'Definition',
	description: 'The gRPC method definition source used to resolve the proto method and message.',
);

const JsonObject _kRestGrpcServerReflectionDefinitionSchema = JsonObject(
	title: 'Server Reflection Definition',
	description: 'Resolve the proto method via gRPC server reflection.',
	properties: {
		'type': JsonString(
			title: 'Definition Type',
			description: 'The definition type.',
			enumValues: ['serverReflection'],
		),
	},
	required: ['type'],
);

const JsonObject _kRestGrpcLocalFileDefinitionSchema = JsonObject(
	title: 'Local File Definition',
	description: 'Resolve the proto method from a local proto file.',
	properties: {
		'type': JsonString(
			title: 'Definition Type',
			description: 'The definition type.',
			enumValues: ['localFile'],
		),
		'filePath': JsonString(
			title: 'File Path',
			description: 'The local proto file path.',
		),
	},
	required: ['type', 'filePath'],
);

const JsonObject _kRestGrpcSpecFileDefinitionSchema = JsonObject(
	title: 'Spec File Definition',
	description: 'Resolve the proto method from a Reqable spec file.',
	properties: {
		'type': JsonString(
			title: 'Definition Type',
			description: 'The definition type.',
			enumValues: ['specFile'],
		),
		'fileId': JsonString(
			title: 'File ID',
			description: 'The Reqable spec file ID.',
		),
	},
	required: ['type', 'fileId'],
);

const JsonObject kRestGrpcSchema = ToolInputSchema(
	title: 'gRPC API Payload',
	description: 'The complete Reqable gRPC object.',
	properties: {
    'id': JsonString(
      title: 'ID',
      description: 'The unique API identifier.',
    ),
    ...kRestGrpcProperties,
  },
	required: [
		'id',
    'type',
		'name',
		'url',
		'method',
    'message',
    'definition',
		'metadata',
		'authorization',
		'documentation',
	],
	additionalProperties: true,
);

const JsonObject kRestGrpcWithoutIdSchema = ToolInputSchema(
	title: 'gRPC API Payload',
	description: 'The Reqable gRPC object used to create a gRPC API.',
	properties: kRestGrpcProperties,
	required: [
    'type',
		'name',
		'url',
		'method',
		'message',
    'definition',
		'metadata',
		'authorization',
		'documentation',
	],
	additionalProperties: true,
);

const JsonObject _kRestRequestMetadataSchema = JsonObject(
	title: 'Metadata',
	description: 'A gRPC metadata entry, optionally marked as disabled.',
	properties: {
		'key': JsonString(
			title: 'Metadata Key',
			description: 'The gRPC metadata key.',
		),
		'value': JsonString(
			title: 'Metadata Value',
			description: 'The gRPC metadata value.',
		),
		'disabled': JsonBoolean(
			title: 'Disabled',
			description: 'Whether this metadata entry is disabled.',
		),
	},
	required: ['key', 'value'],
);