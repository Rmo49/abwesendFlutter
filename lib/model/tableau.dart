import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;

import 'my_uri.dart';

class Tableau {
  int tableauID;
  String? bezeichnung;
  String? konkurrenz;
  String? position;
  late bool isSelected;

  Tableau(this.tableauID, this.position, this.bezeichnung, this.konkurrenz);

  Tableau.fromMap(Map<String, dynamic> map)
      : tableauID = int.parse(map['tableauID']),
        bezeichnung = map['bezeichnung'],
        konkurrenz = map['konkurrenz'],
        position = map['position'],
        isSelected = false;

  Map<String, dynamic> toJson() => {
        'tableauID': tableauID,
        'position': position,
        'bezeichnung': bezeichnung,
        'konkurrenz': konkurrenz
      };

  Future<String> save() async {
    Map<String, dynamic> tableauJson = toJson();
    final response = await http.post(MyUri.getUri("/saveTableau.php"), body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "tableau": tableauJson.toString(),
    });
    return response.body;
  }

  Future<String> delete() async {
    final response = await http.post(MyUri.getUri("/deleteTableau.php"), body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "tableauID": tableauID.toString(),
    });
    return response.body;
  }
}

// Die Liste alller Tabelaux
class TableauList {
  List<Tableau> allTableau = [];

  /// Alle Tableau von der DB lesen, diese werden in json-format geliefert
  Future<List<Tableau>> readAllTableau() async {
    try {
      final response = await http.post(MyUri.getUri("/readTableau.php"), body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
      });
      if (response.statusCode == 200) {
        List tableauFromDb = json.decode(response.body);
        _setTableauData(tableauFromDb);
      }
    } catch (e) {
      print('Error:  $e');
      List<Tableau> tabList = [];
      Tableau tableau = new Tableau(-1, '0', 'keine Daten', '0');
      tabList.add(tableau);
      allTableau = tabList;
    }
    return allTableau;
  }

  /// Die Tableau Liste mit allen Werten f??llen
  void _setTableauData(List tableauFromDb) {
    List<Tableau> tabList = [];
    tableauFromDb.forEach((element) {
      Map<String, dynamic> map = element;
      Tableau tableau = Tableau.fromMap(map);
      tabList.add(tableau);
    });
    // Liste sortieren
    Comparator<Tableau> tableauComparator =
        (a, b) => a.position!.compareTo(b.position!);
    tabList.sort(tableauComparator);
    allTableau = tabList;
  }
}
