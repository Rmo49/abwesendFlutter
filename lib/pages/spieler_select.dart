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

  // die daten vom Aufrufer (Home, TableauSelect)
  Map _selection = {};
  int _tableauId = -1;
  List<SpielerShort> spielerAlle;
  List<SpielerShort> spielerShow = List<SpielerShort>();

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    readAllSpieler();
  }

  @override
  Widget build(BuildContext context) {
    _selection = ModalRoute.of(context).settings.arguments;
    _tableauId = _selection['tableauId'];

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spieler filtern"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text('Tableau: ' + _tableauId.toString()),
//            Text(_txtError),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Spieler filtern",
                    hintText: "Name eingeben",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: spielerShow == null ? 0 : spielerShow.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${spielerShow.elementAt(index).names}'),
                    onTap: () {
                      spielerSelektiert(context, index);
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

  /// Alle Spieler von der DB lesen, diese werden in json-format geliefert
  Future readAllSpieler() async {
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
        setState(() {});
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
          SpielerShort(map['id'], map['name'] + " " + map['vorname']);
      spielerList.add(spielerShort);
    });
    // Liste sortieren
    Comparator<SpielerShort> spielerComparator =
        (a, b) => a.names.compareTo(b.names);
    spielerList.sort(spielerComparator);
    // anzeigen, da build bereits ausgeführt
    setState(() {
      spielerAlle = spielerList;
      spielerShow.addAll(spielerAlle);
    });
  }

  /// Wenn ein Spieler selektiert wurde, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void spielerSelektiert(BuildContext context, int index) {
    print('spielerSelektiert: $index');
    print(spielerShow[index]);

    Navigator.pushNamed(context, '/spieler_show', arguments: {
      'spielerId': spielerShow[index].id,
    });
  }
}
