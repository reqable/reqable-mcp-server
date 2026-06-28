import 'package:mcp_dart/mcp_dart.dart';
import 'package:reqable_mcp_server/tools/result.dart';

CallToolResult? validateRequiredStringArgument(
	Map<String, dynamic> args, {
	required String key,
  List<String>? allowedValues,
  bool allowEmpty = false,
  bool allowWhitespace = false,
}) {
	final dynamic value = args[key];
	if (value == null) {
		return buildErrorResult(
			message: 'Missing required argument: $key.',
		);
	}
	if (value is! String) {
		return buildErrorResult(
			message: 'Invalid argument type: $key should be a string.',
		);
	}
	if (!allowEmpty && value.isEmpty) {
		return buildErrorResult(
			message: 'Invalid argument: $key should not be empty.',
		);
	}
  if (!allowWhitespace && value.trim() != value) {
    return buildErrorResult(
      message: 'Invalid argument: $key should not contain leading or trailing whitespace.',
    );
  }
	if (allowedValues != null && !allowedValues.contains(value)) {
		return buildErrorResult(
			message: 'Invalid argument: $key should be one of [${allowedValues.join(', ')}].',
		);
	}
	return null;
}

CallToolResult? validateRequiredStringListArgument(
  Map<String, dynamic> args, {
  required String key,
}) {
  final dynamic value = args[key];
  if (value == null) {
    return buildErrorResult(
      message: 'Missing required argument: $key.',
    );
  }
  if (value is! List) {
    return buildErrorResult(
      message: 'Invalid argument type: $key should be a list of strings.',
    );
  }
  if (value.isEmpty) {
    return buildErrorResult(
      message: 'Invalid argument: $key list should not be empty.',
    );
  }
  final bool hasInvalidItem = value.any(
    (dynamic item) => item is! String || item.trim().isEmpty,
  );
  if (hasInvalidItem) {
    return buildErrorResult(
      message: 'Invalid argument: $key should contain only non-empty strings.',
    );
  }
  return null;
}

CallToolResult? validateRequiredBoolArgument(
	Map<String, dynamic> args, {
	required String key,
}) {
  final dynamic value = args[key];
  if (value == null) {
    return buildErrorResult(
      message: 'Missing required argument: $key.',
    );
  }
  if (value is! bool) {
    return buildErrorResult(
      message: 'Invalid argument type: $key should be a boolean.',
    );
  }
  return null;
}

CallToolResult? validateRequiredIntArgument(
  Map<String, dynamic> args, {
  required String key,
  int? minimum,
  int? maximum,
}) {
  final dynamic value = args[key];
  if (value == null) {
    return buildErrorResult(
      message: 'Missing required argument: $key.',
    );
  }
  if (value is! int) {
    return buildErrorResult(
      message: 'Invalid argument type: $key should be an integer.',
    );
  }
  if (minimum != null && value < minimum) {
    return buildErrorResult(
      message: 'Invalid argument: $key should be greater than or equal to $minimum.',
    );
  }
  if (maximum != null && value > maximum) {
    return buildErrorResult(
      message: 'Invalid argument: $key should be less than or equal to $maximum.',
    );
  }
  return null;
}

CallToolResult? validateRequiredObjectArgument(
  Map<String, dynamic> args, {
  required String key,
}) {
  final dynamic value = args[key];
  if (value == null) {
    return buildErrorResult(
      message: 'Missing required argument: $key.',
    );
  }
  if (value is! Map) {
    return buildErrorResult(
      message: 'Invalid argument type: $key should be an object.',
    );
  }
  return null;
}