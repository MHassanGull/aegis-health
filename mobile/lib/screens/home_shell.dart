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

  static const _items = [
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Home'),
    (Icons.forum_outlined, Icons.forum_rounded, 'Assistant'),
    (Icons.show_chart_outlined, Icons.show_chart_rounded, 'History'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

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
      body: IndexedStack(index: _index, children: _tabs),
      // A flat bar divided from the page by a single rule. No elevation, no
      // pill indicator, the active item is stated in ink weight and colour.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: p.bg,
          border: Border(top: BorderSide(color: p.line, width: AppTheme.hair)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_items.length, (i) {
                final (iconOff, iconOn, label) = _items[i];
                final on = i == _index;
                final color = on ? AppTheme.green : p.subtle;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(on ? iconOn : iconOff, size: 21, color: color),
                        const SizedBox(height: 5),
                        Text(label,
                            style: AppType.label.copyWith(
                                color: color,
                                fontSize: 9,
                                fontWeight:
                                    on ? FontWeight.w700 : FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
