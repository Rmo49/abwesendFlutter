import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:abwesend/model/globals.dart' as global;

/// Die Lokalen-Daten lesen und speichern, ist ein Singelton
class LocalStorage {
  String webAdress;
  String scheme;
  String host;
  String path;
  String dbPw;
  String userName;
  String userPw;
  String showAbDatum;

  // für Singelton, verwenden: LocalStorage ls = LocalStorage();
  LocalStorage._privateConstructor();
  static final LocalStorage _instance = LocalStorage._privateConstructor();
  factory LocalStorage() {
    return _instance;
  }

  Map<String, dynamic> _toJson() => {
    'scheme': scheme,
    'host': host,
    'path': path,
    'dbPw': dbPw,
    'userName': userName,
    'userPw': userPw,
    'showAbDatum': showAbDatum
  };

  _fromJson(Map<String, dynamic> map) {
    _instance.scheme = map['scheme'];
    _instance.host = map['host'];
    _instance.path = map['path'];
    _instance.dbPw = map['dbPw'];
    _instance.userName = map['userName'];
    _instance.userPw = map['userPw'];
    _instance.showAbDatum = map['showAbDatum'];
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/loginData.txt');
  }

  /// Die  Daten von einem lokalenfile lesen
  /// Wenn Fehler, wird die Meldung zurückgegeben
  Future<String> readLocalData() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      Map<String, dynamic> locData  = jsonDecode(contents);
      if (locData.length > 0) {
        _fromJson(locData);
       }
      else {
        // default-Werte setzen
        initDefault();
      }
      return "";
    } catch (e) {
      initDefault();
      // If encountering an error, return error
      return e.toString();
    }
  }

  /// Die Werte für die Vars setzen
  void initDefault() {
    scheme = "https";
    host = "web Adresse";
    path = "Pfad";
    dbPw = "DB";
    userName = "Vorname";
    userPw = "pw";
    showAbDatum = "2020-01-01";
  }

  /// Die Infos im lokalen File speichern
  void saveLocalData() async {
    Map<String, dynamic> map = _toJson();
    String json = jsonEncode(map);
    await _writeLocalData(json);
    global.userName = userName;
  }


  // user und Passwort getrennt duch ";"
  Future<File> _writeLocalData(String data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data);
  }
}