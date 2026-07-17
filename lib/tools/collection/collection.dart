import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/api/client.dart';
import 'package:reqable_mcp_server/tools/rest/base.dart';
import 'package:reqable_mcp_server/tools/rest/http.dart';
import 'package:reqable_mcp_server/tools/rest/websocket.dart';
import 'package:reqable_mcp_server/tools/result.dart';
import 'package:reqable_mcp_server/tools/schema.dart';
import 'package:reqable_mcp_server/tools/tool.dart';
import 'package:reqable_mcp_server/tools/validate.dart';

void registerCollectionTools(McpServer server, ReqableApiClient client, ReqableToolScope scope) {
	if (!scope.toolGroups.contains(ReqableToolGroup.collection)) {
		return;
	}
	final _RestCollectionService service = _RestCollectionService(
		client: client,
	);
	server.registerTool(
		'collection_list',
		title: 'List Collections',
		description: 'List all Reqable collection IDs.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: ToolOutputSchema(
      title: 'Collection ID List',
      description: 'The collection IDs returned by Reqable.',
      properties: {
        'items': JsonArray(
          items: _kCollectionIdScheme,
        ),
      },
      required: ['items'],
    ),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.listCollections,
				contentBuilder: (String result, dynamic structuredResult) {
					if (structuredResult.isEmpty) {
						return 'There is currently no collection.';
					}
					return result;
				},
			);
		},
	);
	server.registerTool(
		'collection_structure',
		title: 'Get Collection Structure',
		description: 'Get the collection tree structure for all Reqable collections. The structure doesn\'t include the detailed node data.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		outputSchema: ToolOutputSchema(
      title: 'Collection Structure List',
      description: 'The collection tree structures returned by Reqable.',
      properties: {
        'items': JsonArray(
          items: _kCollectionStructureNodeSchema,
        ),
      },
      required: ['items'],
    ),
		callback: (args, extra) {
			return buildContentResult(
				apiCall: service.getStructure,
        contentBuilder: (String result, dynamic structuredResult) {
					if (structuredResult.isEmpty) {
						return 'There is currently no collection.';
					}
					return result;
				},
			);
		},
	);
	server.registerTool(
		'collection_get',
		title: 'Get Collection Properties',
		description: 'Get the properties of a Reqable collection by collection ID.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the collection ID to retrieve.',
			properties: {
				'id': _kCollectionIdScheme,
			},
			required: ['id'],
		),
		outputSchema: _kCollectionPropertiesSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'id',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () => service.getCollection(args),
			);
		},
	);
	server.registerTool(
		'collection_create',
		title: 'Create Collection',
		description: 'Create a new Reqable collection by name.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the new collection name.',
			properties: {
				'name': JsonString(
					title: 'Collection Name',
					description: 'The new collection name.',
				),
			},
			required: ['name'],
		),
		outputSchema: ToolOutputSchema(
      title: 'Collection Create ID',
      description: 'The collection ID returned by Reqable for the newly created collection.',
      properties: {
        'id': _kCollectionIdScheme,
      },
      required: ['id'],
    ),
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildContentResult(
				apiCall: () => service.createCollection(args),
			);
		},
	);
	server.registerTool(
		'collection_update',
		title: 'Update Collection Properties',
		description: 'Update a Reqable collection properties, including name, inherited query, inherited headers, inherited script, inherited authorization, and documentation.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: ToolInputSchema(
      description: 'The collection ID and collection properties payload.',
      properties: {
        'id': _kCollectionIdScheme,
        ..._kCollectionPropertiesSchema.properties ?? const {},
      },
      required: ['id'],
      additionalProperties: true,
    ),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			return buildVoidResult(
				apiCall: () => service.updateCollection(args),
				message: 'Successfully updated the collection properties.',
			);
		},
	);
	server.registerTool(
		'collection_delete',
		title: 'Delete Collection',
		description: 'Delete a Reqable collection by collection ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the collection ID to delete.',
			properties: {
				'id': _kCollectionIdScheme,
			},
			required: ['id'],
		),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			final CallToolResult? validationError = validateRequiredStringArgument(
				args,
				key: 'id',
			);
			if (validationError != null) {
				return validationError;
			}
			return buildVoidResult(
				apiCall: () => service.deleteCollection(args),
				message: 'Successfully deleted the collection.',
			);
		},
	);
	server.registerTool(
		'collection_folder_get',
		title: 'Get Folder Properties',
		description: 'Get a Reqable collection folder properties object by collection ID and folder ID.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: _kCollectionFolderIdentitySchema,
		outputSchema: _kFolderPropertiesSchema,
		callback: (args, extra) {
			final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
        args,
        key: 'collectionId',
      );
      if (collectionIdValidationError != null) {
        return collectionIdValidationError;
      }
      final CallToolResult? idValidationError = validateRequiredStringArgument(
        args,
        key: 'id',
      );
      if (idValidationError != null) {
        return idValidationError;
      }
			return buildContentResult(
				apiCall: () => service.getFolder(args),
			);
		},
	);
	server.registerTool(
		'collection_folder_create',
		title: 'Create Folder',
		description: 'Create a new folder in a Reqable collection, optionally under a parent folder.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the collection ID, new folder name, and optional parent folder ID.',
			properties: {
				'collectionId': _kCollectionIdScheme,
				'name': JsonString(
					title: 'Folder Name',
					description: 'The new folder name.',
				),
				'parentId': JsonString(
					title: 'Parent Folder ID',
					description: 'Optional parent folder ID.',
				),
			},
			required: ['collectionId', 'name'],
		),
		outputSchema: ToolOutputSchema(
			title: 'Folder Create Result',
			description: 'The folder ID returned by Reqable for the newly created folder.',
			properties: {
				'id': _kFolderIdScheme,
			},
			required: ['id'],
		),
		callback: (args, extra) {
			final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
				args,
				key: 'collectionId',
			);
			if (collectionIdValidationError != null) {
				return collectionIdValidationError;
			}
			final CallToolResult? nameValidationError = validateRequiredStringArgument(
				args,
				key: 'name',
			);
			if (nameValidationError != null) {
				return nameValidationError;
			}
			return buildContentResult(
				apiCall: () => service.createFolder(args),
			);
		},
	);
  if (scope == ReqableToolScope.all) {
    server.registerTool(
      'collection_folder_update',
      title: 'Update Folder Properties',
      description: 'Update a Reqable collection folder properties object.',
      annotations: ToolAnnotations(
        readOnlyHint: false,
        destructiveHint: false,
        idempotentHint: false,
      ),
      inputSchema: ToolInputSchema(
        description: 'The collection ID, folder ID, and folder properties payload.',
        properties: {
          'collectionId': JsonString(
            title: 'Collection ID',
            description: 'The containing collection ID.',
          ),
          'id': JsonString(
            title: 'Folder ID',
            description: 'The folder ID.',
          ),
          ..._kFolderPropertiesSchema.properties ?? const {},
        },
        required: ['collectionId', 'id'],
        additionalProperties: true,
      ),
      outputSchema: kMutationResultSchema,
      callback: (args, extra) {
        final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
          args,
          key: 'collectionId',
        );
        if (collectionIdValidationError != null) {
          return collectionIdValidationError;
        }
        final CallToolResult? idValidationError = validateRequiredStringArgument(
          args,
          key: 'id',
        );
        if (idValidationError != null) {
          return idValidationError;
        }
        return buildVoidResult(
          apiCall: () => service.updateFolder(args),
          message: 'Successfully updated the folder properties.',
        );
      },
    );
  }
  if (scope == ReqableToolScope.all) {
    server.registerTool(
      'collection_folder_delete',
      title: 'Delete Folder',
      description: 'Delete a folder from a Reqable collection.',
      annotations: ToolAnnotations(
        readOnlyHint: false,
        destructiveHint: true,
        idempotentHint: false,
      ),
      inputSchema: _kCollectionFolderIdentitySchema,
      outputSchema: kMutationResultSchema,
      callback: (args, extra) {
        final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
          args,
          key: 'collectionId',
        );
        if (collectionIdValidationError != null) {
          return collectionIdValidationError;
        }
        final CallToolResult? idValidationError = validateRequiredStringArgument(
          args,
          key: 'id',
        );
        if (idValidationError != null) {
          return idValidationError;
        }
        return buildVoidResult(
          apiCall: () => service.deleteFolder(args),
          message: 'Successfully deleted the folder.',
        );
      },
    );
  }
	server.registerTool(
		'collection_api_get',
		title: 'Get Http or WebSocket in Collection By ID',
		description: 'Get a Reqable HTTP or WebSocket API details in a collection by collection ID and API ID.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: ToolInputSchema(
      description: 'The collection ID and API ID.',
      properties: {
        'collectionId': _kCollectionIdScheme,
        'id': _kApiIdScheme,
      },
      required: ['collectionId', 'id'],
    ),
    outputSchema: ToolOutputSchema(
      title: 'API Details',
      description: 'The HTTP or WebSocket API details returned by Reqable.',
      properties: {
        'api': kCollectionApiSchema,
      },
      required: ['api'],
    ),
		callback: (args, extra) {
			final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
        args,
        key: 'collectionId',
      );
      if (collectionIdValidationError != null) {
        return collectionIdValidationError;
      }
      final CallToolResult? idValidationError = validateRequiredStringArgument(
        args,
        key: 'id',
      );
      if (idValidationError != null) {
        return idValidationError;
      }
			return buildContentResult(
				apiCall: () => service.getApi(args),
			);
		},
	);
	server.registerTool(
		'collection_api_create',
		title: 'Create API into Collection From cURL',
		description: 'Create a new API in a Reqable collection from a cURL command.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the collection ID, a cURL command, and an optional parent folder ID.',
			properties: {
				'collectionId': _kCollectionIdScheme,
				'parentId': _kFolderIdScheme,
				'curl': JsonString(
					title: 'cURL Command',
					description: 'The cURL command used to create the HTTP API.',
				),
			},
			required: ['collectionId', 'curl'],
		),
    outputSchema: ToolOutputSchema(
      title: 'API Details',
      description: 'The HTTP or WebSocket API details returned by Reqable.',
      properties: {
        'api': kCollectionApiSchema,
      },
      required: ['api'],
    ),
		callback: (args, extra) {
			final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
				args,
				key: 'collectionId',
			);
			if (collectionIdValidationError != null) {
				return collectionIdValidationError;
			}
			final CallToolResult? curlError = validateRequiredStringArgument(
				args,
				key: 'curl',
			);
			if (curlError != null) {
				return curlError;
			}
			return buildContentResult(
				apiCall: () => service.createApi(args),
			);
		},
	);
	server.registerTool(
		'collection_api_add',
		title: 'Add HTTP or WebSocket API into Collection',
		description: 'Add a created HTTP or WebSocket API into a Reqable collection.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: ToolInputSchema(
      description: 'The collection ID and the HTTP or WebSocket API payload.',
      properties: {
        'collectionId': _kCollectionIdScheme,
        'parentId': JsonString(
					title: 'Parent Folder ID',
					description: 'Optional parent folder ID.',
				),
        'api': kCollectionApiSchema,
      },
      required: ['collectionId', 'api'],
    ),
    outputSchema: ToolOutputSchema(
      title: 'API Details',
      description: 'The HTTP or WebSocket API details returned by Reqable.',
      properties: {
        'api': kCollectionApiSchema,
      },
      required: ['api'],
    ),
		callback: (args, extra) {
      final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
				args,
				key: 'collectionId',
			);
			if (collectionIdValidationError != null) {
				return collectionIdValidationError;
			}
      final CallToolResult? apiValidationError = validateRequiredObjectArgument(
        args,
        key: 'api',
      );
			if (apiValidationError != null) {
				return apiValidationError;
			}
			return buildContentResult(
				apiCall: () => service.addApi(args),
			);
		},
	);
	server.registerTool(
		'collection_api_update',
		title: 'Update API in Collection',
		description: 'Update an existing HTTP or WebSocket API in a Reqable collection.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: false,
			idempotentHint: false,
		),
		inputSchema: ToolInputSchema(
      description: 'The collection ID and the HTTP or WebSocket API payload.',
      properties: {
        'collectionId': _kCollectionIdScheme,
        'api': kCollectionApiSchema,
      },
      required: ['collectionId', 'api'],
    ),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
      final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
				args,
				key: 'collectionId',
			);
			if (collectionIdValidationError != null) {
				return collectionIdValidationError;
			}
      final CallToolResult? apiValidationError = validateRequiredObjectArgument(
        args,
        key: 'api',
      );
			if (apiValidationError != null) {
				return apiValidationError;
			}
			return buildVoidResult(
				apiCall: () => service.updateApi(args),
				message: 'Successfully updated the API.',
			);
		},
	);
	server.registerTool(
		'collection_api_delete',
		title: 'Delete HTTP or WebSocket API from Collection',
		description: 'Delete a HTTP or WebSocket API from a Reqable collection by collection ID and API ID.',
		annotations: ToolAnnotations(
			readOnlyHint: false,
			destructiveHint: true,
			idempotentHint: false,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the collection ID and the API ID to delete.',
			properties: {
				'collectionId': _kCollectionIdScheme,
				'id': _kApiIdScheme,
			},
			required: ['collectionId', 'id'],
		),
		outputSchema: kMutationResultSchema,
		callback: (args, extra) {
			final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
        args,
        key: 'collectionId',
      );
      if (collectionIdValidationError != null) {
        return collectionIdValidationError;
      }
      final CallToolResult? idValidationError = validateRequiredStringArgument(
        args,
        key: 'id',
      );
      if (idValidationError != null) {
        return idValidationError;
      }
			return buildVoidResult(
				apiCall: () => service.deleteApi(args),
				message: 'Successfully deleted the API from the collection.',
			);
		},
	);
  server.registerTool(
		'collection_api_generate_curl',
		title: 'Generate cURL Command for HTTP API',
		description: 'Generate a cURL command for a HTTP API in a Reqable collection by collection ID and API ID.',
		annotations: ToolAnnotations(
			readOnlyHint: true,
		),
		inputSchema: const ToolInputSchema(
			description: 'Provide the collection ID and the HTTP API ID to generate a cURL command.',
			properties: {
				'collectionId': _kCollectionIdScheme,
				'id': JsonString(
          title: 'HTTP API ID',
          description: 'The Reqable unique HTTP API identifier.',
        )
			},
			required: ['collectionId', 'id'],
		),
		callback: (args, extra) {
			final CallToolResult? collectionIdValidationError = validateRequiredStringArgument(
        args,
        key: 'collectionId',
      );
      if (collectionIdValidationError != null) {
        return collectionIdValidationError;
      }
      final CallToolResult? idValidationError = validateRequiredStringArgument(
        args,
        key: 'id',
      );
      if (idValidationError != null) {
        return idValidationError;
      }
			return buildTextResult(
				apiCall: () => service.generateCurlCommand(args),
			);
		},
	);
}

