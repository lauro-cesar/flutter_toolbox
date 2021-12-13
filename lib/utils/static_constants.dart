import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static GlobalKey loginFormKey = GlobalKey<FormState>();
  static GlobalKey signInFormKey = GlobalKey<FormState>();
  static GlobalKey recoverFormKey = GlobalKey<FormState>();
  final GlobalKey scaffoldAppKey = GlobalKey<ScaffoldState>();
  static GlobalKey searchFormKey = GlobalKey<FormState>();
  static GlobalKey<ScaffoldState> mainMenuScaffoldKey = GlobalKey<ScaffoldState>();

  static double logoSizeFactor = 0.3;
  static String mainLogoPath = "assets/images/logo_gestaolog.png";
  static String mainBgPath = "assets/images/logo_gestaolog.png";
  static String loginIcon = "assets/icons/logo_gestaolog.png";
  static String loginBgPath = "assets/images/img_background.png";
  static String signinBgPath = "assets/images/img_background.png";
  static String appBgPath = "assets/images/img_background.png";
  static String placeHolderPath = "assets/images/img_caminhao.png";
  static String truckImg = "assets/images/img_caminhao.png";


  static String get baseUrl {
    if (kReleaseMode) {
      return "https://wmsapi.gestaolog.com.br/backend";
    }
    return "https://wmsapi.gestaolog.com.br/backend";
  }

  static String get pingUrl {
    if (kReleaseMode) {
      return "https://wms.gestaolog.com.br";
    }
    return "https://wms.gestaolog.com.br";
  }


  static String appDeviceResource = "rest-api/public/devices/";
  static String loginpath = "api-token-auth/";
  static String signinpath = "accounts/create/";
  static String recoverpath = "/accounts/app/password_reset/";
  static String profilepath = "rest-api/public/profile/";
  static String settingsPath = "rest-api/public/settings/";
  static String checklistsPath = "/rest-api/v1/checklists/lists/";
  static String modelosPath = "rest-api/v1/checklists/modelos/";
  static String oficinasPath = "rest-api/v1/checklists/oficinas/";
  static String fabricantesPath = "rest-api/v1/checklists/fabricantes/";
  static String respostasPath = "rest-api/v1/checklists/respostas/";
  static String pingPath = "ping/";

  static double menuIconSize = 48;
  static double menuHeight = 82;
  static int animationSpeed = 300;

  static String appTitle = "Gestão log";

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
