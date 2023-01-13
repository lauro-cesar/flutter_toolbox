import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppStaticConstants {
  static double logoSizeFactor = 0.3;
  static String pingPath = "ping/";
  static double menuIconSize = 48;
  static double menuHeight = 82;
  static int animationSpeed = 300;

  static Color errorColor = Colors.red;
  static Color accentErrorColor = Color.fromARGB(1, 160, 166, 3);
  static Color containerColor = Color.fromRGBO(169, 203, 217, 1);
  static Color focusColor = Color.fromARGB(1, 160, 166, 3);
  static Color cardColor = Colors.blue;
  static Color appForegroundColor = Color.fromRGBO(169, 203, 217, 1);
  static Color appBackgroundColor = Color.fromRGBO(242, 242, 242, 0.95);
  static Color appScaffoldBackgroundColor = Colors.black;
  static Color appScaffoldTabBarBackgroundColor = Colors.black;
  static Color appButtonGBColor = Colors.blueGrey;
  static Color materialAppColor = Color.fromRGBO(242, 242, 242, 1);

  static Color appPrimaryColor = Colors.black;
  static MaterialColor appPrimarySwatch = Colors.blueGrey;

  static Map<String, String> sessionHeaders = {
    HttpHeaders.contentTypeHeader: "application/json; charset=utf-8",
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
  };
}
