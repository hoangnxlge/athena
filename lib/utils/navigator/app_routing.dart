import 'package:athena/features/base/presentation/base_page.dart';
import 'package:athena/features/luna_api/presentaion/luna_api_page.dart';
import 'package:flutter/material.dart';

import '../../features/apps/presentations/pages/apps_page.dart';

enum Routes {
  settingsPage,
  appsPage,
  lunaApiPage,
  basePage,
}

abstract class AppRouting {
  static Route onGenerateRoute(RouteSettings settings) {
    final routes = {
      Routes.appsPage.name: (_) => AppsRoute.route,
      Routes.lunaApiPage.name: (_) => LunaApiRoute.route,
      Routes.basePage.name: (_) => BaseRoute.route,
    };
    return MaterialPageRoute(
      builder: routes[settings.name]!,
      settings: settings,
    );
  }
}
