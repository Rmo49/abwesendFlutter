import 'package:abwesend/model/tableau.dart';
import 'package:flutter/material.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;

/// Einen Spieler ändern, löschen, Beziehung zu Tableau setzen
class SpielerAdmin extends StatefulWidget {
  @override
  _SpielerAdminState createState() => _SpielerAdminState();
}

class _SpielerAdminState extends State<SpielerAdmin> {
  // der gewählte Spieler
  Spieler _spieler;
  // Die angezeigte Liste der Tableau
  List<Tableau> _tableauList = List<Tableau>();
  // weil 2 zeilen, hier die berechnete Mitte
  int _tableauListMid;

  TextEditingController txtName = TextEditingController();
  TextEditingController txtVorname = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tableauListMid = 0;
    readData();
  }

  void readData() async {
    await readSpieler(global.spielerIdList);
    await readSpielerTableau();
    await readTableau();
    await setData();
    doSetState();
  }

  /// Den ersten Spieler von der DB lesen
  Future readSpieler(List<int> spielerIdList) async {
    if (spielerIdList.length > 0) {
      _spieler = await Spieler.readSpieler(spielerIdList.elementAt(0));
    } else {
      _spieler = null;
    }
  }

  Future readTableau() async {
    TableauList tableau = TableauList();
    await tableau.readAllTableau();
    _tableauList = tableau.allTableau;
  }

  /// Einlesen der Tableaux eines Spielers
  Future readSpielerTableau() async {
    await _spieler.readTableau();
  }

  Future setData() async {
    txtName.text = _spieler.name;
    txtVorname.text = _spieler.vorname;
    txtEmail.text = _spieler.email;
    txtId.text = _spieler.spielerId.toString();
    // Tableau setzen
    Iterator iter = _spieler.tableauList.iterator;
    while(iter.moveNext()) {
      for (int i = 0; i < _tableauList.length; i++) {
        if (_tableauList[i].id == iter.current) {
          _tableauList[i].isSelected = true;
          break;
        }
      }
    }
  }

  /// nachdem alles eingelesen wurde
  void doSetState() {
    if (_spieler != null) {
      // _initTxtController();
    }
    setState(() {
      double len = _tableauList.length/2;
      _tableauListMid = len.round();
    });
  }

  //----- bis hieher daten einlesen -------------------------

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Spieler ändern'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: [
              RaisedButton(
                child: const Text('Neue Spieler'),
                onPressed: () {
                  _spielerNeu();
                },
              ),
              RaisedButton(
                child: const Text('Daten speichern'),
                onPressed: () {
                  _speichern();
                },
              ),
              RaisedButton(
                child: const Text('Spieler löschen'),
                onPressed: () {
                  _speichern();
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  controller: txtName,
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(5.0)))),
                ),
              ),
              Flexible(
                flex: 1,
                child: TextField(
                  controller: txtVorname,
                  decoration: InputDecoration(
                      labelText: "Vorname",
                      hintText: "Name",
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(5.0)))),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(
                flex: 5,
                child: TextField(
                  controller: txtEmail,
                  decoration: InputDecoration(
                      labelText: "e-mail",
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(5.0)))),
                ),
              ),
              Flexible(
                flex: 1,
                child: TextField(
                  controller: txtId,
                  decoration: InputDecoration(
                      labelText: "spieler ID",
                      enabled: false,
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(5.0)))),
                ),
              ),
            ],
          ),
          Text('spielt in:'),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: ListView(
                    shrinkWrap: true,
                    children:
                      _getTableauList(context, 0, _tableauListMid)
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: ListView(
                    shrinkWrap: true,
                    children:
                    _getTableauList(context, _tableauListMid, _tableauList.length)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Die Liste der angezeigten Tableau
  List<Widget> _getTableauList(BuildContext context, int von, int bis) {
    List<Widget> tableauList = List<Widget>();
    if (von == null || bis == null) {
      return tableauList;
    }
    for (int index = von; index < bis; index++) {
      Container tableau = Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        color: _tableauList[index].isSelected ? Colors.orange[300] : Colors
            .white,
        // height: 30.0,
        child: ListTile(
          title: Text(
            '${_tableauList
                .elementAt(index)
                .bezeichnung}',
            style: TextStyle(fontSize: 18.0),
//          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2),
          ),
          dense: true,
          onTap: () {
            setState(() {
              _tableauList[index].isSelected = !_tableauList[index].isSelected;
            });
          },
        ),
      );
      tableauList.add(tableau);
    }
    return tableauList;
  }

  void _speichern() {
    _spieler.name = txtName.text;
    _spieler.vorname = txtVorname.text;
    _spieler.email = txtEmail.text;
    _spieler.saveSpieler();
    // Tableau-Liste neu setzen, falls geändert
    List<int> tabList = new List<int>();
    _tableauList.forEach((element) {
      if (element.isSelected) {
        tabList.add(element.id);
      }
    });
    _spieler.resetTableauList(tabList);
    _spieler.saveSpielerTableau();
  }

  void _spielerNeu() {}
}
