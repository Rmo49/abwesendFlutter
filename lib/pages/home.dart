import 'package:abwesend/model/config.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/tableau.dart';
import 'package:abwesend/pages/alert_popup.dart';
import 'package:abwesend/pages/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:abwesend/model/globals.dart' as global;

class Home extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

/// Der Hauptscreen
class _HomeState extends State<Home> {
  final DateFormat _dateForm = new DateFormat('d.M.yyyy');
  TextEditingController _txtDatumStart = TextEditingController();

  TextEditingController _txtNameSuchen = TextEditingController();

  HomeDrawer _homeDrawer = new HomeDrawer();

  // Zugriff auf die Tableau-Date
  late TableauList _tableauList;
  // Tableau in der selektionsliste
  List<Tableau> _allTableau = [];
  List<DropdownMenuItem<Tableau>> _dropdownTableauItems = [];
  Tableau tableauAlle = new Tableau(-1, ' ', 'Alle Spieler', '0');
  Tableau? _selectedTableau;

  // Spieler Listen, Zugriff auf Date
  SpielerList _spielerList = SpielerList();
  // alle Spieler, wird einmal eingelesen, für reset, wenn alle anzeigen
  List<SpielerShort> _spielerAlle = [];
  // Spieler eines Tableau
  List<SpielerShort> _spielerTableau = [];
  // Die angezeigte Liste der Spieler
  List<SpielerShort> _spielerShow = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// Die Daten lesen von der DB
  void _initData() async {
    await _initConfig();
    await _initSpieler();
    await _initTableau();
    _txtDatumStart.text = _dateForm.format(global.startDatum);
  }

  Future _initConfig() async {
    String message = await Config.readConfig();
    if (message.length > 0) {
      AlertPopup alert = AlertPopup('Config', message, context);
      await alert.showMyDialog();
      return;
    }
    // wenn abDatumAnzeigen noch nicht gesetzt, dann wurde locals nicht
    // richtig eingelesen
    if ((global.abDatumAnzeigen.compareTo(global.startDatum) < 0) ||
        (global.abDatumAnzeigen.compareTo(global.endDatum) > 0)) {
      global.abDatumAnzeigen = global.startDatum;
    }
  }

  Future _initSpieler() async {
    // Spieler Date
    _spielerAlle = await _spielerList.readAllSpielerShort();
    setState(() {
      _spielerShow.addAll(_spielerAlle);
    });
  }

