import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'config.dart';

/// An error with a sentence written for people, ready to show (same idea as the website).
class ApiError implements Exception {
  ApiError(this.status, this.code, this.message);
  final int status;
  final String code;
  final String message;

  @override
  String toString() => message;
}

/// The only place that talks to the backend: `/api/<service>/<path>` on [baseUrl].
/// Signing in sets the same session cookie the website uses; it is kept on the phone (so
/// the app stays signed in) and copied into the web views that show lessons and practice.
class Api {
  Api._(this._dio, this._jar);

  /// For tests: a Dio whose answers the test decides, and cookies kept in memory.
  factory Api.forTests(Dio dio) {
    final jar = CookieJar();
    dio.interceptors.add(CookieManager(jar));
    return Api._(dio, jar);
  }

  final Dio _dio;
  final CookieJar _jar;

  static Future<Api> create() async {
    final dir = await getApplicationSupportDirectory();
    final jar = PersistCookieJar(storage: FileStorage('${dir.path}/cookies'));
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'User-Agent': 'AriseloApp/0.1 (${Platform.operatingSystem})'},
      // errors are turned into ApiError below, with the server's own message
      validateStatus: (_) => true,
    ));
    dio.interceptors.add(CookieManager(jar));
    return Api._(dio, jar);
  }

  Future<dynamic> _send(String method, String service, String path, [Object? body]) async {
    Response<dynamic> r;
    try {
      r = await _dio.request<dynamic>('/api/$service$path', data: body, options: Options(method: method));
    } on DioException {
      throw ApiError(0, 'offline', "We can't reach Ariselo. Check your internet connection and try again.");
    }
    final status = r.statusCode ?? 0;
    if (status == 204) return null;
    final data = r.data;
    if (status >= 400) {
      final m = data is Map ? data : const {};
      throw ApiError(status, (m['error'] ?? 'error').toString(),
          (m['message'] ?? 'Something went wrong. Please try again.').toString());
    }
    return data;
  }

  Future<dynamic> get(String service, String path) => _send('GET', service, path);
  Future<dynamic> post(String service, String path, [Object? body]) => _send('POST', service, path, body ?? {});
  Future<dynamic> patch(String service, String path, Object body) => _send('PATCH', service, path, body);
  Future<dynamic> delete(String service, String path) => _send('DELETE', service, path);

  /// Gives the web views the same session as the app.
  Future<void> shareSessionWithWebViews() async {
    final uri = Uri.parse(baseUrl);
    final manager = WebViewCookieManager();
    await manager.clearCookies();
    for (final c in await _jar.loadForRequest(uri)) {
      await manager.setCookie(WebViewCookie(name: c.name, value: c.value, domain: uri.host, path: c.path ?? '/'));
    }
  }

  Future<void> forgetSession() async {
    await _jar.deleteAll();
    try {
      await WebViewCookieManager().clearCookies();
    } catch (_) {
      // no web views on this platform (tests)
    }
  }
}

String errorText(Object e) => e is ApiError ? e.message : 'Something went wrong. Please try again.';
