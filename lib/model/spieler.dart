import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/local_storage.dart';
import 'package:abwesend/model/match.dart';

class Spieler {
  int spielerID;
  String name;
  String vorname;
  String email;
  String abwesend;
  String begin; // Begin datum des Truniers
  List<Match> matches;
  List<int> tableauList;

  Spieler(this.name, this.vorname, this.email);

  Spieler.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        assert(map['vorname'] != null),
        spielerID = int.parse(map['spielerID']),
        name = map['name'],
        vorname = map['vorname'],
        email = map['email'],
        abwesend = map['abwesendArray'],
        begin = map['begin'];

  Map<String, dynamic> toJson() => {
        'spielerID': spielerID,
        'name': name,
        'vorname': vorname,
        'email': email,
        'abwesend': abwesend
      };

  setMatches(List<dynamic> matchList) {
    matches = [];
    matchList.forEach((element) {
      Match match = Match.fromMap(element);
      matches.add(match);
    });
  }

  /// Die Liste der Tableau setzen, falls gelesen
  setTableaux(List<dynamic> data) {
    tableauList = [];
    for (int i = 0; i < data.length; i++) {
      String tabStr = data[i];
      tableauList.add(int.parse(tabStr));
    }
  }

  // Die Liste der Tableau wieder setzen (falls geändert)
  void resetTableauList(List<int> newList) {
    tableauList.clear();
    tableauList = newList;
  }

  /// Einen Spieler von der DB lesen.
  static Future<Spieler> readSpieler(int spielerID) async {
    LocalStorage localStorage = LocalStorage();
    Uri uri = Uri(
        scheme: localStorage.scheme,
        host: localStorage.host,
        path: localStorage.path + "/readSpieler.php");
    var response = await http.post(uri, body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "spielerID": spielerID.toString(),
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      Spieler spieler = Spieler.fromMap(data['spieler']);
      spieler.setMatches(data['matches']);
      return spieler;
    } else {
      return null;
    }
  }

  /// Den Spieler in der DB speichern
  Future<String> saveSpieler() async {
    Map<String, dynamic> spielerJson = toJson();
    LocalStorage localStorage = LocalStorage();
    Uri uri = Uri(
        scheme: localStorage.scheme,
        host: localStorage.host,
        path: localStorage.path + "/saveSpieler.php");
    var response = await http.post(uri, body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "spieler": spielerJson.toString(),
    });
    return response.body;
  }

  /// Alle Tableau zum Spieler von der DB lesen, diese werden
  /// der Liste beim spieler gesetzt
  Future readTableau() async {
    LocalStorage localStorage = LocalStorage();
    Uri uri = Uri(
        scheme: localStorage.scheme,
        host: localStorage.host,
        path: localStorage.path + "/readSpielerTableau.php");
    var response = await http.post(uri, body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "spielerID": spielerID.toString(),
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setTableaux(data);
    }
  }

  /// Beziehungen Spieler / Tableau speichern.
  Future saveSpielerTableau() async {
    LocalStorage localStorage = LocalStorage();
    Uri uri = Uri(
        scheme: localStorage.scheme,
        host: localStorage.host,
        path: localStorage.path + "/saveSpielerTableau.php");
    StringBuffer tabString = new StringBuffer();
    tabString.write(tableauList);

    var response = await http.post(uri, body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "spielerID": spielerID.toString(),
      "tableauList": tabString.toString()
    });
    if (response.statusCode == 200) {
      // final String result = response.body;
    }
  }

  /// Den Spieler in der DB speichern
  Future<String> deleteSpieler() async {
    LocalStorage localStorage = LocalStorage();
    Uri uri = Uri(
        scheme: localStorage.scheme,
        host: localStorage.host,
        path: localStorage.path + "/deleteSpieler.php");
    var response = await http.post(uri, body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "spielerID": spielerID.toString(),
    });
    return response.body;
  }

}

/// Spieler kurzform, um in einer Liste anzuzeigen
class SpielerShort {
  final String spielerID;
  final String names;
  bool isSelected;

  SpielerShort(this.spielerID, this.names, this.isSelected);

  SpielerShort.fromMap(Map<String, dynamic> map)
      : spielerID = map['spielerID'],
        names = map['names'],
        isSelected = false;
}

/// Attribute von einem Match zur Darstellung
class MatchDisplay {
  final double pos;
  final String type;

  MatchDisplay(this.pos, this.type);

  MatchDisplay.fromMap(Map<String, dynamic> map)
      : pos = double.parse(map['pos']),
        type = map['type'];
}

//----------------------------------------------------------
/// Die Liste aller Spieler
class SpielerList {
  // alle Spieler ohne Einschränkung
  List spielerAlle;
  // Spieler eines Tableau
  List spielerTableau;

  /// Kruzform aller Spieler von der DB lesen, diese werden in json-format geliefert
  Future<List> readAllSpielerShort() async {
    Uri uri = Uri(
        scheme: global.scheme,
        host: global.host,
        path: global.path + "/readSpielerAll.php");
    try {
      final response = await http.post(uri, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "tableauID": global.tableauID.toString(),
      });
      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          // String resp = response.body;
          List spielerFromDb = json.decode(response.body);
          spielerAlle = setSpielerData(spielerFromDb);
        } else {
          spielerAlle = setSpielerError('keine Spieler gefunden');
        }
      } else {
        spielerAlle = setSpielerError(response.body);
      }
    } catch (e) {
      // Könnte sein, dass response eine Error-Message enthält
      spielerAlle = setSpielerError(e.toString());
    }
    return spielerAlle;
  }

  /// Alle Spieler eines Tableau lesen.
  Future<List> readTableauSpielerShort(int tableauID) async {
    Uri uri = Uri(
        scheme: global.scheme,
        host: global.host,
        path: global.path + "/readTableauSpieler.php");
    try {
      final response = await http.post(uri, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "tableauID": tableauID.toString(),
      });

      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          List spielerFromDb = json.decode(response.body);
          spielerTableau = setSpielerData(spielerFromDb);
        } else {
          spielerTableau = setSpielerError('keine Spieler gefunden');
        }
      } else {
        spielerTableau = setSpielerError(response.body);
      }
    } catch (e) {
      // Könnte sein, dass response eine Error-Message enthält
      spielerTableau = setSpielerError(e.toString());
    }
    return spielerTableau;
  }

  /// Die Listen mi den entsprechenden Spielern füllen
  List setSpielerData(List spielerFromDb) {
    List<SpielerShort> spielerList = [];
    spielerFromDb.forEach((element) {
      Map<String, dynamic> map = element;
      // Name und Vorname zusammen in einem Feld
      SpielerShort spielerShort =
          SpielerShort(map['id'], map['name'] + " " + map['vorname'], false);
      spielerList.add(spielerShort);
    });
    // Liste sortieren
    Comparator<SpielerShort> spielerComparator =
        (a, b) => a.names.compareTo(b.names);
    spielerList.sort(spielerComparator);
    return spielerList;
  }

  /// Die SpielerListe setzen, wenn keine Spieler gefunden,
  /// oder sonstige Fehler
  List setSpielerError(String errorMessage) {
    SpielerShort spielerErr = new SpielerShort('-1', errorMessage, false);
    var spielerListe =  [];
    spielerListe.add(spielerErr);
    return spielerListe;
  }
}
