import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;

class SpielerSelect extends StatefulWidget {
  @override
  _SpielerSelectState createState() => _SpielerSelectState();
}

class _SpielerSelectState extends State<SpielerSelect> {
  TextEditingController editingController = TextEditingController();

  // Flip-Flop wenn alle selektiert
  bool _alleSelektiert = false;
  String selButtonText = 'alle';
  List<SpielerShort> spielerAlle;
  List<SpielerShort> spielerShow = List<SpielerShort>();

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    readAllSpielerShort();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spieler filtern"),
      ),
      body: Container(
        child: Column(children: <Widget>[
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200.0,
                height: 40.0,
                child: TextField(
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  controller: editingController,
                  decoration: InputDecoration(
                      labelText: "Name eingeben",
                      hintText: "Name",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: FlatButton(
                child: Text(
                  selButtonText,
//                  style: TextStyle(fontSize: 20.0),
                ),
                color: Colors.orange[200],
                onPressed: selectAll,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: FlatButton(
                child: Text('anzeigen'),
                color: Colors.orange[400],
                padding: EdgeInsets.all(4.0),
                onPressed: () { spielerAnzeigen(context); },
              ),
            ),
          ]),
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemCount: spielerShow == null ? 0 : spielerShow.length,
            itemBuilder: _getListItemTile,
          )),
        ]),
      ),
    );
  }

  Widget _getListItemTile(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      color: spielerShow[index].isSelected ? Colors.orange[300] : Colors.white,
      height: 40.0,
      child: ListTile(
        title: Text('${spielerShow.elementAt(index).names}'),
        onTap: () {
          setState(() {
            spielerShow[index].isSelected = !spielerShow[index].isSelected;
          });
        },
        onLongPress: () {
          spielerAnzeigen(context);
        },
      ),
    );
  }

  /// Wenn etwas im search-feld eingegeben wurde.
  void filterSearchResults(String query) {
    List<SpielerShort> tempList = List<SpielerShort>();
    if (query.isNotEmpty) {
      spielerAlle.forEach((item) {
        if (item.names.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      });
      setState(() {
        spielerShow.clear();
        spielerShow.addAll(tempList);
      });
      return;
    } else {
      setState(() {
        spielerShow.clear();
        spielerShow.addAll(spielerAlle);
      });
    }
  }

  // alle selektieren, wenn vorher bereits selektiert, dann unselect
  void selectAll() {
    if (spielerShow.length > 20) {
      // TODO popup anzeigen
      return;
    }
    if (_alleSelektiert) {
      spielerShow.forEach((element) {
        element.isSelected = false;
      });
      selButtonText = 'alle';
    } else {
      spielerShow.forEach((element) {
        element.isSelected = true;
      });
      selButtonText = 'keine';
    }
    _alleSelektiert = !_alleSelektiert;
    setState(() {});
  }

  /// Wenn mehrere Spieler selektiert wurden, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void spielerAnzeigen(BuildContext context) {
    global.spielerIdList.clear();
    spielerShow.forEach((element) {
      if (element.isSelected) {
        global.spielerIdList.add(int.parse(element.id));
      }
    });
    Navigator.pushNamed(context, '/abwesend_show', arguments: {
    });
  }

  /// Wenn ein Spieler selektiert wurde, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void spielerSelect(BuildContext context, int index) {
    Navigator.pushNamed(context, '/spieler_show', arguments: {
      'spielerId': spielerShow[index].id,
    });
  }

  //------------- DB access ------------------------
  /// Kruzform aller Spieler von der DB lesen, diese werden in json-format geliefert
  Future readAllSpielerShort() async {
    var url = '';
    if (global.tableauId < 0)
      url = "https://nomadus.ch/tca/db/readSpielerAll.php";
    else {
      url = "https://nomadus.ch/tca/db/readTableauSpieler.php";
    }
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbname,
        "tableauId": global.tableauId.toString(),
      });
      if (response.statusCode == 200) {
        if (response.body.length > 0) {
          List spielerFromDb = json.decode(response.body);
          setSpielerData(spielerFromDb);
        } else {
          setSpielerData(getSpielerMessage('keine Spieler gefunden'));
        }
      } else {
        setSpielerData(getSpielerMessage(response.body));
        setState(() {});
        return;
      }
    } catch (e) {
      // Könnte sein, dass response eine Error-Message enthält
//      LineSplitter ls = new LineSplitter();
//      List<String> lines = ls.convert(response.body);
      setSpielerData(getSpielerMessage(e));
      // anzeigen, da build bereits ausgeführt
      setState(() {});
      return;
    }
  }

  /// Wenn statt Spieler eine Message in der Liste angezeigt werden soll.
  List getSpielerMessage(String message) {
    List msgList = new List();
    msgList.add({'id': '-1', 'name': message, 'vorname': '!'});
    return msgList;
  }

  /// Die Listen mi den entsprechenden Spielern füllen
  void setSpielerData(List spielerFromDb) {
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
    // anzeigen, da build bereits ausgeführt, aber nur wenn neu

    setState(() {
      spielerAlle = spielerList;
      spielerShow.addAll(spielerAlle);
    });
  }
}
