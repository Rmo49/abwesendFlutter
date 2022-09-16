import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:abwesend/model/globals.dart' as global;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Die Lokalen-Daten lesen und speichern, ist ein Singelton
class LocalStorage {
  String scheme = "";
  String host = "";
  int port = 0;
  String path = "";
  String database = "";
  String dbPw ="";
  String? userName;
  String? userPw;
  String? showAbDatum;

  // final web.Storage _localStorage = web.window.localStorage;

  // für Singelton, verwenden: LocalStorage ls = LocalStorage();
  LocalStorage._privateConstructor();

  static final LocalStorage _instance = LocalStorage._privateConstructor();

  factory LocalStorage() {
    return _instance;
  }

  Map<String, dynamic> _toJson() => {
        'scheme': scheme,
        'host': host,
        'port': port,
        'path': path,
    'database': database,
        'dbPw': dbPw,
        'userName': userName,
        'userPw': userPw,
        'showAbDatum': showAbDatum
      };

  _fromJson(Map<String, dynamic> map) {
    _instance.scheme = map['scheme'];
    _instance.host = map['host'];
    _instance.port = map['port'];
    _instance.path = map['path'];
    _instance.database = map['database'];
    _instance.dbPw = map['dbPw'];
    _instance.userName = map['userName'];
    _instance.userPw = map['userPw'];
    _instance.showAbDatum = map['showAbDatum'];
  }

  Future<String> _localPath() async {
    if    (kIsWeb) {
      return "xx";
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<File> _localFile() async {
    final localPath = await _localPath();
    return File('$localPath/loginData.txt');
  }

  /// Die  Daten von einem lokalenfile lesen
  /// Wenn Fehler, wird die Meldung zurückgegeben
  Future<String> readLocalData() async {
    if (kIsWeb) {
      _initDefault();
      return "kann lokale Daten nicht lesen";
    }
    try {
      final file = await _localFile();
      // Read the file
      String contents = await file.readAsString();
      Map<String, dynamic> locData = jsonDecode(contents);
      if (locData.isNotEmpty) {
        _fromJson(locData);
      } else {
        // default-Werte setzen
        _initDefault();
      }
      return "";
    } catch (e) {
      _initDefault();
      // If encountering an error, return error
      return e.toString();
    }
  }

  /// Die Werte für die Vars setzen
  void _initDefault() {
    if (global.initWerte == 0) {
      scheme = "https";
      host = "nomadus.ch";
      port = 0;
      path = "tca/db";
      database = 'tennis';
      dbPw = "Php.4123";
      userName = "";
      userPw = "";
      showAbDatum = "2020-01-01";
    }
    if (global.initWerte == 1) {
      scheme = "http";
      host = "192.168.0.59";
      port = int.parse("8081");
      path = "db";
      dbPw = "Php.4123";
      userName = "";
      userPw = "";
      showAbDatum = "2020-01-01";
    }
  }

  /// Die Infos im lokalen File speichern
  void saveLocalData() async {
    if (kIsWeb) {
      return;
    }
    Map<String, dynamic> map = _toJson();
    String json = jsonEncode(map);
    await _writeLocalData(json);
    global.userName = userName!;
  }

  // user und Passwort getrennt duch ";"
  Future<File> _writeLocalData(String data) async {
    final file = await _localFile();

    // Write the file
    return file.writeAsString(data);
  }

}
