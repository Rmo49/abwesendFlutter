import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:abwesend/model/local_storage.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/pages/abwesend_table.dart';
import 'package:abwesend/model/globals.dart' as global;

/// Alle Abwesenheiten anzeigen
class AbwesendShow extends StatefulWidget {
  @override
  _AbwesendShowState createState() => _AbwesendShowState();
}

class _AbwesendShowState extends State<AbwesendShow> {
  // lokale Vars
  List<Spieler> _spielerAll = new List<Spieler>();
  double _percent = 0;
  String _percentString = "";

  @override
  void initState() {
    super.initState();
    readAllSpieler(global.spielerIdList);
  }

  @override
  Widget build(BuildContext context) {
    if (_spielerAll.length <= 0) {
      return new Scaffold(
        appBar: new AppBar(
          title: Text("lese Spieler von DB"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: LinearPercentIndicator(
              width: 250.0,
              lineHeight: 25.0,
              progressColor: Colors.orangeAccent,
              percent: _percent,
              center: Text("lese Spieler $_percentString %"),
              animation: false,
            ),
          ),
        ),
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Abwesenheiten anzeigen"),
      ),
      body: Column(
        children: <Widget>[
          AbwesendTable(
            spielerList: _spielerAll,
          ),
        ],
      ),
    );
  }

  //----------- DB -------------------------

  /// Spieler von der DB lesen, dieser werden in json-format geliefert
  Future readAllSpieler(List<int> spielerIdList) async {
    List<Spieler> spielerAll = await getSpielerList(spielerIdList);
    doSetState(spielerAll);
  }

  Future<List<Spieler>> getSpielerList(List<int> spielerIdList) async {
    List<Spieler> spielerAll = new List<Spieler>();
    for (int i = 0; i < spielerIdList.length; i++) {
      setState(() {
        _percent = i / spielerIdList.length;
        _percentString = (_percent * 100).toStringAsFixed(0);

      });
      var spieler = await readElement(spielerIdList.elementAt(i));
      spielerAll.add(spieler);
    }
    return spielerAll;
  }

  void doSetState(List<Spieler> spielerAll) {
    setState(() {
      _spielerAll = spielerAll;
    });
  }

  Future<Spieler> readElement(int id) async {
    LocalStorage localStorage = LocalStorage();
    var url = localStorage.webAdress + "/readSpieler.php";
    var response = await http.post(url, body: {
      "dbname": global.dbName,
      "dbuser": global.dbUser,
      "dbpass": global.dbPass,
      "id": id.toString(),
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
}