class _RestCollectionService {

	final ReqableApiClient client;

	const _RestCollectionService({
		required this.client,
	});

	Future<String> listCollections() {
		return client.sendGetRequest(
			const VoidRequest(route: '/collection/list'),
		);
	}

	Future<String> getStructure() {
		return client.sendGetRequest(
			const VoidRequest(route: '/collection/structure'),
		);
	}

	Future<String> getCollection(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/collection/get', jsonMap: args),
		);
	}

	Future<String> createCollection(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/collection/create', jsonMap: {
				'name': args['name'],
			}),
		);
	}

	Future<void> updateCollection(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/collection/update', jsonMap: args),
		);
	}

	Future<void> deleteCollection(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/collection/delete', jsonMap: args),
		);
	}

	Future<String> getFolder(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/collection/folder/get', jsonMap: args),
		);
	}

	Future<String> createFolder(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/collection/folder/create', jsonMap: args),
		);
	}

	Future<void> updateFolder(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/collection/folder/update', jsonMap: args),
		);
	}

	Future<void> deleteFolder(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/collection/folder/delete', jsonMap: args),
		);
	}

	Future<String> getApi(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/collection/api/get', jsonMap: args),
		);
	}

	Future<String> createApi(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/collection/api/create', jsonMap: args),
		);
	}

	Future<String> addApi(Map<String, dynamic> args) {
		return client.sendPostRequest(
			JsonRequest(route: '/collection/api/add', jsonMap: args),
		);
	}

	Future<void> updateApi(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/collection/api/update', jsonMap: args),
		);
	}

	Future<void> deleteApi(Map<String, dynamic> args) async {
		await client.sendPostRequest(
			JsonRequest(route: '/collection/api/delete', jsonMap: args),
		);
	}

  Future<String> generateCurlCommand(Map<String, dynamic> args) {
    return client.sendPostRequest(
      JsonRequest(route: '/collection/api/generate/curl', jsonMap: args),
    );
  }

}

