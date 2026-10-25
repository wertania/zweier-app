import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../models/models.dart';
import '../update_check.dart';

/// Default backend. Override at build time with `--dart-define=SERVER_URL=…`
/// (e.g. `http://10.0.2.2:3000` for a local backend from the Android emulator).
const _defaultServerUrl = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'https://zweier-app.resomo.de',
);

/// `offline`: logged in, but the server could not be reached or failed.
enum Stage { loading, loggedOut, offline, needsCouple, ready }

/// Central app state: session, our couple space, ideas and destinations.
class AppState extends ChangeNotifier {
  final api = ApiClient(serverUrl: _defaultServerUrl);
  late SharedPreferences _prefs;

  Stage stage = Stage.loading;
  String? email;
  String? coupleName;
  List<Invitation> invitations = [];
  List<Idea> ideas = [];
  List<Destination> destinations = [];

  /// Set when the server knows a newer app version.
  UpdateInfo? update;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // 'baseUrl' is the key used by 1.0.0 (stored with the API path)
    api.serverUrl =
        _prefs.getString('serverUrl') ?? _prefs.getString('baseUrl') ?? _defaultServerUrl;
    api.token = _prefs.getString('token');
    email = _prefs.getString('email');
    if (api.token == null) {
      _setStage(Stage.loggedOut);
      return;
    }
    await reconnect();
  }

  /// Loads our space again; an expired session logs out, anything else
  /// (no network, server error) keeps the session and shows a retry screen.
  Future<void> reconnect() async {
    _setStage(Stage.loading);
    try {
      await _resolveCouple();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await logout();
      } else {
        lastError = e.message;
        _setStage(Stage.offline);
      }
    } catch (e) {
      lastError = '$e';
      _setStage(Stage.offline);
    }
  }

  /// Message of the last failed [reconnect].
  String? lastError;

  void _setStage(Stage s) {
    stage = s;
    notifyListeners();
  }

  /// Asks the server whether a newer app version exists.
  Future<UpdateInfo?> refreshUpdate() async {
    update = await checkForUpdate(api);
    notifyListeners();
    return update;
  }

  Future<void> setServerUrl(String url) async {
    api.serverUrl = url.trim().isEmpty ? _defaultServerUrl : url;
    await _prefs.setString('serverUrl', api.serverUrl);
    await _prefs.remove('baseUrl');
    notifyListeners();
  }

  Future<void> requestCode(String mail) async {
    email = mail.trim().toLowerCase();
    await api.requestLoginCode(email!);
  }

  Future<void> verifyCode(String code) async {
    api.token = await api.loginWithCode(email!, code.trim());
    await _prefs.setString('token', api.token!);
    await _prefs.setString('email', email!);
    await _resolveCouple();
  }

  Future<void> _resolveCouple() async {
    final tenants = await api.myTenants();
    if (tenants.isEmpty) {
      invitations = await api.myInvitations();
      _setStage(Stage.needsCouple);
      return;
    }
    api.tenantId = tenants.first['tenantId'] as String;
    coupleName = tenants.first['name'] as String?;
    await refreshAll();
    _setStage(Stage.ready);
  }

  Future<void> createCouple(String name) async {
    await api.createTenant(name);
    await _resolveCouple();
  }

  Future<void> acceptInvitation(Invitation inv) async {
    await api.acceptInvitation(inv);
    await _resolveCouple();
  }

  Future<void> logout() async {
    api.token = null;
    api.tenantId = null;
    await _prefs.remove('token');
    ideas = [];
    destinations = [];
    _setStage(Stage.loggedOut);
  }

  // ---------- data ----------

  Future<void> refreshAll() async {
    final results = await Future.wait([api.ideas(), api.destinations()]);
    ideas = results[0] as List<Idea>;
    destinations = results[1] as List<Destination>;
    notifyListeners();
  }

  Future<void> saveIdea(Idea idea) async {
    await api.saveIdea(idea);
    await refreshAll();
  }

  Future<void> toggleDone(Idea idea) async {
    idea.done = !idea.done;
    notifyListeners();
    await saveIdea(idea);
  }

  Future<void> toggleFavorite(Idea idea) async {
    idea.favorite = !idea.favorite;
    notifyListeners();
    await saveIdea(idea);
  }

  Future<void> deleteIdea(Idea idea) async {
    await api.deleteIdea(idea.id!);
    await refreshAll();
  }

  Future<void> saveDestination(Destination d) async {
    await api.saveDestination(d);
    await refreshAll();
  }

  Future<void> deleteDestination(Destination d) async {
    await api.deleteDestination(d.id!);
    await refreshAll();
  }
}
