import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'shared/themes/app_themes.dart';
import 'utils/di/injections.dart';
import 'utils/navigator/app_routing.dart';
import 'utils/navigator/navigator_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigatorUtils.key,
      title: getIt<AppConfig>().appName,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: ThemeMode.dark,
      onGenerateRoute: AppRouting.onGenerateRoute,
      initialRoute: Routes.basePage.name,
    );
  }
}