const JsonString _kCollectionIdScheme = JsonString(
  title: 'Collection ID',
  description: 'The Reqable unique collection identifier.',
);

const JsonString _kFolderIdScheme = JsonString(
  title: 'Folder ID',
  description: 'The Reqable unique collection folder identifier.',
);

const JsonString _kApiIdScheme = JsonString(
  title: 'API ID',
  description: 'The Reqable unique HTTP/WebSocket API identifier.',
);

const JsonObject _kCollectionStructureNodeSchema = JsonObject(
	title: 'Collection Structure Node',
	description: 'A collection, folder, or HTTP/WebSocket node in the collection tree.',
	properties: {
		'id': JsonString(
			title: 'ID',
			description: 'The node identifier.',
		),
		'name': JsonString(
			title: 'Name',
			description: 'The node name.',
		),
		'type': JsonString(
			title: 'Type',
			description: 'The node type.',
			enumValues: ['collection', 'folder', 'api', 'websocket'],
		),
		'items': JsonArray(
			title: 'Children',
			description: 'The child nodes for collection and folder nodes.',
			items: JsonObject(
				additionalProperties: true,
			),
		),
	},
	required: ['id', 'name', 'type'],
	additionalProperties: true,
);

const JsonObject _kCollectionFolderIdentitySchema = ToolInputSchema(
	title: 'Collection Folder Identifier',
	description: 'The collection ID and folder ID.',
	properties: {
		'collectionId': _kCollectionIdScheme,
		'id': _kFolderIdScheme,
	},
	required: ['collectionId', 'id'],
);

