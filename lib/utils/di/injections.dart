import 'package:get_it/get_it.dart';

import '../../config/app_config.dart';
import '../../config/app_flavors.dart';

final getIt = GetIt.instance;
Future<void> initInjection() async {
  // core

  // features

  // others
  await Future.wait([
    _regisConfig(),
  ]);
}

Future<void> _regisConfig() async {
  late AppFlavor flavor;
  late AppConfig appConfig;
  const flavorString =
      String.fromEnvironment('flavor', defaultValue: 'develop');
  for (var fl in AppFlavor.values) {
    if (fl.name.contains(flavorString)) {
      flavor = fl;
    }
  }
  switch (flavor) {
    case AppFlavor.develop:
      appConfig = await AppConfig.dev();
      break;
    case AppFlavor.staging:
      appConfig = await AppConfig.staging();
      break;
    case AppFlavor.production:
      appConfig = await AppConfig.prod();
      break;
  }
  getIt.registerSingleton<AppConfig>(appConfig);
}
