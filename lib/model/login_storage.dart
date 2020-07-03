import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LoginStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/loginData.txt');
  }

  //
  Future<String> readLogin() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If encountering an error, return empty String
      return "";
    }
  }

  // user und Passwort getrennt duch ";"
  Future<File> writeLogin(String userPassword) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(userPassword);
  }
}