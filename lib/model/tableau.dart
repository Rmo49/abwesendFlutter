import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/local_storage.dart';
import 'package:abwesend/model/globals.dart' as global;

class Tableau {
  int tableauID;
  String bezeichnung;
  String konkurrenz;
  String position;
  bool isSelected;

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
    LocalStorage localStorage = LocalStorage();
    var url = localStorage.webAdress + "/saveTableau.php";
    var response = await http.post(url, body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "tableau": tableauJson.toString(),
    });
    return response.body;
  }

  Future<String> delete() async {
    LocalStorage localStorage = LocalStorage();
    var url = localStorage.webAdress + "/deleteTableau.php";
    var response = await http.post(url, body: {
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
  List<Tableau> allTableau;

  /// Alle Tableau von der DB lesen, diese werden in json-format geliefert
  Future<List<Tableau>> readAllTableau() async {
    var url = LocalStorage().webAdress + "/readTableau.php";
    try {
      final response = await http.post(url, body: {
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
      allTableau = new List<Tableau>();
      Tableau tableau = new Tableau(-1, '0', 'keine Daten', '0');
      allTableau.add(tableau);
    }
    return allTableau;
  }

  void _setTableauData(List tableauFromDb) {
    List<Tableau> list = new List<Tableau>();
    tableauFromDb.forEach((element) {
      Map<String, dynamic> map = element;
      Tableau tableau = Tableau.fromMap(map);
      list.add(tableau);
    });
    // Liste sortieren
    Comparator<Tableau> tableauComparator =
        (a, b) => a.position.compareTo(b.position);
    list.sort(tableauComparator);
    allTableau = list;
  }
}