  Future _initTableau() async {
    // Tableau Daten lesen
    _tableauList = new TableauList();
    _allTableau = await _tableauList.readAllTableau();
    setState(() {
      _buildDropDownMenuItems(_allTableau);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called

    return new Scaffold(
      appBar: AppBar(
        title: Text(global.titel),
        // das Menu links
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // ruft scheinbar drawer: Drawer (weiter unten) auf.
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.article_outlined),
            iconSize: 30.0,
            tooltip: 'Abwesenheiten anzeigen',
            onPressed: () {
              _abwesendAnzeigen(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_chart),
            iconSize: 30.0,
            tooltip: 'Abwesenheiten eintragen',
            onPressed: () {
              _abwesendAendern(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            iconSize: 30.0,
            tooltip: 'Spieler verwalten',
            onPressed: () {
              _spielerAdmin(context);
            },
          ),
        ],
      ),

      body: Container(
        child: Column(children: <Widget>[
          // _tableauDropDown();
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 10, top: 10),
                child: Text(
                  "Tableau:",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: DropdownButton<Tableau>(
                    items: _dropdownTableauItems,
                    isDense: true,
                    value: _selectedTableau,
                    onChanged: (Tableau? newValue) {
                      _selectedTableau = newValue!;
                      _readSpielerTableau(newValue.tableauID);
                    }),
              ),
            ],
          ),

          Row(children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    _filterSearchResults(value);
                  },
                  controller: _txtNameSuchen,
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
                child: TextButton(
                  child: Text(
                    'alle',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: _selectAll,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  child: Text(
                    'keine',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: _unselectAll,
                ),
              ),
            ),
          ]),

          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemCount: _spielerShow.length,
            itemBuilder: _getListOfSpieler,
          )),
        ]),
      ),

      // das Menü auf der linken Seite
      drawer: _homeDrawer.getDrawer(context),
      // Disable opening the drawer with a swipe gesture.
      drawerEnableOpenDragGesture: false,
    );
  }

  // Wenn ein Tableau selektiert wurde
  void _readSpielerTableau(int tableauID) async {
    if (tableauID < 0) {
      _spielerShow.clear();
      _spielerShow.addAll(_spielerAlle);
    } else {
      _spielerTableau = await _spielerList.readTableauSpielerShort(tableauID);
      _spielerShow.clear();
      _spielerShow.addAll(_spielerTableau);
    }
    setState(() {
      _txtNameSuchen.text = "";
    });
  }

  // Den Dropdown für Tableau erstellen
  void _buildDropDownMenuItems(List<Tableau> listItems) {
    List<DropdownMenuItem<Tableau>> items = [];
    // erster Eintrag leer
    items.add(DropdownMenuItem(
      child: Text(tableauAlle.bezeichnung!),
      value: tableauAlle,
    ));
    for (Tableau tableau in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(tableau.bezeichnung!),
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
          _abwesendAnzeigen(context);
        },
      ),
    );
  }

  /// Wenn etwas im search-feld eingegeben wurde.
  void _filterSearchResults(String query) {
    List<SpielerShort> tempList = [];
    if (query.isNotEmpty) {
      _spielerShow.forEach((item) {
        if (item.names!.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      });
      setState(() {
        _spielerShow.clear();
        _spielerShow.addAll(tempList);
      });
      return;
    } else {
      _spielerShow.clear();
      if (_selectedTableau == null || _selectedTableau!.tableauID < 0) {
        _spielerShow.addAll(_spielerAlle);
      } else {
        _spielerShow.addAll(_spielerTableau);
      }
      setState(() {
        // zurücksetzen auf Ausgang: alle oder Tableau
        _txtNameSuchen.text = "";
      });
    }
  }

  // alle Spieler selektieren,
  void _selectAll() {
    if (_spielerShow.length > 20) {
      AlertPopup popup =
          AlertPopup("Spieler anzeigen", "das wären zuviele Spieler\n" +
              "zuerst ein Tableau wählen", context);
      popup.showMyDialog();
      return;
    }
    _spielerShow.forEach((element) {
      element.isSelected = true;
    });
    setState(() {});
  }

  /// keine selektieren
  void _unselectAll() {
    _spielerShow.forEach((element) {
      element.isSelected = false;
    });
    setState(() {});
  }

  /// Die globale Liste mit den ID's füllen
  void _fillSpielerList() {
    if (global.spielerIdList.length > 0) {
      global.spielerIdList.clear();
    } else {
      global.spielerIdList = [];
    }
    _spielerShow.forEach((element) {
      if (element.isSelected) {
        global.spielerIdList.add(int.parse(element.spielerID!));
      }
    });
  }

  /// Wenn Icon gedrückt, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void _abwesendAnzeigen(BuildContext context) {
    _fillSpielerList();
    if (global.spielerIdList.length > 0) {
      Navigator.pushNamed(context, '/abwesend_show', arguments: {});
    }
  }

  /// Wenn Icon gedrückt, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void _abwesendAendern(BuildContext context) {
    _fillSpielerList();
    if (global.spielerIdList.length > 0) {
      Navigator.pushNamed(context, '/abwesend_edit', arguments: {});
    }
  }

  /// Wenn Icon gedrückt, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  void _spielerAdmin(BuildContext context) {
    _fillSpielerList();
//    if (global.spielerIdList.length > 0) {
      Navigator.pushNamed(context, '/spieler_admin', arguments: {});
 //   }
  }
}
