// import 'dart:io';

// import 'package:http/http.dart' as;
// import 'package:dio/dio.dart' as dio;
// import 'http_handler.dart';

// Future<Response> httpGet(
//   String url, {
//   dynamic body,
//   Map<String, String> headers = const {},
//   bool isRedirectingStatusCode = true,
//   bool isMaintenance = false,
//   bool isSendToken = false,
// }) {
//   return NetworkService().httpGet(
//     url,
//     body: body,
//     headers: headers,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//     isMaintenance: isMaintenance,
//     isSendToken: isSendToken,
//   );
// }

// Future<Response> httpPost(
//   String url,
//   dynamic body, {
//   Map<String, String> headers = const {},
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().httpPost(
//     url,
//     body,
//     headers: headers,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// Future<Response> httpPut(
//   String url,
//   dynamic body, {
//   Map<String, String> headers = const {},
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().httpPut(
//     url,
//     body,
//     headers: headers,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// Future<Response> httpDelete(
//   String url,
//   dynamic body, {
//   Map<String, String> headers = const {},
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().httpDelete(
//     url,
//     body,
//     headers: headers,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// Future<Response> httpPostMultipart({
//   required String url,
//   required Map<String, String> fields,
//   File? imageFile,
//   String imageFieldName = 'image',
//   Map<String, String> headers = const {},
// }) {
//   return NetworkService().httpPostMultipart(
//     url: url,
//     fields: fields,
//     imageFile: imageFile,
//     imageFieldName: imageFieldName,
//     headers: headers,
//   );
// }

// Future<http.StreamedResponse> httpPostFileWithToken(
//   Uri url,
//   Map<String, String> fields,
//   File file, {
//   String fileFieldName = 'file',
//   String fileMimeType = 'application/octet-stream',
// }) {
//   return NetworkService().httpPostFileWithToken(
//     url,
//     fields,
//     file,
//     fileFieldName: fileFieldName,
//     fileMimeType: fileMimeType,
//   );
// }

// // With Token Wrappers
// Future<Response> httpGetWithToken(
//   String url, {
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().httpGetWithToken(
//     url,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// Future<Response> httpPostWithToken(
//   String url,
//   dynamic body, {
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().httpPostWithToken(
//     url,
//     body,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// Future<Response> httpPutWithToken(
//   String url,
//   dynamic body, {
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().httpPutWithToken(
//     url,
//     body,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// Future<Response> httpDeleteWithToken(
//   String url,
//   dynamic body, {
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().httpDeleteWithToken(
//     url,
//     body,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// // Dio Methods
// Future<dio.Response> dioPost(
//   String url,
//   dynamic body, {
//   Map<String, String> headers = const {},
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().dioPost(
//     url,
//     body,
//     headers: headers,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }

// Future<dio.Response> dioPostWithToken(
//   String url,
//   dynamic body, {
//   bool isRedirectingStatusCode = true,
// }) {
//   return NetworkService().dioPostWithToken(
//     url,
//     body,
//     isRedirectingStatusCode: isRedirectingStatusCode,
//   );
// }
