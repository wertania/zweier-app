import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import 'destinations_screen.dart';
import 'ideas_screen.dart';
import 'today_screen.dart';
import 'us_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _pages = [TodayScreen(), IdeasScreen(), DestinationsScreen(), UsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.wb_sunny_outlined), selectedIcon: const Icon(Icons.wb_sunny_rounded), label: context.l10n.navToday),
          NavigationDestination(icon: const Icon(Icons.lightbulb_outline_rounded), selectedIcon: const Icon(Icons.lightbulb_rounded), label: context.l10n.navIdeas),
          NavigationDestination(icon: const Icon(Icons.flight_takeoff_outlined), selectedIcon: const Icon(Icons.flight_takeoff_rounded), label: context.l10n.navTrips),
          NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: context.l10n.navUs),
        ],
      ),
    );
  }
}
