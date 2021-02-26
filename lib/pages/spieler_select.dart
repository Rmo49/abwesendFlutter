import 'package:flutter/material.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/tableau.dart';

class SpielerSelect extends StatefulWidget {
  @override
  _SpielerSelectState createState() => _SpielerSelectState();
}

class _SpielerSelectState extends State<SpielerSelect> {
  TextEditingController editingController = TextEditingController();

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

  // Steuerung des Anzeige-Buttons
  bool _isButtonAnzeigeEnabled;

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    _initData();
    _isButtonAnzeigeEnabled = false;
  }

  /// Die Daten lesen von der DB
  void _initData () async {
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
        title: new Text("Spieler filtern"),
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
                ],
              ),
            ]),
          ),

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

  /// wenn etwas selektiert, sollte aktiviert werden
  Widget _buttonAnzeige() {
    return new FlatButton(
      child: Text('anzeigen'),
      color: _isButtonAnzeigeEnabled ? Colors.orange[400] : Colors.orange[200],
      padding: EdgeInsets.all(4.0),
      onPressed: _anzeigePress,
    );
  }

  // Wenn ein Tableau selektiert wurde
  void _readSpielerTableau(int tableauId) async {
    if (tableauId < 0) {
      setState(() {
        _spielerShow = _spielerAlle;
      });
    }
    else {
      _spielerTableau = await spielerList.readTableauSpielerShort(tableauId);
      setState(() {
        _spielerShow = _spielerTableau;
      });
    }

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
    for (int i = 0; i < _spielerShow.length; i++) {
      if (_spielerShow.elementAt(i).isSelected) {
        _isButtonAnzeigeEnabled = true;
        break;
      }
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
      height: 40.0,
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
      _spielerAlle.forEach((item) {
        if (item.names.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(item);
        }
      });
      setState(() {
        _spielerShow.clear();
        _spielerShow.addAll(tempList);
        _checkSelected();
      });
      return;
    } else {
      setState(() {
        // zurücksetzen auf Ausgang: alle oder Tableau
        _spielerShow.clear();
        _spielerShow.addAll(_spielerAlle);
        _checkSelected();
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
    setState(() {
      _checkSelected();
    });
  }

  /// keine selektieren
  void unselectAll() {
    _spielerShow.forEach((element) {
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
    _spielerShow.forEach((element) {
      if (element.isSelected) {
        global.spielerIdList.add(int.parse(element.id));
      }
    });
    Navigator.pushNamed(context, '/abwesend_show', arguments: {});
  }

  /// Wenn ein Spieler selektiert wurde, wird diese Funkion aufgerufen.
  /// index ist die position in der Liste
  // void spielerSelect(BuildContext context, int index) {
  //   Navigator.pushNamed(context, '/spieler_show', arguments: {
  //     'spielerId': _spielerShow[index].id,
  //   });
  // }
}
