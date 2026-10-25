import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// First start: create our shared space or join the partner's.
class CoupleSetupScreen extends StatefulWidget {
  const CoupleSetupScreen({super.key});
  @override
  State<CoupleSetupScreen> createState() => _CoupleSetupScreenState();
}

class _CoupleSetupScreenState extends State<CoupleSetupScreen> {
  final _name = TextEditingController(text: 'Wir zwei');
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: state.logout, icon: const Icon(Icons.logout_rounded)),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Text('🏡', style: TextStyle(fontSize: 64), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Euer gemeinsamer Ort',
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Leg euren Bereich an und lade danach deinen Schatz ein – oder nimm eine Einladung an.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ZColors.plumSoft, height: 1.4),
          ),
          if (state.invitations.isNotEmpty) ...[
            const SectionLabel('EINLADUNGEN FÜR DICH'),
            for (final inv in state.invitations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    leading: const Text('💌', style: TextStyle(fontSize: 28)),
                    title: Text(inv.tenantName ?? 'Gemeinsamer Bereich',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Du wurdest eingeladen'),
                    trailing: FilledButton(
                      onPressed: _busy ? null : () => _run(() => state.acceptInvitation(inv)),
                      child: const Text('Annehmen'),
                    ),
                  ),
                ),
              ),
          ],
          const SectionLabel('NEU ANLEGEN'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'z. B. Anna & Ben', prefixIcon: Icon(Icons.favorite_border)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : () => _run(() => state.createCouple(_name.text.trim())),
            child: const Text('Unseren Bereich anlegen'),
          ),
        ],
      ),
    );
  }
}
