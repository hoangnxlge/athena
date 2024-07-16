import 'dart:developer';

import 'package:athena/features/apps/presentations/pages/apps_page.dart';
import 'package:athena/features/luna_api/presentaion/luna_api_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseRoute {
  static Widget get route => const BasePage();
}

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  final pageController = PageController();
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS): () =>
            log('AppLog: search'),
      },
      child: Scaffold(
        appBar: AppBar(),
        drawer: NavigationDrawer(
          onDestinationSelected: (index) {
            setState(() {
              pageController.jumpToPage(index);
            });
            Navigator.pop(context);
          },
          selectedIndex:
              pageController.hasClients ? pageController.page?.toInt() : 0,
          children: [
            const DrawerHeader(child: Text('Ares')),
            ...[
              (Icons.apps, 'Apps'),
              (Icons.api, 'Luna Api Testing'),
            ].map(
              (e) => NavigationDrawerDestination(
                icon: Icon(e.$1),
                label: Text(e.$2),
              ),
            )
          ],
        ),
        body: PageView(
          controller: pageController,
          children: [
            AppsRoute.route,
            LunaApiRoute.route,
          ],
        ),
      ),
    );
  }
}
