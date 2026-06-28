import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp/utils/json.dart';

Future<CallToolResult> buildContentResult({
  required Future<String> Function() apiCall,
  required String Function(dynamic) contentBuilder,
}) async {
  final String result;
  try {
    result = await apiCall();
    final dynamic structuredResult = json.tryDecode(result);
    if (structuredResult is Map<String, dynamic>) {
      return CallToolResult(
        content: [
          TextContent(
            text: contentBuilder(structuredResult)
          )
        ],
        structuredContent: structuredResult
      );
    } else if (structuredResult is List) {
      return CallToolResult(
        content: [
          TextContent(
            text: contentBuilder(structuredResult)
          )
        ],
        structuredContent: {
          'items': structuredResult
        },
      );
    } else {
      return CallToolResult(
        content: [
          TextContent(
            text: contentBuilder(result)
          )
        ],
      );
    }
  } catch (error) {
    return buildErrorResult(
      message: error.toString()
    );
  }
}

Future<CallToolResult> buildVoidResult({
  required Future<void> Function() apiCall,
  required String message,
}) async {
  try {
    await apiCall();
    return CallToolResult(
      content: [
        TextContent(
          text: message,
        )
      ],
      structuredContent: {
        'success': true,
        'message': message,
      },
    );
  } catch (error) {
    return buildErrorResult(
      message: error.toString()
    );
  }
}

CallToolResult buildErrorResult({
  required String message,
}) {
  return CallToolResult(
    content: [
      TextContent(
        text: message
      )
    ],
    isError: true,
  );
}