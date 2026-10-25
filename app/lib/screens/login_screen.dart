import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/labels.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
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

  Future<void> _editServer() async {
    final state = context.read<AppState>();
    final ctrl = TextEditingController(text: state.api.baseUrl);
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.server),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'https://…/api/v1')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(context.l10n.save)),
        ],
      ),
    );
    if (url != null && url.isNotEmpty) await state.setBaseUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ZColors.blush, ZColors.cream, ZColors.apricot],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Text('💞', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 8),
                  Text(context.l10n.appTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 40)),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ZColors.plumSoft, fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 36),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: !_codeSent
                        ? Column(key: const ValueKey('mail'), children: [
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                  hintText: context.l10n.emailHint, prefixIcon: const Icon(Icons.mail_outline_rounded)),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _busy
                                    ? null
                                    : () => _run(() async {
                                          await state.requestCode(_email.text);
                                          setState(() => _codeSent = true);
                                        }),
                                child: _busy
                                    ? const SizedBox(
                                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(context.l10n.sendCode),
                              ),
                            ),
                          ])
                        : Column(key: const ValueKey('code'), children: [
                            Text(context.l10n.codeSentTo(state.email ?? ''),
                                textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _code,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700),
                              decoration: const InputDecoration(hintText: '••••••'),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _busy ? null : () => _run(() => state.verifyCode(_code.text)),
                                child: Text(context.l10n.letsGo),
                              ),
                            ),
                            TextButton(
                                onPressed: () => setState(() => _codeSent = false),
                                child: Text(context.l10n.useOtherEmail)),
                          ]),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: _editServer,
                    icon: const Icon(Icons.dns_outlined, size: 16, color: ZColors.plumSoft),
                    label: Text(context.l10n.setServer, style: const TextStyle(color: ZColors.plumSoft)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
