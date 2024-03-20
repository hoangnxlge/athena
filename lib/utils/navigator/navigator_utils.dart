import 'package:flutter/material.dart';

class NavigatorUtils {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  static final BuildContext context = key.currentContext!;
}
