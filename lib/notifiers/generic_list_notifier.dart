import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_toolbox/flutter_toolbox.dart';
import 'dart:io';
import 'dart:convert';

class GenericListNotifier extends ChangeNotifier with AppLocalFilesApi {
  final String keyName;
  final bool? writeToLocalStorage;
  final bool? debugMode;
  List<dynamic>? initialList;

  List<dynamic> get _excludeItems {
    return [];
  }

  final List<dynamic> _initialList = [];
  final List<dynamic> _instancelList = [];

  UnmodifiableListView<dynamic> get instanceList => UnmodifiableListView(_instancelList);

  GenericListNotifier({required this.keyName, this.writeToLocalStorage, this.debugMode}) {
    _loadAppState().then((value) => {notifyListeners()});
  }

  void add(item) {
    _instancelList.add(item);
    _saveAppState().then((value) => {notifyListeners()});
  }

  void del(item) {
    if (_instancelList.contains(item)) {
      _instancelList.remove(item);
      _saveAppState().then((value) => {notifyListeners()});
    }
  }

  void removeAll() {
    _instancelList.clear();
    _instancelList.addAll(_initialList);
    _saveAppState().then((value) => {notifyListeners()});
  }

  Future<void> reloadList() async {
    await _loadAppState();
  }

  Future<void> _loadAppState() async {
    if (writeToLocalStorage ?? true) {
      var sharedPrefs = await SharedPreferences.getInstance();
      var initialData = sharedPrefs.getStringList('${keyName}') ?? _initialList;
      _instancelList.addAll(initialData);
    } else {
      if (debugMode ?? false) {
        print("save not found");
      }
      _instancelList.addAll(_initialList);
    }
  }

  Future<void> _saveAppState() async {
    if (writeToLocalStorage ?? true) {
      var sharedPrefs = await SharedPreferences.getInstance();
      final List<String> _writeList = [];
      _writeList.addAll(_instancelList.map((e) => e.toString()));
      _excludeItems.forEach((key) {
        _writeList.remove(key);
        if (debugMode ?? false) {
          print("Removing key: $key");
        }
      });
      await sharedPrefs.setStringList('${keyName}', _writeList);
    } else {
      if (debugMode ?? false) {
        print("not write");
      }
    }
  }
}
