import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AppLocalFilesApi {
  Future<String> get localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> sourceFile(String filename) async {
    final path = await localPath;
    return File('$path/$filename');
  }

  Future<File> outPutFile(String filename) async {
    final path = await localPath;
    return File('$path/$filename');
  }

  Future<File> saveData(String data, String filename) async {
    final file = await outPutFile(filename);
    await file.writeAsString('$data');
    return file;
  }

  Future<String> loadFilePath(String filename) async {
    final file = await outPutFile(filename);
    if (file.existsSync()) {
      return await file.readAsString();
    } else {
      return "{}";
    }
  }

  Future<String> loadData(File file) async {
    return await file.readAsString();
  }
}
