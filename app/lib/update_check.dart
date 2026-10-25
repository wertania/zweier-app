import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api/api_client.dart';
import 'l10n/labels.dart';
import 'state/app_state.dart';
import 'theme.dart';

/// Compares "x.y.z" versions; anything after the third number is ignored.
int compareVersions(String a, String b) {
  List<int> parts(String v) {
    final nums = v.split(RegExp(r'[^0-9]+')).where((p) => p.isNotEmpty).map(int.parse).toList();
    while (nums.length < 3) {
      nums.add(0);
    }
    return nums.take(3).toList();
  }

  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < 3; i++) {
    if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
  }
  return 0;
}

class UpdateInfo {
  UpdateInfo({required this.current, required this.latest, required this.required, required this.downloadUrl});
  final String current;
  final String latest;

  /// The server no longer supports [current] – the update is not optional.
  final bool required;
  final String downloadUrl;

  /// Decides from the server answer whether an update is due; null if not.
  static UpdateInfo? fromServer(String current, Map<String, dynamic> server) {
    final latest = server['latestVersion'] as String?;
    final min = server['minVersion'] as String?;
    final url = server['downloadUrl'] as String? ?? '';
    final required = min != null && compareVersions(current, min) < 0;
    if (!required && (latest == null || compareVersions(current, latest) >= 0)) return null;
    return UpdateInfo(
      current: current,
      latest: latest ?? min!,
      required: required,
      downloadUrl: url,
    );
  }
}

/// Asks the server for the newest app version. Never throws.
Future<UpdateInfo?> checkForUpdate(ApiClient api) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final server = await api.appVersion();
    return UpdateInfo.fromServer(info.version, server);
  } catch (_) {
    return null;
  }
}

/// Shows the "please update" dialog – once per new version, unless required.
Future<void> showUpdateDialogIfNeeded(BuildContext context, UpdateInfo update) async {
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {}
  const key = 'updateDismissedFor';
  if (!update.required && prefs?.getString(key) == update.latest) return;
  if (!context.mounted) return;

  final l = context.l10n;
  await showDialog<void>(
    context: context,
    barrierDismissible: !update.required,
    builder: (ctx) => PopScope(
      canPop: !update.required,
      child: AlertDialog(
        icon: const Text('💌', style: TextStyle(fontSize: 40)),
        title: Text(l.updateTitle),
        content: Text(
          update.required ? l.updateRequiredText(update.latest) : l.updateText(update.latest, update.current),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (!update.required)
            TextButton(
              onPressed: () {
                prefs?.setString(key, update.latest);
                Navigator.pop(ctx);
              },
              child: Text(l.later),
            ),
          FilledButton(
            onPressed: () => openDownload(update.downloadUrl),
            child: Text(l.updateNow),
          ),
        ],
      ),
    ),
  );
}

Future<void> openDownload(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Small card for the settings: "Update available".
class UpdateTile extends StatelessWidget {
  const UpdateTile({super.key, required this.update});
  final UpdateInfo update;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const CircleAvatar(backgroundColor: ZColors.blush, child: Text('💌')),
        title: Text(context.l10n.updateTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${update.current} → ${update.latest}'),
        trailing: const Icon(Icons.download_rounded, color: ZColors.rose),
        onTap: () => openDownload(update.downloadUrl),
      );
}

/// Checks for a new app version on start and whenever the app comes back to
/// the foreground, on every screen (also before login).
class UpdateWatcher extends StatefulWidget {
  const UpdateWatcher({super.key, required this.child});
  final Widget child;
  @override
  State<UpdateWatcher> createState() => _UpdateWatcherState();
}

class _UpdateWatcherState extends State<UpdateWatcher> with WidgetsBindingObserver {
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_dialogOpen) return;
    final update = await context.read<AppState>().refreshUpdate();
    if (update == null || !mounted) return;
    _dialogOpen = true;
    await showUpdateDialogIfNeeded(context, update);
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
