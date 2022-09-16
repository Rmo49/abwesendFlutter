import 'dart:convert';
import 'package:abwesend/model/my_uri.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/match.dart';

class Spieler {
  int spielerID = -1;
  String? name;
  String? vorname;
  String? email;
  String? abwesendStr;
  String? begin; // Begin datum des Truniers
  late List<Match> matches;
  List<int>? tableauList;

  Spieler(this.name, this.vorname, this.email);

  Spieler.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        assert(map['vorname'] != null),
        spielerID = int.parse(map['spielerID']),
        name = map['name'],
        vorname = map['vorname'],
        email = map['email'],
        abwesendStr = map['abwesendArray'],
        begin = map['begin'];

  Map<String, dynamic> toJson() => {
        'spielerID': spielerID,
        'name': name,
        'vorname': vorname,
        'email': email,
        'abwesend': abwesendStr
      };

  /// Den AbwesendArray leeren
  abwesendStrLeeren() {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < global.arrayLenMax; i++) {
      sb.write(";");
    }
    abwesendStr = sb.toString();
  }

  setMatches(List<dynamic> matchList) {
    matches = [];
    for (var element in matchList) {
      Match match = Match.fromMap(element);
      matches.add(match);
    }
  }

  /// Die Liste der Tableau setzen, falls gelesen
  _setTableaux(List<dynamic> data) {
    tableauList = [];
    for (int i = 0; i < data.length; i++) {
      String tabStr = data[i];
      tableauList!.add(int.parse(tabStr));
    }
  }

  // Die Liste der Tableau wieder setzen (falls geändert)
  void resetTableauList(List<int> newList) {
    if (tableauList != null) {
      tableauList!.clear();
    }
    tableauList = newList;
  }

  /// Einen Spieler von der DB lesen.
  static Future<Spieler?> readSpieler(int spielerID) async {
    final response = await http.post(MyUri.getUri("/readSpieler.php"), body: {
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
    final response = await http.post(MyUri.getUri("/saveSpieler.php"), body: {
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
    final response =
        await http.post(MyUri.getUri("/readSpielerTableau.php"), body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "spielerID": spielerID.toString(),
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _setTableaux(data);
    }
  }

  /// Beziehungen Spieler / Tableau speichern.
  Future saveSpielerTableau() async {
    StringBuffer tabString = StringBuffer();
    tabString.write(tableauList);
    final response =
        await http.post(MyUri.getUri("/saveSpielerTableau.php"), body: {
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
    final response = await http.post(MyUri.getUri("/deleteSpieler.php"), body: {
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
  final String? spielerID;
  final String? names;
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
  final String? type;

  MatchDisplay(this.pos, this.type);

  MatchDisplay.fromMap(Map<String, dynamic> map)
      : pos = double.parse(map['pos']),
        type = map['type'];
}

//----------------------------------------------------------
/// Die Liste aller Spieler
class SpielerList {
  // alle Spieler ohne Einschränkung
  List<SpielerShort> spielerAlle = [];
  // Spieler eines Tableau
  List<SpielerShort> spielerTableau = [];

  /// Kruzform aller Spieler von der DB lesen, diese werden in json-format geliefert
  Future<List<SpielerShort>> readAllSpielerShort() async {
    try {
      final response =
          await http.post(MyUri.getUri("/readSpielerAll.php"), body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "tableauID": global.tableauID.toString(),
      });
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
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
  Future<List<SpielerShort>> readTableauSpielerShort(int tableauID) async {
    try {
      final response =
          await http.post(MyUri.getUri("/readTableauSpieler.php"), body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "tableauID": tableauID.toString(),
      });

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
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
  List<SpielerShort> setSpielerData(List spielerFromDb) {
    List<SpielerShort> spielerList = [];
    for (var element in spielerFromDb) {
      Map<String, dynamic> map = element;
      // Name und Vorname zusammen in einem Feld
      SpielerShort spielerShort =
          SpielerShort(map['id'], map['name'] + " " + map['vorname'], false);
      spielerList.add(spielerShort);
    }
    // Liste sortieren
    spielerList.sort(spielerComparator);
    return spielerList;
  }

  Comparator<SpielerShort> spielerComparator =
      (a, b) => a.names!.compareTo(b.names!);

  /// Die SpielerListe setzen, wenn keine Spieler gefunden,
  /// oder sonstige Fehler
  List<SpielerShort> setSpielerError(String errorMessage) {
    SpielerShort spielerErr = SpielerShort('-1', errorMessage, false);
    List<SpielerShort> spielerListe = [];
    spielerListe.add(spielerErr);
    return spielerListe;
  }
}
