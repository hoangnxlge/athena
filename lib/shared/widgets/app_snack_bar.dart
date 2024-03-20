import 'package:flutter/material.dart';

import '../../utils/navigator/navigator_utils.dart';

abstract class AppSnackBar {
  static final _context = NavigatorUtils.context;
  static void show({
    Widget? content,
    String? message,
    int? duration,
  }) {
    ScaffoldMessenger.of(_context).clearSnackBars();
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: content ?? Text(message ?? ''),
        duration: Duration(seconds: duration ?? 4),
      ),
    );
  }
}
