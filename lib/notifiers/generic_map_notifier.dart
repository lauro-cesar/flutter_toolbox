import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolbox/utils/app_local_files_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_toolbox/flutter_toolbox.dart';
import 'dart:io';
import 'dart:convert';

class GenericMapNotifier extends ChangeNotifier with AppLocalFilesApi {
  final String keyName;
  final bool? writeToLocalStorage;
  final bool? debugMode;
  final bool? autoNotify;

  final List<String>? keepKeys;
  final List<String>? excludeKeys;

  List<String> get _keepKeys {
    return keepKeys ?? [];
  }

  List<String> get _excludeKeys {
    return excludeKeys ?? [];
  }

  String? getStringKey(String key) {
    return instanceMap[key] ?? null;
  }

  final Map<String, dynamic> _initialMap = {"isLoaded": true};

  final Map<String, dynamic> _instanceMap = {};

  UnmodifiableMapView<String, dynamic> get instanceMap => UnmodifiableMapView(_instanceMap);

  GenericMapNotifier(
      {required this.keyName,
      this.writeToLocalStorage,
      this.debugMode,
      this.keepKeys,
      this.excludeKeys,
      this.autoNotify}) {
    reloadMap().then((_) => {
          if (autoNotify ?? true) {notifyListeners()}
        });
  }

  Future<void> reloadMap() async {
    await _loadAppState();
  }

  void onAdd(Map<String, dynamic> values) {
    _instanceMap.addAll(values);
  }

  void onNotify() {
    notifyListeners();
  }

  void onSave() {
    _saveAppState();
  }

  void addAndSave(Map<String, dynamic> values) {
    _instanceMap.addAll(values);
    _saveAppState().then((value) => {notifyListeners()});
  }

  void add(Map<String, dynamic> values) {
    _instanceMap.addAll(values);
    _saveAppState().then((value) => {notifyListeners()});
  }

  Future<void> removeKey(String keyName) async {
    _instanceMap.remove(keyName);
    await _saveAppState();
    notifyListeners();
  }

  void del(Map<String, dynamic> values) {
    _instanceMap.remove(values);
    _saveAppState().then((value) => {notifyListeners()});
  }

  void removeAll() {
    Map<String, dynamic> _writeMap = {};
    _keepKeys.forEach((key) {
      _writeMap.addAll(_instanceMap[key]);
      if (debugMode ?? false) {
        print("keeping key: $key");
      }
    });
    _instanceMap.clear();
    _instanceMap.addAll(_initialMap);
    _instanceMap.addAll(_writeMap);
    _saveAppState().then((value) => {notifyListeners()});
  }

  Future<void> _loadAppState() async {
    if (writeToLocalStorage ?? true) {
      var sharedPrefs = await SharedPreferences.getInstance();
      if (sharedPrefs.containsKey(keyName)) {
        _instanceMap.addAll(jsonDecode(sharedPrefs.getString('${keyName}').toString()));
      } else {
        _instanceMap.addAll(_initialMap);
      }
    } else {
      if (debugMode ?? false) {
        print("save not found");
      }
      _instanceMap.addAll(_initialMap);
    }
  }

  Future<void> _saveAppState() async {
    if (writeToLocalStorage ?? true) {
      var sharedPrefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> _writeMap = {};
      _writeMap.addAll(_instanceMap);
      _excludeKeys.forEach((key) {
        _writeMap.remove(key);
        if (debugMode ?? false) {
          print("Removing key: $key");
        }
      });
      await sharedPrefs.setString('${keyName}', jsonEncode(_writeMap));
    } else {
      if (debugMode ?? false) {
        print("not write");
      }
    }
  }
}
