import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
  List<Spieler> _spielerList = [];
  double _percent = 0;
  String _percentString = "";

  @override
  void initState() {
    super.initState();
    readAllSpieler(global.spielerIdList);
  }

  @override
  Widget build(BuildContext context) {
    if (_spielerList.length <= 0) {
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
            spielerList: _spielerList,
          ),
        ],
      ),
    );
  }

  //----------- DB -------------------------

  /// Spieler von der DB lesen, dieser werden in json-format geliefert
  Future readAllSpieler(List<int> spielerIdList) async {
    List<Spieler> spielerAllDb = await getSpielerList(spielerIdList);
    doSetState(spielerAllDb);
  }

  Future<List<Spieler>> getSpielerList(List<int> spielerIdList) async {
    List<Spieler> spielerListDb = [];
    for (int i = 0; i < spielerIdList.length; i++) {
      setState(() {
        _percent = i / spielerIdList.length;
        _percentString = (_percent * 100).toStringAsFixed(0);
      });

      var spieler = await Spieler.readSpieler(spielerIdList.elementAt(i));
      spielerListDb.add(spieler);
    }
    return spielerListDb;
  }

  void doSetState(List<Spieler> spielerAllDb) {
    setState(() {
      _spielerList = spielerAllDb;
    });
  }

}
