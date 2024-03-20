import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_flavors.dart';

class AppConfig {
  final String appName;
  final AppFlavor flavor;

  AppConfig({
    required this.appName,
    required this.flavor,
  });

  static Future<AppConfig> dev() async {
    await dotenv.load(fileName: 'env/.env.development');
    return AppConfig(
      appName: 'Athena',
      flavor: AppFlavor.develop,
    );
  }

  static Future<AppConfig> staging() async {
    await dotenv.load(fileName: 'env/.env.staging');
    return AppConfig(
      appName: 'Ares staging',
      flavor: AppFlavor.staging,
    );
  }

  static Future<AppConfig> prod() async {
    await dotenv.load(fileName: 'env/.env.prod');
    return AppConfig(
      appName: 'Ares roduction',
      flavor: AppFlavor.production,
    );
  }
}