final JsonObject _kCollectionPropertiesSchema = ToolOutputSchema(
	title: 'Collection Properties',
	description: 'The properties of a Reqable collection.',
	properties: {
		'name': JsonString(
      title: 'Name',
      description: 'The collection name.',
    ),
    'query': JsonArray(
      title: 'Inherited Query Entries',
      description: 'Collection-level inherited query parameters.',
      items: kSelectableStringEntrySchema,
    ),
    'headers': JsonArray(
      title: 'Inherited Headers',
      description: 'Collection-level inherited headers.',
      items: kSelectableStringEntrySchema,
    ),
    'script': JsonObject(
      title: 'Inherited Script',
      description: 'Collection-level inherited script.',
      properties: kRestHttpScriptSchema.properties,
      required: kRestHttpScriptSchema.required,
    ),
    'authorization': JsonOneOf(
      kRestRequestAuthorizationSchema.schemas,
      title: 'Inherited Authorization',
      description: 'Collection-level inherited authorization.',
    ),
    'documentation': kRestDocumentationSchema,
	},
	required: ['name'],
	additionalProperties: true,
);

final JsonObject _kFolderPropertiesSchema = ToolOutputSchema(
	title: 'Folder Properties',
	description: 'The properties of a Reqable collection folder.',
	properties: {
		'name': JsonString(
			title: 'Name',
			description: 'The folder name.',
		),
		'query': JsonArray(
			title: 'Inherited Query Entries',
			description: 'Folder-level inherited query parameters.',
			items: kSelectableStringEntrySchema,
		),
		'headers': JsonArray(
			title: 'Inherited Headers',
			description: 'Folder-level inherited headers.',
			items: kSelectableStringEntrySchema,
		),
		'script': JsonObject(
      title: 'Inherited Script',
      description: 'Folder-level inherited script.',
      properties: kRestHttpScriptSchema.properties,
      required: kRestHttpScriptSchema.required,
    ),
    'authorization': JsonOneOf(
      kRestRequestAuthorizationSchema.schemas,
      title: 'Inherited Authorization',
      description: 'Folder-level inherited authorization.',
    ),
		'documentation': kRestDocumentationSchema,
	},
	required: ['name'],
	additionalProperties: true,
);

const JsonSchema kCollectionApiSchema = JsonOneOf(
  [
    kRestHttpSchema,
    kRestWebSocketSchema,
  ],
  title: 'Collection API',
  description: 'A Reqable HTTP or WebSocket API in a collection.',
);