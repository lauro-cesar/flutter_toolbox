import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class StaticMethods {
  static Future<http.Response> requestDelete(Uri url, Map<String, String> requestHeaders) async {
    http.Response resposta = http.Response("", 408);
    if (!kReleaseMode) {
      print(url);
    }
    try {
      resposta = await http.Client().delete(url, headers: requestHeaders).timeout(const Duration(seconds: 240));
      if (!kReleaseMode) {}
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

  static Future<http.Response> requestHead(Uri url, Map<String, String> requestHeaders) async {
    http.Response resposta = http.Response("", 408);
    if (!kReleaseMode) {
      print(url);
    }
    try {
      resposta = await http.Client().head(url, headers: requestHeaders).timeout(const Duration(seconds: 240));
      if (!kReleaseMode) {}
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

  static Future<http.Response> requestGet(Uri url, Map<String, String> requestHeaders) async {
    http.Response resposta = http.Response("", 408);
    if (!kReleaseMode) {
      print(url);
    }
    try {
      resposta = await http.Client().get(url, headers: requestHeaders).timeout(const Duration(seconds: 240));
      if (!kReleaseMode) {}
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

  static Future<http.Response> requestPatch(Uri url, Map<String, String> requestBody, Map<String, String> requestHeaders) async {
    if (!kReleaseMode) {
      print(url);
      print(requestBody);
    }
    http.Response resposta = http.Response("", 408);
    try {
      resposta = await http.Client().patch(url, headers: requestHeaders, body: jsonEncode(requestBody)).timeout(const Duration(seconds: 240));
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

  static Future<http.Response> requestPut(Uri url, Map<String, String> requestBody, Map<String, String> requestHeaders) async {
    if (!kReleaseMode) {
      print(url);
      print(requestBody);
    }
    http.Response resposta = http.Response("", 408);
    try {
      resposta = await http.Client().put(url, headers: requestHeaders, body: jsonEncode(requestBody)).timeout(const Duration(seconds: 240));
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

  static Future<http.Response> requestPost(Uri url, Map<String, String> requestBody, Map<String, String> requestHeaders) async {
    if (!kReleaseMode) {}
    http.Response resposta = http.Response("", 408);
    try {
      resposta = await http.Client().post(url, headers: requestHeaders, body: jsonEncode(requestBody)).timeout(const Duration(seconds: 240));
      if (!kReleaseMode) {}
      return resposta;
    } on TimeoutException catch (e) {
      if (!kReleaseMode) {}

      return resposta;
    } on SocketException catch (e) {
      if (!kReleaseMode) {}
      return resposta;
    } catch (e) {
      if (!kReleaseMode) {}
      return resposta;
    }
  }
}
