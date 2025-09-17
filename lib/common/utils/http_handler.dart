import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:webinar/app/pages/introduction_page/ip_empty_state_page.dart';
import 'package:webinar/app/pages/introduction_page/maintenance_page.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/utils/constants.dart';
import '../../locator.dart';
import '../common.dart';
import '../data/app_data.dart';

/// ====================
/// Shared Functions
/// ====================

Future<Map<String, String>> _buildHeaders({
  bool isSendToken = false,
  Map<String, String>? extraHeaders,
  bool isMultipart = false,
}) async {
  String token = await AppData.getAccessToken();
  return {
    if (isSendToken) 'Authorization': 'Bearer $token',
    'Content-Type': isMultipart ? 'multipart/form-data' : 'application/json',
    'Accept': 'application/json',
    'x-api-key': Constants.apiKey,
    'x-locale': locator<AppLanguage>().currentLanguage.toLowerCase(),
    ...?extraHeaders,
  };
}

void _checkGlobalResponses(Response res, {bool isMaintenance = false}) {
  try {
    var data = jsonDecode(res.body);

    if (data['status'] == 'restriction' && !isNavigatedIpPage) {
      nextRoute(IpEmptyStatePage.pageName, arguments: data['data'], isClearBackRoutes: true);
    } else if (isMaintenance && data['status'] == 'maintenance') {
      nextRoute(MaintenancePage.pageName, arguments: data['data'], isClearBackRoutes: true);
    }
  } catch (_) {}

  if (res.statusCode == 401) {
    nextRoute(LoginPage.pageName, isClearBackRoutes: true);
  }
}

/// ====================
/// HTTP Methods
/// ====================

Future<Response> httpGet(
  String url, {
  dynamic body,
  Map<String, String> headers = const {},
  bool isRedirectingStatusCode = true,
  bool isMaintenance = false,
  bool isSendToken = false,
}) async {
  var finalHeaders = headers.isEmpty ? await _buildHeaders(isSendToken: isSendToken) : headers;

  var request = http.Request('GET', Uri.parse(url));
  if (body != null) request.body = json.encode(body);
  request.headers.addAll(finalHeaders);

  http.StreamedResponse streamedResponse = await request.send();
  http.Response res = http.Response(await streamedResponse.stream.bytesToString(), streamedResponse.statusCode);

  _checkGlobalResponses(res, isMaintenance: isMaintenance);

  return res;
}

Future<Response> httpPost(
  String url,
  dynamic body, {
  Map<String, String> headers = const {},
  bool isRedirectingStatusCode = true,
}) async {
  var finalHeaders = headers.isEmpty ? await _buildHeaders() : headers;
  var request = http.Request('POST', Uri.parse(url));

  request.body = json.encode(body);
  request.headers.addAll(finalHeaders);

  http.StreamedResponse streamedResponse = await request.send();
  http.Response res = http.Response(await streamedResponse.stream.bytesToString(), streamedResponse.statusCode);

  if (res.statusCode == 401 && isRedirectingStatusCode) {
    nextRoute(LoginPage.pageName, isClearBackRoutes: true);
  }

  return res;
}

Future<Response> httpPut(
  String url,
  dynamic body, {
  Map<String, String> headers = const {},
  bool isRedirectingStatusCode = true,
}) async {
  var finalHeaders = headers.isEmpty ? await _buildHeaders() : headers;
  var request = http.Request('PUT', Uri.parse(url));

  request.body = body is String ? body : json.encode(body);
  request.headers.addAll(finalHeaders);

  http.StreamedResponse streamedResponse = await request.send();
  http.Response res = http.Response(await streamedResponse.stream.bytesToString(), streamedResponse.statusCode);

  if (res.statusCode == 401 && isRedirectingStatusCode) {
    nextRoute(LoginPage.pageName, isClearBackRoutes: true);
  }

  return res;
}

