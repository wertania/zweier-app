import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Our couple space: members, invite the partner, a few stats.
class UsScreen extends StatefulWidget {
  const UsScreen({super.key});
  @override
  State<UsScreen> createState() => _UsScreenState();
}

class _UsScreenState extends State<UsScreen> {
  List<Map<String, dynamic>>? _members;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final m = await context.read<AppState>().api.members();
      if (mounted) setState(() => _members = m);
    } catch (_) {
      if (mounted) setState(() => _members = []);
    }
  }

  Future<void> _invite() async {
    final ctrl = TextEditingController();
    final mail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schatz einladen 💌'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'E-Mail deines Partners'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Einladen')),
        ],
      ),
    );
    if (mail == null || mail.isEmpty || !mounted) return;
    try {
      await context.read<AppState>().api.invitePartner(mail);
      if (mounted) showLove(context, 'Einladung ist unterwegs 💌');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final doneIdeas = state.ideas.where((i) => i.done).length;
    final visited = state.destinations.where((d) => d.visited).length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(state.coupleName ?? 'Wir', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Row(children: [
            _Stat(emoji: '💡', value: state.ideas.length, label: 'Ideen'),
            const SizedBox(width: 10),
            _Stat(emoji: '💕', value: doneIdeas, label: 'Erlebt'),
            const SizedBox(width: 10),
            _Stat(emoji: '✈️', value: visited, label: 'Gereist'),
          ]),
          const SectionLabel('WIR ZWEI'),
          Card(
            child: Column(children: [
              if (_members == null) const Padding(padding: EdgeInsets.all(20), child: HeartLoader(size: 28)),
              for (final m in _members ?? [])
                ListTile(
                  leading: const CircleAvatar(backgroundColor: ZColors.blush, child: Text('🙂')),
                  title: Text((m['userEmail'] ?? m['email'] ?? '').toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(m['userEmail'] == state.email ? 'Das bist du' : 'Dein Schatz'),
                ),
              if ((_members?.length ?? 0) < 2)
                ListTile(
                  leading: const CircleAvatar(backgroundColor: ZColors.apricot, child: Icon(Icons.add, color: ZColors.rose)),
                  title: const Text('Partner:in einladen', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Dann plant ihr gemeinsam'),
                  onTap: _invite,
                ),
            ]),
          ),
          const SectionLabel('EINSTELLUNGEN'),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: const Text('Server'),
                subtitle: Text(state.api.baseUrl),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: ZColors.roseDark),
                title: const Text('Abmelden'),
                subtitle: Text(state.email ?? ''),
                onTap: state.logout,
              ),
            ]),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Mit ❤️ für euch zwei gemacht',
                style: TextStyle(color: ZColors.plumSoft, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.emoji, required this.value, required this.label});
  final String emoji;
  final int value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(color: ZColors.plumSoft, fontSize: 12)),
            ]),
          ),
        ),
      );
}
