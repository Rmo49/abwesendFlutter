import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/local_storage.dart';

class Config {

  static Map<String, dynamic>  configMap;


  /// Die Configuration von DB lesen, die Daten werden in json-format geliefert
  static Future<String> readConfig() async {
    LocalStorage localStorage = LocalStorage();
    String message = "";
    var url = localStorage.webAdress + "/readConfig.php";

    try {
      // var global;
      final response = await http.post(url, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
      });
      if (response.statusCode == 200) {
        configMap = json.decode(response.body);
        setGlobalData();
      } else {
        message = response.body;
      }
    } catch (e) {
      print('Fehler:  $e');
        message = 'Kann Config nicht lesen, ist eine Internet-Verbindung vorhanden? \n $e';
      }
      return message;
    }

  /// Die Config-Daten setzen in global
  static String setGlobalData() {
    if (configMap.isEmpty) {
      return 'Config Daten nicht gelesen.';
    }
    global.startDatum = global.dateFormDb.parse(configMap['turnier.beginDatum']);
    // global.startDatumAnzeigen = global.startDatum;
    global.endDatum = global.dateFormDb.parse(configMap['turnier.endDatum']);
    Duration diff = global.endDatum.difference(global.startDatum);
    // die Anzahl tage für die Anzeige
    global.arrayLen = diff.inDays + 1;
    global.arrayLen < 0
        ? global.arrayLen = -global.arrayLen
        : global.arrayLen = global.arrayLen;
    if (global.arrayLen > 21) {
      global.arrayLen = 21;
    }

    global.zeitWeekBegin = double.parse(configMap['week.beginZeit']);
    global.zeitWeekEnd = double.parse(configMap['week.endZeit']);
    global.zeitWeekendBegin = double.parse(configMap['weekend.beginZeit']);
    global.zeitWeekendEnd = double.parse(configMap['weekend.endZeit']);
    return "";
  }

  static updateConfig(String key, String newValue) {
    configMap.update(key, (value) => newValue);
  }

  /// Die Configuration von DB lesen, die Daten werden in json-format geliefert
  static Future<String> saveConfig() async {
    LocalStorage localStorage = LocalStorage();
    String message = "";
    var url = localStorage.webAdress + "/saveConfig.php";
    var config = json.encode(configMap);
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "config": config
      });
      if (response.statusCode == 200) {
        message = "gespeichert";
      } else {
        message = response.body;
      }
    } catch (e) {
      print('Fehler:  $e');
      message = 'Kann Config nicht speichen. \n $e';
    }
    return message;
  }
}