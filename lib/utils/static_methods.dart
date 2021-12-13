import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';



class StaticMethods {


  static Future<String?> getDeviceID() async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();


    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    }

    if(Platform.isAndroid){
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }

    return "0-0-0-0-";

  }

  static Future<http.Response> requestGet(Uri url, Map<String, String> requestHeaders) async {
    http.Response resposta = http.Response("", 408);
    if (!kReleaseMode) {
      print(url);
    }
    try {
      resposta = await http.Client().get(url, headers: requestHeaders).timeout(const Duration(seconds: 240));
      if (!kReleaseMode) {
        print(resposta.body);
      }
      return resposta;
    } on TimeoutException catch (e) {
      if (!kReleaseMode) {
        print(e);
      }
      return resposta;
    } on SocketException catch (e) {
      if (!kReleaseMode) {
        print(e);
      }
      return resposta;
    } catch (e) {
      if (!kReleaseMode) {
        print(e);
      }
      return resposta;
    }
  }

  static Future<http.Response> requestPost(
      Uri url, Map<String, String> requestBody, Map<String, String> requestHeaders) async {
    if (!kReleaseMode) {
      print(url);
      print(requestBody);
    }
    http.Response resposta = http.Response("", 408);
    try {
      resposta = await http.Client()
          .post(url, headers: requestHeaders, body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 240));
      if (!kReleaseMode) {
        print(resposta.body);
      }
      return resposta;
    } on TimeoutException catch (e) {
      if (!kReleaseMode) {
        print(e);
      }

      return resposta;
    } on SocketException catch (e) {
      if (!kReleaseMode) {
        print(e);
      }
      return resposta;
    } catch (e) {
      if (!kReleaseMode) {
        print(e);
      }
      return resposta;
    }
  }

  static Future<http.Response> submitForm(
      Uri url, Map<String, String> requestBody, Map<String, String> requestHeaders) async {
    final resposta = await http.Client()
        .post(url, headers: requestHeaders, body: jsonEncode(requestBody), encoding: Encoding.getByName("utf-8"));
    return resposta;
  }



  static Future<void> unFocus(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
