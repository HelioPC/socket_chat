import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:socket_test/constants/storage_keys.dart';
import 'package:socket_test/constants/urls.dart';
import 'package:socket_test/utils/storage.dart';

final restClientProvider =
Provider.family<RestClient, Storage?>((ref, storage) {
  if (storage == null) {
    return RestClient(storage: ref.read(storageProvider));
  }

  return RestClient(storage: storage);
});

final class RestClient {
  final Storage storage;

  RestClient({required this.storage});

  String get baseUrl => _baseUrl.toString();

  RestClient get auth {
    _isAuth = true;

    return this;
  }

  RestClient get unAuth {
    _isAuth = false;

    return this;
  }

  String _baseUrl = UrlsConstants.baseURL;
  final Map<String, String> _headers = {"Content-Type": "application/json"};
  bool _isAuth = false;

  set baseUrl(String value) {
    _baseUrl = value;
  }

  Future<void> _authenticateRequest() async {
    final accessToken = await storage.read(StorageKeys.accessToken);
    _headers['Authorization'] = 'Bearer $accessToken';
  }

  Future<http.Response> deleteRequest({
    required String path,
    Map<String, String>? headers,
  }) async {
    if (_isAuth) {
      await _authenticateRequest();
    }

    final headersCopy = Map<String, String>.from(_headers);

    if (headers != null) headersCopy.addAll(headers);

    return await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: headersCopy,
    );
  }

  Future<http.Response> postRequest({
    required String path,
    required Map<String, Object> body,
    Map<String, String>? headers,
  }) async {
    if (_isAuth) {
      await _authenticateRequest();
    }

    final headersCopy = Map<String, String>.from(_headers);

    if (headers != null) headersCopy.addAll(headers);

    return await http.post(
      Uri.parse('$_baseUrl$path'),
      body: jsonEncode(body),
      headers: headersCopy,
    );
  }

  Future<http.Response> getRequest({
    required String path,
    Map<String, String>? headers,
  }) async {
    if (_isAuth) {
      await _authenticateRequest();
    }

    final headersCopy = Map<String, String>.from(_headers);

    if (headers != null) headersCopy.addAll(headers);

    return await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: headersCopy,
    );
  }

  Future<http.Response> patchRequest({
    required String path,
    required Map<String, Object> body,
    Map<String, String>? headers,
  }) async {
    if (_isAuth) {
      await _authenticateRequest();
    }

    final headersCopy = Map<String, String>.from(_headers);

    if (headers != null) headersCopy.addAll(headers);

    return await http.patch(
      Uri.parse('$_baseUrl$path'),
      body: jsonEncode(body),
      headers: headersCopy,
    );
  }

  Future<http.Response> sendFile({
    required String path,
    required String fieldName,
    required File file,
    required String method,
    required String type,
    required String subtype,
    Map<String, String>? headers,
  }) async {
    if (_isAuth) {
      await _authenticateRequest();
    }

    final headersCopy = Map<String, String>.from(_headers);

    if (headers != null) headersCopy.addAll(headers);

    headersCopy.remove('Content-Type');

    final stream = http.ByteStream(file.openRead());
    stream.cast();

    final length = await file.length();

    final request = http.MultipartRequest(method, Uri.parse('$_baseUrl$path'));
    request.headers.addAll(headersCopy);

    final multipart = http.MultipartFile(
      fieldName,
      stream,
      length,
      filename: file.path.split('/').last,
      contentType: MediaType(type, subtype),
    );

    request.files.add(multipart);

    final response = await request.send();

    return await http.Response.fromStream(response);
  }
}
