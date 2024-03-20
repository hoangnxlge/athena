import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/navigator/navigator_utils.dart';

abstract class LoadingDialog {
  static final _context = NavigatorUtils.context;
  static bool _isShow = false;
  static Future<void> show({int timeOut = 5}) async {
    Timer(Duration(seconds: timeOut), () {
      hide();
    });
    hide();
    _isShow = true;
    await showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: const AlertDialog(
            content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Loading...'),
          ],
        )),
      ),
    );
    _isShow = false;
  }

  static void hide() {
    if (_isShow) {
      Navigator.pop(_context);
      _isShow = false;
    }
  }
}
