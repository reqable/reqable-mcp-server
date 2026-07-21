import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:reqable_mcp_server/utils/json.dart';
import 'package:reqable_mcp_server/version.g.dart';

const int _kConnectTimeout = 5;
const int _kSessionTimeout = 30;

class ReqableApiClient {

  final String host;
  final int port;

  final HttpClient _httpClient = HttpClient();

  ReqableApiClient({
    required this.host,
    required this.port,
  }) {
    _httpClient.userAgent = 'reqable-mcp/$kVersionName';
    _httpClient.connectionTimeout = const Duration(
      seconds: _kConnectTimeout
    );
  }

  Future<String> sendGetRequest(Request request) {
    return _send('GET', request);

  }

  Future<String> sendPostRequest(Request request) {
    return _send('POST', request);
  }

  Future<String> _send(String method, Request req) async {
    final HttpClientRequest request;
    try {
      request = await _httpClient.open(method, host, port, req.route);
    } catch (error) {
      throw ReqableNotConnectedException(host: host, port: port);
    }
    final Map<String, dynamic> jsonMap = req.toJson();
    if (jsonMap.isNotEmpty) {
      final String body = jsonEncode(jsonMap);
      request.headers.contentType = ContentType.json;
      request.write(body);
    }
    final HttpClientResponse response = await request.close()
      .timeout(const Duration(seconds: _kSessionTimeout), onTimeout: () {
        throw TimeoutException('${req.route} access is timeout.');
      },);
    final String body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ReqableHttpException(
        method: method,
        route: req.route,
        statusCode: response.statusCode,
        message: json.tryDecode(body)?['message'] ?? body,
      );
    }
    return body;
  }

}

abstract class Request {

  Map<String, dynamic> toJson();

  String get route;

}

class VoidRequest implements Request {

  @override
  final String route;

  const VoidRequest({
    required this.route
  });

  @override
  Map<String, dynamic> toJson() => const {};

}

class JsonRequest implements Request {

  final Map<String, dynamic> jsonMap;

  @override
  final String route;

  const JsonRequest({
    required this.route,
    required this.jsonMap,
  });

  @override
  Map<String, dynamic> toJson() => jsonMap;

}

class ReqableNotConnectedException implements IOException {

  final String host;
  final int port;

  const ReqableNotConnectedException({
    required this.host,
    required this.port,
  });

  @override
  String toString() => "Reqable is not running or cannot be reached at $host:$port.";

}

class ReqableHttpException implements IOException {

  final String method;
  final String route;
  final int statusCode;
  final String message;

  const ReqableHttpException({
    required this.method,
    required this.route,
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return message;
  }

}