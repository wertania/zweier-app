import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => message;
}

/// Thin client for the Zweier backend (symbiosika framework, `/api/v1`).
class ApiClient {
  ApiClient({required String serverUrl, this.token, this.tenantId})
      : _serverUrl = normalizeServerUrl(serverUrl);

  static const apiPath = '/api/v1';

  /// Turns whatever the user typed into a server root URL:
  /// adds `https://` if no scheme is given and drops trailing slashes and a
  /// trailing `/api/v1`, e.g. `zweier.example.com/api/v1/` → `https://zweier.example.com`.
  static String normalizeServerUrl(String input) {
    var url = input.trim();
    if (!url.contains('://')) url = 'https://$url';
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.endsWith(apiPath)) url = url.substring(0, url.length - apiPath.length);
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  String _serverUrl;
  String? token;
  String? tenantId;

  /// Server root without the API path, as shown to the user.
  String get serverUrl => _serverUrl;
  set serverUrl(String value) => _serverUrl = normalizeServerUrl(value);

  Uri _uri(String path, [Map<String, String?>? query]) {
    final q = <String, String>{};
    query?.forEach((k, v) {
      if (v != null) q[k] = v;
    });
    return Uri.parse('$_serverUrl$apiPath$path').replace(queryParameters: q.isEmpty ? null : q);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> _send(String method, String path,
      {Object? body, Map<String, String?>? query}) async {
    final req = http.Request(method, _uri(path, query))..headers.addAll(_headers);
    if (body != null) req.body = jsonEncode(body);
    final streamed = await req.send().timeout(const Duration(seconds: 20));
    final res = await http.Response.fromStream(streamed);
    dynamic json;
    try {
      json = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      json = res.body;
    }
    if (res.statusCode >= 400) {
      final msg = json is Map
          ? (json['error'] ?? json['message'] ?? 'Error ${res.statusCode}').toString()
          : 'Error ${res.statusCode}';
      throw ApiException(res.statusCode, msg);
    }
    // app routes wrap their payload as {success, data}
    if (json is Map && json.containsKey('success') && json.containsKey('data')) {
      return json['data'];
    }
    return json;
  }

  String get _t => '/tenant/$tenantId';

  // ---------- Auth ----------

  /// Makes sure an account exists and sends a login code by e-mail.
  Future<void> requestLoginCode(String email) async {
    final random = Random.secure();
    final password = List.generate(32, (_) => random.nextInt(36).toRadixString(36)).join();
    try {
      await _send('POST', '/user/register',
          body: {'email': email, 'password': password, 'sendVerificationEmail': false});
    } on ApiException {
      // account exists already – fine
    }
    await _send('POST', '/user/request-login-code', body: {'email': email});
  }

  Future<String> loginWithCode(String email, String code) async {
    final res = await _send('POST', '/user/login-with-code', body: {'email': email, 'code': code});
    final t = res is Map ? res['token'] as String? : null;
    if (t == null) throw ApiException(400, 'Invalid code');
    return t;
  }

  Future<Map<String, dynamic>> me() async =>
      (await _send('GET', '/user/me')) as Map<String, dynamic>;

  // ---------- Couple (= tenant) ----------

  Future<List<Map<String, dynamic>>> myTenants() async =>
      ((await _send('GET', '/user/tenants')) as List).cast<Map<String, dynamic>>();

  Future<String> createTenant(String name) async {
    final res = await _send('POST', '/tenant', body: {'name': name});
    return (res as Map)['id'] as String;
  }

  Future<List<Invitation>> myInvitations() async {
    final list = (await _send('GET', '/user/tenants/invitations')) as List;
    return list
        .map((e) => Invitation(
              id: e['id'] as String,
              tenantId: e['tenantId'] as String,
              tenantName: e['tenantName'] as String?,
            ))
        .toList();
  }

  Future<void> acceptInvitation(Invitation inv) =>
      _send('POST', '/tenant/${inv.tenantId}/invitations/${inv.id}/accept');

  Future<void> invitePartner(String email) =>
      _send('POST', '$_t/invite', body: {'email': email, 'role': 'admin'});

  Future<List<Map<String, dynamic>>> members() async =>
      ((await _send('GET', '$_t/members')) as List).cast<Map<String, dynamic>>();

  // ---------- Ideas ----------

  Future<List<Idea>> ideas({String? destinationId}) async {
    final list = (await _send('GET', '$_t/ideas',
        query: {'destinationId': destinationId ?? 'none'})) as List;
    return list.map((e) => Idea.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Idea> saveIdea(Idea idea) async {
    final res = idea.id == null
        ? await _send('POST', '$_t/ideas', body: idea.toJson())
        : await _send('PUT', '$_t/ideas/${idea.id}', body: idea.toJson());
    return Idea.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteIdea(String id) => _send('DELETE', '$_t/ideas/$id');

  // ---------- Destinations ----------

  Future<List<Destination>> destinations() async {
    final list = (await _send('GET', '$_t/destinations')) as List;
    return list.map((e) => Destination.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Destination> saveDestination(Destination d) async {
    final res = d.id == null
        ? await _send('POST', '$_t/destinations', body: d.toJson())
        : await _send('PUT', '$_t/destinations/${d.id}', body: d.toJson());
    return Destination.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteDestination(String id) => _send('DELETE', '$_t/destinations/$id');

  // ---------- Suggestions ----------

  Future<SuggestionResult> suggestions({
    Weather? weather,
    IdeaDuration? maxDuration,
    double? latitude,
    double? longitude,
    DateTime? date,
    int count = 3,
  }) async {
    final res = await _send('GET', '$_t/suggestions', query: {
      'weather': weather?.name,
      'maxDuration': maxDuration?.apiName,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'date': date?.toIso8601String().substring(0, 10),
      'count': '$count',
    });
    return SuggestionResult.fromJson(res as Map<String, dynamic>);
  }
}
