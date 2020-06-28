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

  // Steuerung des Anzeige-Buttons
  bool _isButtonAnzeigeEnabled;

  List<SpielerShort> spielerAlle;
  List<SpielerShort> spielerShow = List<SpielerShort>();

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    readAllSpielerShort();
    _isButtonAnzeigeEnabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spieler filtern"),
      ),
      body: Container(
        child: Column(children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 150.0,
                  height: 50.0,
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
              ButtonBar(
                children: [
                  FlatButton(
                    child: Text(
                      'alle',
//                  style: TextStyle(fontSize: 20.0),
                    ),
                    color: Colors.orange[400],
                    onPressed: selectAll,
                  ),
                  FlatButton(
                    child: Text(
                      'keine',
//                  style: TextStyle(fontSize: 20.0),
                    ),
                    color: Colors.orange[400],
                    onPressed: unselectAll,
                  ),
                  _buttonAnzeige(),
//                FlatButton(
//                  child: Text('anzeigen'),
//                  color: Colors.orange[400],
//                  onPressed: () {
//                    spielerAnzeigen(context);
//                  },
//                ),
                ],
              ),
            ]),
          ),
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemCount: spielerShow == null ? 0 : spielerShow.length,
            itemBuilder: _getListOfSpieler,
          )),
        ]),
      ),
    );
  }

  /// wenn etwas selektiert, sollte aktiviert werden
  Widget _buttonAnzeige() {
    return new FlatButton(
      child: Text('anzeigen'),
      color: _isButtonAnzeigeEnabled ? Colors.orange[400] : Colors.orange[200],
      padding: EdgeInsets.all(4.0),
      onPressed: _anzeigePress,
    );
  }

  /// Wenn der Button anzeige gedrückt ist
  void _anzeigePress() {
    if (_isButtonAnzeigeEnabled) {
      spielerAnzeigen(context);
    } else {
      return null;
    }
    return null;
  }

  /// überprüfen, ob ein Spieler selektiert wurde
  void _checkSelected() {
    _isButtonAnzeigeEnabled = false;
    for (int i = 0; i < spielerAlle.length; i++) {
      if (spielerAlle.elementAt(i).isSelected) {
        _isButtonAnzeigeEnabled = true;
        break;
      }
    }
  }

  /// Die Liste der angezeigten Spieler
  Widget _getListOfSpieler(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      color: spielerShow[index].isSelected ? Colors.orange[300] : Colors.white,
      height: 40.0,
      child: ListTile(
        title: Text(
          '${spielerShow.elementAt(index).names}',
          style: TextStyle(fontSize: 18.0),
//          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2),
        ),
        dense: true,
        onTap: () {
          setState(() {
            spielerShow[index].isSelected = !spielerShow[index].isSelected;
            _checkSelected();
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
        _checkSelected();
      });
      return;
    } else {
      setState(() {
        spielerShow.clear();
        spielerShow.addAll(spielerAlle);
        _checkSelected();
      });
    }
  }

  // alle Spieler selektieren,
  void selectAll() {
    if (spielerShow.length > 20) {
      // TODO popup anzeigen
      return;
    }
    spielerShow.forEach((element) {
      element.isSelected = true;
    });
    setState(() {
      _checkSelected();
    });
  }

  /// keine selektieren
  void unselectAll() {
    spielerShow.forEach((element) {
      element.isSelected = false;
    });
    setState(() {
      _checkSelected();
    });
  }

  /// Wenn mehrere Spieler selektiert wurden, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void spielerAnzeigen(BuildContext context) {
    global.spielerIdList.clear();
    spielerAlle.forEach((element) {
      if (element.isSelected) {
        global.spielerIdList.add(int.parse(element.id));
      }
    });
    Navigator.pushNamed(context, '/abwesend_show', arguments: {});
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
