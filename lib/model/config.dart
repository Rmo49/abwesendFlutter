import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;

import 'my_uri.dart';

class Config {

  static Map<String, dynamic>?  configMap;


  /// Die Configuration von DB lesen, die Daten werden in json-format geliefert
  static Future<String> readConfig() async {
    String message = "";
    try {
      // var global;
      final response = await http.post(MyUri.getUri("/readConfig.php"), body: {
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
      debugPrint ('Fehler:  $e');
        message = 'Kann Config nicht lesen, ist eine Internet-Verbindung vorhanden? \n $e';
      }
      return message;
    }

  /// Die Config-Daten setzen in global
  static String setGlobalData() {
    if (configMap!.isEmpty) {
      return 'Config Daten nicht gelesen.';
    }
    global.startDatum = global.dateFormDb.parse(configMap!['turnier.beginDatum']);
    // global.startDatumAnzeigen = global.startDatum;
    global.endDatum = global.dateFormDb.parse(configMap!['turnier.endDatum']);
    Duration diff = global.endDatum.difference(global.startDatum);
    // die Anzahl tage für die Anzeige
    global.arrayLenMax = diff.inDays + 1;
    global.arrayLenMax < 0
        ? global.arrayLenMax = -global.arrayLenMax
        : global.arrayLenMax = global.arrayLenMax;
    if (global.arrayLenMax > global.arrayLenMaxAbsolut) {
      global.arrayLenMax = global.arrayLenMaxAbsolut;
    }

    global.zeitWeekBegin = double.parse(configMap!['week.beginZeit']);
    global.zeitWeekEnd = double.parse(configMap!['week.endZeit']);
    global.zeitWeekendBegin = double.parse(configMap!['weekend.beginZeit']);
    global.zeitWeekendEnd = double.parse(configMap!['weekend.endZeit']);
    global.spielerListMax = int.parse(configMap!['spieler.liste.max']);
    return "";
  }

  static updateConfig(String key, String newValue) {
    if (key.isNotEmpty && newValue.isNotEmpty) {
      configMap!.update(key, (value) => newValue);
    }
  }

  /// Die Configuration von DB lesen, die Daten werden in json-format geliefert
  static Future<String> saveConfig(String key, String value) async {
    String? message = "";
    try {
      final response = await http.post(MyUri.getUri("/saveConfig.php"), body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "userName": global.userName,
        "configToken": key,
        "configWert": value
      });
      if (response.statusCode == 200) {
        message = "OK gespeichert";
      } else {
        message = response.reasonPhrase as String;
      }
    } catch (e) {
      debugPrint('Fehler:  $e');
      message = 'Kann Config nicht speichen. \n $e';
    }
    return message;
  }
}