import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../core/theme.dart';
import '../state/auth_state.dart';
import '../state/theme_controller.dart';
import '../widgets/shield_logo.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final theme = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          SoftCard(
            child: Row(children: [
              Container(
                height: 44, width: 44,
                decoration: BoxDecoration(
                    color: p.tint(AppTheme.green),
                    borderRadius: BorderRadius.circular(AppTheme.radius)),
                child: const Icon(Icons.dark_mode_rounded, color: AppTheme.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dark mode',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: p.ink)),
                    Text('Easier on the eyes at night',
                        style: TextStyle(color: p.subtle, fontSize: 12.5)),
                  ],
                ),
              ),
              Switch(
                value: theme.isDark,
                activeTrackColor: AppTheme.green,
                onChanged: (v) => context.read<ThemeController>().setDark(v),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          const _ServerConnectionTile(),
          const SizedBox(height: 14),
          _tile(p, Icons.info_outline_rounded, 'About Aegis Health',
              'AI preventive screening from your lifestyle.'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: p.tint(AppTheme.coral),
                borderRadius: BorderRadius.circular(AppTheme.radius)),
            child: Row(children: [
              const Icon(Icons.health_and_safety_rounded, color: AppTheme.coral),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    'Educational screening only, not a medical diagnosis. Please talk to a doctor.',
                    style: TextStyle(color: p.ink, fontSize: 12.5, height: 1.4)),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.high,
              minimumSize: const Size.fromHeight(54),
              side: BorderSide(color: p.tint(AppTheme.coral)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius)),
            ),
            onPressed: () async {
              await context.read<AuthState>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false);
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(children: [
              const ShieldLogo(size: 36),
              const SizedBox(height: 6),
              Text('Aegis Health · v2.0',
                  style: TextStyle(color: p.subtle, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tile(Palette p, IconData icon, String title, String body) {
    return SoftCard(
      child: Row(children: [
        Container(
          height: 44, width: 44,
          decoration: BoxDecoration(
              color: p.tint(AppTheme.green),
              borderRadius: BorderRadius.circular(AppTheme.radius)),
          child: Icon(icon, color: AppTheme.green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
              Text(body, style: TextStyle(color: p.subtle, fontSize: 12.5)),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Lets the user point the app at a different backend URL without a rebuild, 
/// USB (127.0.0.1 + adb reverse) or Wi-Fi (http://<PC-IP>:8000).
class _ServerConnectionTile extends StatefulWidget {
  const _ServerConnectionTile();
  @override
  State<_ServerConnectionTile> createState() => _ServerConnectionTileState();
}

class _ServerConnectionTileState extends State<_ServerConnectionTile> {
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SoftCard(
      onTap: _edit,
      child: Row(children: [
        Container(
          height: 44, width: 44,
          decoration: BoxDecoration(
              color: p.tint(AppTheme.green),
              borderRadius: BorderRadius.circular(AppTheme.radius)),
          child: const Icon(Icons.dns_rounded, color: AppTheme.green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Server connection',
                  style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
              Text(ApiClient.instance.baseUrl,
                  style: TextStyle(color: p.subtle, fontSize: 12.5)),
            ],
          ),
        ),
        Icon(Icons.edit_rounded, size: 18, color: p.subtle),
      ]),
    );
  }

  Future<void> _edit() async {
    final c = TextEditingController(text: ApiClient.instance.baseUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: c,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                  hintText: 'https://aegis-health-jc2o.onrender.com'),
            ),
            const SizedBox(height: 10),
            const Text(
                'Leave this on the live server unless you are developing.\n'
                'Local over USB: http://127.0.0.1:8000 '
                '(needs "adb reverse tcp:8000 tcp:8000").',
                style: TextStyle(fontSize: 11.5)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'live'),
              child: const Text('Use live server')),
          FilledButton(
              onPressed: () => Navigator.pop(context, c.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result == null) return;
    final url = result == 'live' ? AppConfig.apiBaseUrl : result;
    await ApiClient.instance.setBaseUrl(url);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server set to $url')));
    }
  }
}
