import 'dart:convert';
import 'package:abwesend/model/spieler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpielerSelect extends StatefulWidget {
  @override
  _SpielerSelectState createState() => _SpielerSelectState();
}

class _SpielerSelectState extends State<SpielerSelect> {
  TextEditingController editingController = TextEditingController();

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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spieler suchen"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
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
    List<SpielerShort> spielerList = new List<SpielerShort>();
    var url = "https://nomadus.ch/tca/db/readSpielerAll.php";
    final String res = await http.read(url);
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(res);
    // die erste Zeile enthält keine Daten
    List spielerFromDb = json.decode(lines.elementAt(1));
    spielerFromDb.forEach((element) {
      Map<String, dynamic> map = element;
      SpielerShort spielerShort = SpielerShort(map['id'], map['name'] + " " + map['vorname']);
      spielerList.add(spielerShort);
    });
    // Liste sortieren
    Comparator<SpielerShort> spielerComparator = (a, b) => a.names.compareTo(b.names);
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
      'spielerId' : spielerShow[index].id,
    });
  }
}
