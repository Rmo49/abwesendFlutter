import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:abwesend/model/globals.dart' as global;

/// Die Lokalen-Daten lesen und speichern, ist ein Singelton
class LocalStorage {
  String webAdress;
  String dbPw;
  String userName;
  String userPw;

  // für Singelton, verwenden: LocalStorage ls = LocalStorage();
  LocalStorage._privateConstructor();
  static final LocalStorage _instance = LocalStorage._privateConstructor();
  factory LocalStorage() {
    return _instance;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/loginData.txt');
  }

  // die  Daten von einem file lesen
  Future<String> readLocalData() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      List<String> locData = contents.split(";");
      if (locData.length == 4) {
        webAdress = locData.elementAt(0);
        dbPw = locData.elementAt(1);
        userName = locData.elementAt(2);
        userPw = locData.elementAt(3);
      }
      else {
        // default-Werte setzen
        webAdress = "http://";
        dbPw = "DB";
        userName = "Vorname";
        userPw = "PW";
      }
      return "";
    } catch (e) {
      // If encountering an error, return empty String
      return e.toString();
    }
  }


  /// Die Infos im lokalen File speichern
  void saveLocalData() async {
    StringBuffer sb = new StringBuffer();
    sb.write(webAdress);
    sb.write(";");
    sb.write(dbPw);
    sb.write(";");
    sb.write(userName);
    sb.write(";");
    sb.write(userPw);
    await _writeLocalData(sb.toString());
    global.userName = userName;
  }

  // user und Passwort getrennt duch ";"
  Future<File> _writeLocalData(String data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data);
  }
}