Future<Response> httpDelete(
  String url,
  dynamic body, {
  Map<String, String> headers = const {},
  bool isRedirectingStatusCode = true,
}) async {
  var finalHeaders = headers.isEmpty ? await _buildHeaders() : headers;
  var request = http.Request('DELETE', Uri.parse(url));

  request.body = json.encode(body);
  request.headers.addAll(finalHeaders);

  http.StreamedResponse streamedResponse = await request.send();
  http.Response res = http.Response(await streamedResponse.stream.bytesToString(), streamedResponse.statusCode);

  if (res.statusCode == 401 && isRedirectingStatusCode) {
    nextRoute(LoginPage.pageName, isClearBackRoutes: true);
  }

  return res;
}

Future<Response> httpPostMultipart({
  required String url,
  required Map<String, String> fields,
  File? imageFile,
  String imageFieldName = 'image',
  Map<String, String> headers = const {},
}) async {
  var finalHeaders = headers.isEmpty ? await _buildHeaders(isMultipart: true) : headers;
  var request = http.MultipartRequest('POST', Uri.parse(url));

  request.headers.addAll(finalHeaders);
  request.fields.addAll(fields);

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath(imageFieldName, imageFile.path));
  }

  http.StreamedResponse streamedResponse = await request.send();
  http.Response response = await http.Response.fromStream(streamedResponse);

  return response;
}

Future<http.StreamedResponse> httpPostFileWithToken(
  Uri url,
  Map<String, String> fields,
  File file, {
  String fileFieldName = 'file',
  String fileMimeType = 'application/octet-stream',
}) async {
  String token = await AppData.getAccessToken();
  var request = http.MultipartRequest('POST', url);

  request.headers.addAll({
    "Authorization": "Bearer $token",
    "x-api-key": Constants.apiKey,
    "x-locale": locator<AppLanguage>().currentLanguage.toLowerCase(),
    'Accept': 'application/json',
  });

  request.fields.addAll(fields);
  request.files.add(await http.MultipartFile.fromPath(fileFieldName, file.path, contentType: MediaType.parse(fileMimeType)));

  return request.send();
}

/// ====================
/// With Token Wrappers
/// ====================

Future<Response> httpGetWithToken(String url, {bool isRedirectingStatusCode = true}) async {
  var headers = await _buildHeaders(isSendToken: true);
  return httpGet(url, headers: headers, isRedirectingStatusCode: isRedirectingStatusCode);
}

Future<Response> httpPostWithToken(String url, dynamic body, {bool isRedirectingStatusCode = true}) async {
  var headers = await _buildHeaders(isSendToken: true);
  return httpPost(url, body, headers: headers, isRedirectingStatusCode: isRedirectingStatusCode);
}

Future<Response> httpPutWithToken(String url, dynamic body, {bool isRedirectingStatusCode = true}) async {
  var headers = await _buildHeaders(isSendToken: true);
  return httpPut(url, body, headers: headers, isRedirectingStatusCode: isRedirectingStatusCode);
}

Future<Response> httpDeleteWithToken(String url, dynamic body, {bool isRedirectingStatusCode = true}) async {
  var headers = await _buildHeaders(isSendToken: true);
  return httpDelete(url, body, headers: headers, isRedirectingStatusCode: isRedirectingStatusCode);
}

/// ====================
/// Dio Requests
/// ====================

Future<dio.Response> dioPost(
  String url,
  dynamic body, {
  Map<String, String> headers = const {},
  bool isRedirectingStatusCode = true,
}) async {
  var finalHeaders = headers.isEmpty ? await _buildHeaders() : headers;

  var res = await locator<dio.Dio>()
      .post(url, data: body, options: dio.Options(headers: finalHeaders))
      .timeout(const Duration(seconds: 30));

  if (res.statusCode == 401 && isRedirectingStatusCode) {
    nextRoute(LoginPage.pageName, isClearBackRoutes: true);
  }

  return res;
}

Future<dio.Response> dioPostWithToken(String url, dynamic body, {bool isRedirectingStatusCode = true}) async {
  var headers = await _buildHeaders(isSendToken: true);
  return dioPost(url, body, headers: headers, isRedirectingStatusCode: isRedirectingStatusCode);
}
