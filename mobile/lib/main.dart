import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/notifications.dart';
import 'core/theme.dart';
import 'data/reminder.dart';
import 'state/auth_state.dart';
import 'state/theme_controller.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.loadToken();
  final themeController = ThemeController();
  await themeController.load();
  // Notifications: init + re-arm any saved reminders (survives app restarts).
  await NotificationService.instance.init();
  await ReminderStore.rescheduleAll();
  runApp(AegisApp(themeController: themeController));
}

class AegisApp extends StatelessWidget {
  final ThemeController themeController;
  const AegisApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Aegis Health',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
