import 'package:flutter/material.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/tableau.dart';

class SpielerSelect extends StatefulWidget {
  @override
  _SpielerSelectState createState() => _SpielerSelectState();
}

class _SpielerSelectState extends State<SpielerSelect> {
  TextEditingController txtNameSuchen = TextEditingController();

  // Tableau in der selektionsliste
  TableauList tableauList;
  List<Tableau> _allTableau;
  List<DropdownMenuItem<Tableau>> _dropdownTableauItems;
  Tableau _selectedTableau;

  // Spieler Listen
  SpielerList spielerList = SpielerList();
  // alle Spieler, wird einmal eingelesen, für reset, wenn alle anzeigen
  List<SpielerShort> _spielerAlle;
  // Spieler eines Tableau
  List<SpielerShort> _spielerTableau;
  // Die angezeigte Liste der Spieler
  List<SpielerShort> _spielerShow = List<SpielerShort>();

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    _initData();
  }

  /// Die Spieler- und Tableau-Daten lesen von der DB
  void _initData() async {
    // Spieler Date
    _spielerAlle = await spielerList.readAllSpielerShort();
    setState(() {
      _spielerShow = _spielerAlle;
    });
    // Tableau Daten lesen
    tableauList = new TableauList();
    _allTableau = await tableauList.readAllTableau();
    setState(() {
      _buildDropDownMenuItems(_allTableau);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spieler wählen"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.article_outlined),
            iconSize: 30.0,
            tooltip: 'Abwesenheiten anzeigen',
            onPressed: () {
              abwesendAnzeigen(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_chart),
            iconSize: 30.0,
            tooltip: 'Abwesenheiten eintragen',
            onPressed: () {
              abwesendAendern(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            iconSize: 30.0,
            tooltip: 'Spieler verwalten',
            onPressed: () {
              spielerAdmin(context);
            },
          ),
        ],
      ),
      body: Container(
        child: Column(children: <Widget>[
          // _tableauDropDown();
          Row(
            children: [
              Text("Tableau: "),
              DropdownButton<Tableau>(
                  value: _selectedTableau,
                  items: _dropdownTableauItems,
                  onChanged: (value) {
                    _selectedTableau = value;
                    _readSpielerTableau(value.id);
                  }),
            ],
          ),

          Row(children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  controller: txtNameSuchen,
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
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  child: Text(
                    'alle',
//                  style: TextStyle(fontSize: 20.0),
                  ),
                  color: Colors.orange[400],
                  onPressed: selectAll,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  child: Text(
                    'keine',
//                  style: TextStyle(fontSize: 20.0),
                  ),
                  color: Colors.orange[400],
                  onPressed: unselectAll,
                ),
              ),
            ),
          ]),

          Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _spielerShow == null ? 0 : _spielerShow.length,
                itemBuilder: _getListOfSpieler,
              )),
        ]),
      ),
    );
  }

  // Wenn ein Tableau selektiert wurde
  void _readSpielerTableau(int tableauId) async {
    if (tableauId < 0) {
      setState(() {
        _spielerShow = _spielerAlle;
      });
    } else {
      _spielerTableau = await spielerList.readTableauSpielerShort(tableauId);
      setState(() {
        _spielerShow = _spielerTableau;
      });
    }
  }

  // Den Dropdown für Tableau erstellen
  void _buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Tableau>> items = List();
    // erster Eintrag leer
    Tableau tabLeer = new Tableau(-1, ' ', '0');
    items.add(DropdownMenuItem(
      child: Text(tabLeer.bezeichnung),
      value: tabLeer,
    ));
    for (Tableau tableau in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(tableau.bezeichnung),
          value: tableau,
        ),
      );
    }
    _dropdownTableauItems = items;
  }

  /// Die Liste der angezeigten Spieler
  Widget _getListOfSpieler(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      color: _spielerShow[index].isSelected ? Colors.orange[300] : Colors.white,
      // height: 30.0,
      child: ListTile(
        title: Text(
          '${_spielerShow.elementAt(index).names}',
          style: TextStyle(fontSize: 18.0),
//          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2),
        ),
        dense: true,
        onTap: () {
          setState(() {
            _spielerShow[index].isSelected = !_spielerShow[index].isSelected;
          });
        },
        onLongPress: () {
          abwesendAnzeigen(context);
        },
      ),
    );
  }

  /// Wenn etwas im search-feld eingegeben wurde.
  void filterSearchResults(String query) {
    List<SpielerShort> tempList = List<SpielerShort>();
    if (query.isNotEmpty) {
      _spielerAlle.forEach((item) {
        if (item.names.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      });
      setState(() {
        _spielerShow.clear();
        _spielerShow.addAll(tempList);
      });
      return;
    } else {
      setState(() {
        // zurücksetzen auf Ausgang: alle oder Tableau
        _spielerShow.clear();
        _spielerShow.addAll(_spielerAlle);
      });
    }
  }

  // alle Spieler selektieren,
  void selectAll() {
    if (_spielerShow.length > 20) {
      // TODO popup anzeigen
      return;
    }
    _spielerShow.forEach((element) {
      element.isSelected = true;
    });
    setState(() {});
  }

  /// keine selektieren
  void unselectAll() {
    _spielerShow.forEach((element) {
      element.isSelected = false;
    });
    setState(() {});
  }

  /// Die globale Liste mit den ID's füllen
  void fillSpielerList() {
    global.spielerIdList.clear();
    _spielerShow.forEach((element) {
      if (element.isSelected) {
        global.spielerIdList.add(int.parse(element.id));
      }
    });
  }

  /// Wenn Icon gedrückt, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void abwesendAnzeigen(BuildContext context) {
    fillSpielerList();
    if (global.spielerIdList.length > 0) {
      Navigator.pushNamed(context, '/abwesend_show', arguments: {});
    }
  }

  /// Wenn Icon gedrückt, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void abwesendAendern(BuildContext context) {
    fillSpielerList();
    if (global.spielerIdList.length > 0) {
      Navigator.pushNamed(context, '/abwesend_edit', arguments: {});
    }
  }

  /// Wenn Icon gedrückt, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void spielerAdmin(BuildContext context) {
    fillSpielerList();
    if (global.spielerIdList.length > 0) {
      Navigator.pushNamed(context, '/spieler_admin', arguments: {});
    }
  }
}
