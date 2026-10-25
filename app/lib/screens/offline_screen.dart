import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/labels.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Logged in, but the server is not reachable right now.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              EmptyState(emoji: '📡', title: l.offlineTitle, text: l.offlineText),
              Text(state.api.serverUrl, style: const TextStyle(color: ZColors.plumSoft, fontSize: 12)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: state.reconnect,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.tryAgain),
              ),
              TextButton(onPressed: state.logout, child: Text(l.logout)),
            ]),
          ),
        ),
      ),
    );
  }
}
