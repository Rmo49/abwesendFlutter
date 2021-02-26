import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/local_storage.dart';
import 'package:abwesend/model/match.dart';

class Spieler {
  int id;
  final String name;
  final String vorname;
  String email;
  String abwesend;
  String begin; // Begin datum des Truniers
  List<Match> matches;

  Spieler(this.name, this.vorname, this.email);

  Spieler.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        assert(map['vorname'] != null),
        id = int.parse(map['id']),
        name = map['name'],
        vorname = map['vorname'],
        email = map['email'],
        abwesend = map['abwesendArray'],
        begin = map['begin'];

  setMatches(List<dynamic> matchList) {
    matches = new List<Match>();
    matchList.forEach((element) {
      Match match = Match.fromMap(element);
      matches.add(match);
    });
  }
}

/// Spieler kurzform, um in einer Liste anzuzeigen
class SpielerShort {
  final String id;
  final String names;
  bool isSelected;

  SpielerShort(this.id, this.names, this.isSelected);

  SpielerShort.fromMap(Map<String, dynamic> map)
      : id = map['id'],
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
  List<SpielerShort> spielerAlle;
  // Spieler eines Tableau
  List<SpielerShort> spielerTableau;


  /// Kruzform aller Spieler von der DB lesen, diese werden in json-format geliefert
  Future<List<SpielerShort>> readAllSpielerShort() async {
    var url = LocalStorage().webAdress + "/readSpielerAll.php";
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "tableauId": global.tableauId.toString(),
      });
      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          List spielerFromDb = json.decode(response.body);
          spielerAlle = setSpielerData(spielerFromDb);
        } else {
          setSpielerError('keine Spieler gefunden');
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

  Future<List<SpielerShort>> readTableauSpielerShort(int tableauId) async {
    var url = LocalStorage().webAdress + "/readTableauSpieler.php";
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
        "tableauId": tableauId.toString(),
      });

      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          List spielerFromDb = json.decode(response.body);
          spielerTableau = setSpielerData(spielerFromDb);
        } else {
          setSpielerError('keine Spieler gefunden');
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
    List<SpielerShort> spielerList = new List<SpielerShort>();
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
  List<SpielerShort> setSpielerError(String errorMessage) {
    SpielerShort spielerErr = new SpielerShort('-1', errorMessage, false);
    List<SpielerShort> spielerListe = new List<SpielerShort>();
    spielerListe.add(spielerErr);
    return spielerListe;
  }
}