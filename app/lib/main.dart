import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/couple_setup_screen.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const ZweierApp(),
    ),
  );
}

class ZweierApp extends StatelessWidget {
  const ZweierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zweier',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Consumer<AppState>(
        builder: (context, state, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: switch (state.stage) {
            Stage.loading => const Scaffold(body: Center(child: HeartLoader())),
            Stage.loggedOut => const LoginScreen(),
            Stage.needsCouple => const CoupleSetupScreen(),
            Stage.ready => const HomeShell(),
          },
        ),
      ),
    );
  }
}
