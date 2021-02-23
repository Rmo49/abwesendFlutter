import 'dart:convert';

import 'package:abwesend/model/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/tableau.dart';

/// Die Liste mit allen Tableau, eines kann dann selektiert werden.
class TableauSelect extends StatefulWidget {
  @override
  _TableauSelectState createState() => _TableauSelectState();
}

class _TableauSelectState extends State<TableauSelect> {
  String txtError = '';
  List<Tableau> tableauList;

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    readAllTableau();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Tableau wählen"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(txtError),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tableauList == null ? 0 : tableauList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${tableauList.elementAt(index).bezeichnung}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    dense: true,
                    onTap: () {
                      tableauSelektiert(context, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Wenn ein Tableau selektiert wurde, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void tableauSelektiert(BuildContext context, int index) {
    global.tableauId = tableauList[index].id;
    Navigator.pushNamed(context, '/spieler_select', arguments: {
      'tableauId': tableauList[index].id,
    });
  }

  /// Alle Spieler von der DB lesen, diese werden in json-format geliefert
  Future readAllTableau() async {
    var url = LocalStorage().webAdress + "/readTableau.php";
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
      });
      if (response.statusCode == 200) {
        List tableauFromDb = json.decode(response.body);
        setTableauData(tableauFromDb);
        setState(() {});
      } else {
        setState(() {
          txtError = response.body;
        });
        return;
      }
    } catch (e) {
      print('Error:  $e');
      setState(() {
        txtError = 'Keine Verbindung zu DB, Internet-Verbindung vorhanden?';
      });
      return;
    }
  }

  void setTableauData(List tableauFromDb) {
    List<Tableau> list = new List<Tableau>();
    tableauFromDb.forEach((element) {
      Map<String, dynamic> map = element;
//      Tableau tableau = Tableau(map['id'], map['bezeichnung'], map['position']);
      Tableau tableau = Tableau.fromMap(map);
      list.add(tableau);
    });
    // Liste sortieren
    Comparator<Tableau> tableauComparator =
        (a, b) => a.position.compareTo(b.position);
    list.sort(tableauComparator);
    // anzeigen, da build bereits ausgeführt
    setState(() {
      tableauList = list;
    });
  }
}
