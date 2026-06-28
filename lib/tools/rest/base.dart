import 'package:mcp_dart/mcp_dart.dart';

const JsonObject kRestHttpScriptSchema = JsonObject(
	title: 'HTTP Script',
	description: 'The Python script to run before sending the HTTP request or after receiving the response. Like pre-request and post-request scripts in Postman, the script can modify the request or response.',
	properties: {
		'script': JsonString(
			title: 'Script',
			description: 'The script source code. Before generating script code, always call tools or resources `script_framework` and `script_template`.',
		),
		'isEnabled': JsonBoolean(
			title: 'Enabled',
			description: 'Whether the script is enabled.',
		),
	},
	required: ['isEnabled'],
	additionalProperties: true,
);

const JsonOneOf kRestRequestAuthorizationSchema = JsonOneOf(
	[
		_kRestRequestAuthorizationInheritSchema,
		_kRestRequestAuthorizationNoneSchema,
		_kRestRequestAuthorizationBasicSchema,
		_kRestRequestAuthorizationBearerSchema,
		_kRestRequestAuthorizationApiKeySchema,
		_kRestRequestAuthorizationDigestSchema,
	],
	title: 'Authorization',
	description: 'The request authorization configuration.',
);

const JsonObject kRestDocumentationSchema = JsonObject(
	title: 'Documentation',
	description: 'This document describes the purpose of the API, important considerations, and other relevant details.',
	properties: {
		'content': JsonString(
			title: 'Content',
			description: 'Document content written using Markdown syntax.',
		),
		'updatedAt': JsonOneOf([
      JsonInteger(
        title: 'Updated At',
        description: 'The last update time in Unix milliseconds.',
      ),
      JsonNull(),
    ]),
	},
	required: ['content'],
);

const JsonObject _kRestRequestAuthorizationInheritSchema = JsonObject(
	title: 'Inherited Authorization',
	description: 'Use authorization inherited from the parent collection or folder.',
	properties: {
		'mode': JsonString(
			title: 'Authorization Mode',
			description: 'The authorization mode.',
			enumValues: ['inherit'],
		),
	},
	required: ['mode'],
);

const JsonObject _kRestRequestAuthorizationNoneSchema = JsonObject(
	title: 'No Authorization',
	description: 'Do not send any authorization data.',
	properties: {
		'mode': JsonString(
			title: 'Authorization Mode',
			description: 'The authorization mode.',
			enumValues: ['none'],
		),
	},
	required: ['mode'],
);

const JsonObject _kRestRequestAuthorizationBasicSchema = JsonObject(
	title: 'Basic Authorization',
	description: 'HTTP Basic authentication credentials.',
	properties: {
		'mode': JsonString(
			title: 'Authorization Mode',
			description: 'The authorization mode.',
			enumValues: ['basic'],
		),
		'data': JsonObject(
			title: 'Basic Credentials',
			description: 'The basic authentication credentials.',
			properties: {
				'key': JsonString(
					title: 'Username',
					description: 'The basic authentication username.',
				),
				'value': JsonString(
					title: 'Password',
					description: 'The basic authentication password.',
				),
			},
			required: ['key', 'value'],
		),
	},
	required: ['mode', 'data'],
);

const JsonObject _kRestRequestAuthorizationBearerSchema = JsonObject(
	title: 'Bearer Authorization',
	description: 'Bearer token authorization.',
	properties: {
		'mode': JsonString(
			title: 'Authorization Mode',
			description: 'The authorization mode.',
			enumValues: ['bearer'],
		),
		'data': JsonObject(
			title: 'Bearer Token',
			description: 'The bearer token payload.',
			properties: {
				'token': JsonString(
					title: 'Token',
					description: 'The bearer token string.',
				),
			},
			required: ['token'],
		),
	},
	required: ['mode', 'data'],
);

const JsonObject _kRestRequestAuthorizationApiKeySchema = JsonObject(
	title: 'API Key Authorization',
	description: 'API key authorization sent as a header or query parameter.',
	properties: {
		'mode': JsonString(
			title: 'Authorization Mode',
			description: 'The authorization mode.',
			enumValues: ['apikey'],
		),
		'data': JsonObject(
			title: 'API Key',
			description: 'The API key configuration.',
			properties: {
				'key': JsonString(
					title: 'Key',
					description: 'The API key name.',
				),
				'value': JsonString(
					title: 'Value',
					description: 'The API key value.',
				),
				'type': JsonInteger(
					title: 'Placement Type',
					description: 'Where to place the API key: 0 header, 1 query.',
					minimum: 0,
					maximum: 1,
				),
			},
			required: ['key', 'value', 'type'],
		),
	},
	required: ['mode', 'data'],
);

const JsonObject _kRestRequestAuthorizationDigestSchema = JsonObject(
	title: 'Digest Authorization',
	description: 'HTTP Digest authentication credentials and options.',
	properties: {
		'mode': JsonString(
			title: 'Authorization Mode',
			description: 'The authorization mode.',
			enumValues: ['digest'],
		),
		'data': JsonObject(
			title: 'Digest Authorization Data',
			description: 'The digest authentication configuration.',
			properties: {
				'username': JsonString(
					title: 'Username',
					description: 'The digest authentication username.',
				),
				'password': JsonString(
					title: 'Password',
					description: 'The digest authentication password.',
				),
				'options': JsonObject(
					title: 'Digest Options',
					description: 'The digest authentication parameters.',
					properties: {
						'realm': JsonString(
							title: 'Realm',
							description: 'The authentication realm.',
						),
						'nonce': JsonString(
							title: 'Nonce',
							description: 'The server nonce.',
						),
						'algorithm': JsonString(
							title: 'Algorithm',
							description: 'The digest algorithm name.',
							enumValues: ['md5', 'md5sess', 'sha256', 'sha256sess', 'sha512', 'sha512sess', 'sha512256', 'sha512256sess'],
						),
						'qop': JsonString(
							title: 'QOP',
							description: 'The quality-of-protection value.',
						),
						'nonceCount': JsonString(
							title: 'Nonce Count',
							description: 'The nonce count value.',
						),
						'clientNonce': JsonString(
							title: 'Client Nonce',
							description: 'The client nonce value.',
						),
						'opaque': JsonString(
							title: 'Opaque',
							description: 'The opaque digest parameter.',
						),
					},
					required: ['realm', 'nonce', 'algorithm', 'qop', 'nonceCount', 'clientNonce', 'opaque'],
				),
				'resend': JsonBoolean(
					title: 'Resend',
					description: 'Whether Reqable should resend the request after a digest challenge.',
				),
			},
			additionalProperties: true,
		),
	},
	required: ['mode', 'data'],
);