import 'package:flutter/material.dart';

import '../navigator/navigator_utils.dart';

class DeviceInfo {
  static final _context = NavigatorUtils.context;
  static final _media = MediaQuery.of(_context);
  static final _size = _media.size;

  static bool get isMobile => _size.shortestSide < 600;
  static bool get isTablet => !isMobile;
  static bool get isLandscape => _size.width > _size.height;
  static bool get isPortrait => !isLandscape;
}
