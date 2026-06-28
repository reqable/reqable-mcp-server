import 'package:mcp_dart/mcp_dart.dart';

const JsonObject kMutationResultSchema = ToolOutputSchema(
  title: 'Mutation Result',
  description: 'The result of a successful mutation operation.',
  properties: {
    'success': JsonBoolean(
      title: 'Success',
      description: 'Whether the mutation operation completed successfully.',
    ),
    'message': JsonString(
      title: 'Message',
      description: 'A short confirmation message for the completed mutation operation.',
    ),
  },
  required: ['success', 'message'],
);

const JsonObject kStringEntrySchema = JsonObject(
	title: 'String Entry',
	description: 'A key-value string entry, typically used for HTTP headers.',
	properties: {
		'key': JsonString(
			title: 'Key',
			description: 'The entry key, such as an HTTP header name.',
		),
		'value': JsonString(
			title: 'Value',
			description: 'The entry value, such as an HTTP header value.',
		),
	},
	required: ['key', 'value'],
);

const JsonObject kSelectableStringEntrySchema = JsonObject(
	title: 'Selectable String Entry',
	description: 'A key-value entry with an optional disabled flag.',
	properties: {
		'key': JsonString(
			title: 'Key',
			description: 'The entry key.',
		),
		'value': JsonString(
			title: 'Value',
			description: 'The entry value.',
		),
		'disabled': JsonBoolean(
			title: 'Disabled',
			description: 'Whether this entry is disabled.',
		),
	},
	required: ['key', 'value'],
);