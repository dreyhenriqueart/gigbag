import 'package:flutter/material.dart';

import 'screens/agenda/agenda_screen.dart';
import 'screens/bags/bags_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/events/event_editor_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/app_bottom_nav.dart';

enum AppTab { home, bags, agenda }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.home;

  void _setTab(AppTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final screen = switch (_tab) {
      AppTab.home => HomeScreen(onNavigateToBags: () => _setTab(AppTab.bags)),
      AppTab.bags => const BagsScreen(),
      AppTab.agenda => const AgendaScreen(),
    };

    return Scaffold(
      body: screen,
      bottomNavigationBar: AppBottomNav(active: _tab, onSelect: _setTab),
      floatingActionButton: (_tab == AppTab.home || _tab == AppTab.bags)
          ? FloatingActionButton(
              backgroundColor: AppColors.accentTeal,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EventEditorScreen()),
                );
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }
}

