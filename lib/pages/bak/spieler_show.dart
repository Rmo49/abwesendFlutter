import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/pages/abwesend_table.dart';
import 'package:abwesend/model/globals.dart' as global;

class SpielerShow extends StatefulWidget {
  @override
  _SpielerShowState createState() => _SpielerShowState();
}

class _SpielerShowState extends State<SpielerShow> {
  // lokale Vars
  String _txtStart = 'lese Daten';
  Spieler _spieler;
  List<Spieler> _spielerAll = new List<Spieler>();

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
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spieler anzeigen"),
      ),
      body: Column(
        children: <Widget>[
          Text(_txtStart),
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
    var url = "https://nomadus.ch/tca/db/readSpieler.php";
    var response = await http.post(url, body: {
      "dbname": global.dbname,
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

  /// Spieler von der DB lesen, dieser werden in json-format geliefert
  Future readSpieler(int spielerId) async {
    var url = "https://nomadus.ch/tca/db/readSpieler.php";
    var response = await http.post(url, body: {
      "dbname": global.dbname,
      "id": spielerId.toString(),
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      _spieler = Spieler.fromMap(data['spieler']);
      _spieler.setMatches(data['matches']);
      _spielerAll.add(_spieler);
    } else {
      return;
    }
    setState(() {});
  }
}
