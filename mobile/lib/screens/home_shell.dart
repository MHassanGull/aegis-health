import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import 'home_tab.dart';
import 'chat_screen.dart';
import 'history_tab.dart';
import 'profile_tab.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;
  final _tabs = const [HomeTab(), ChatScreen(), HistoryTab(), ProfileTab()];

  @override
  void initState() {
    super.initState();
    // Warm the profile/avatar cache so the photo shows across the app.
    ApiClient.instance.getProfile().catchError((_) => <String, dynamic>{});
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _tabs[_index],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: p.card, boxShadow: p.shadow),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: p.card,
          indicatorColor: p.tint(AppTheme.green),
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppTheme.green),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon:
                    Icon(Icons.chat_bubble_rounded, color: AppTheme.green),
                label: 'Assistant'),
            NavigationDestination(
                icon: Icon(Icons.timeline_outlined),
                selectedIcon: Icon(Icons.timeline_rounded, color: AppTheme.green),
                label: 'History'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: AppTheme.green),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
