import 'package:abwesend/model/tableau.dart';
import 'package:abwesend/pages/alert_popup.dart';
import 'package:flutter/material.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;

/// Einen Spieler ändern, löschen, Beziehung zu Tableau setzen
/// Der Spieler ist der erste selektierte in der Liste von home.
class SpielerAdmin extends StatefulWidget {
  @override
  _SpielerAdminState createState() => _SpielerAdminState();
}

class _SpielerAdminState extends State<SpielerAdmin> {
  // Prüfung der Eingaben
  final _formKey = GlobalKey<FormState>();
  // der gewählte Spieler
  Spieler? _spieler;
  // Die angezeigte Liste der Tableau
  List<Tableau>? _tableauList = [];
  // weil 2 zeilen, hier die berechnete Mitte
  int? _tableauListMid;

  TextEditingController _txtName = TextEditingController();
  TextEditingController _txtVorname = TextEditingController();
  TextEditingController _txtEmail = TextEditingController();
  TextEditingController _txtId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tableauListMid = 0;
    _readData();
  }

  void _readData() async {
    if (global.spielerIdList.length > 0) {
      await _readSpieler(global.spielerIdList);
      await _readSpielerTableau();
    }
    await _readTableau();
    await _setData(global.spielerIdList);
    _doSetState();
  }

  /// Den ersten Spieler von der DB lesen
  Future _readSpieler(List<int> spielerIdList) async {
    if (spielerIdList.length > 0) {
      _spieler = await Spieler.readSpieler(spielerIdList.elementAt(0));
    } else {
      _spieler = null;
    }
  }

  Future _readTableau() async {
    TableauList tableau = TableauList();
    await tableau.readAllTableau();
    _tableauList = tableau.allTableau;
  }

  /// Einlesen der Tableaux eines Spielers
  Future _readSpielerTableau() async {
    await _spieler!.readTableau();
  }

  /// Daten der Anzeige-Felder setzen
  Future _setData(List<int> spielerIdList) async {
    if (spielerIdList.length > 0) {
      _txtName.text = _spieler!.name!;
      _txtVorname.text = _spieler!.vorname!;
      _txtEmail.text = _spieler!.email!;
      _txtId.text = _spieler!.spielerID.toString();
      // Tableau setzen
      Iterator iter = _spieler!.tableauList!.iterator;
      while (iter.moveNext()) {
        for (int i = 0; i < _tableauList!.length; i++) {
          if (_tableauList![i].tableauID == iter.current) {
            _tableauList![i].isSelected = true;
            break;
          }
        }
      }
    }
    else {
      _spielerNeu();
    }
  }

  /// nachdem alles eingelesen wurde
  void _doSetState() {
    if (_spieler != null) {
      // _initTxtController();
    }
    setState(() {
      double len = _tableauList!.length / 2;
      _tableauListMid = len.round();
    });
  }

  //----- bis hieher daten einlesen -------------------------

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Spieler ändern'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person_add),
            iconSize: 30.0,
            tooltip: 'Neuen Spieler eingeben',
            onPressed: () {
              _spielerNeu();
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            iconSize: 30.0,
            tooltip: 'Speichern',
            onPressed: () {
              _speichern();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_remove),
            iconSize: 30.0,
            tooltip: 'Spieler löschen',
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: _txtName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Wert eingeben';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: _txtVorname,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Wert eingeben';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: "Vorname",
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
                  child: TextFormField(
                    controller: _txtEmail,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Wert eingeben';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
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
                    controller: _txtId,
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
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'spielt in:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: ListView(
                        shrinkWrap: true,
                        children: _getTableauList(context, 0, _tableauListMid)),
                  ),
                  Flexible(
                    flex: 1,
                    child: ListView(
                        shrinkWrap: true,
                        children: _getTableauList(
                            context, _tableauListMid, _tableauList!.length)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Die Liste der angezeigten Tableau
  List<Widget> _getTableauList(BuildContext context, int? von, int? bis) {
    List<Widget> tableauList = [];
    if (von == null || bis == null) {
      return tableauList;
    }
    for (int index = von; index < bis; index++) {
      Container tableau = Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        color:
            _tableauList![index].isSelected ? Colors.orange[300] : Colors.white,
        // height: 30.0,
        child: ListTile(
          title: Text(
            '${_tableauList!.elementAt(index).bezeichnung}',
            style: TextStyle(fontSize: 18.0),
//          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2),
          ),
          dense: true,
          onTap: () {
            setState(() {
              _tableauList![index].isSelected =
                  !_tableauList![index].isSelected;
            });
          },
        ),
      );
      tableauList.add(tableau);
    }
    return tableauList;
  }

  void _speichern() async {
    if (_formKey.currentState!.validate()) {
      // _formKey2.currentState!.validate()) {
      _spieler!.name = _txtName.text;
      _spieler!.vorname = _txtVorname.text;
      _spieler!.email = _txtEmail.text;
      var _spielerId = await _spieler!.saveSpieler();

      // wenn neu, dann SpielerId setzen
      if (_spieler!.spielerID < 0) {
        _spieler!.spielerID = int.parse(_spielerId);
      }
      // Tableau-Liste neu setzen, falls geändert
      List<int> tabList = [];
      _tableauList!.forEach((element) {
        if (element.isSelected) {
          tabList.add(element.tableauID);
        }
      });
      _spieler!.resetTableauList(tabList);
      await _spieler!.saveSpielerTableau();

      AlertPopup alert = AlertPopup(
          'Spieler speichern', _spieler!.name! + ' gespeichert', context);
      await alert.showMyDialog();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _spielerNeu() async {
    _spieler = new Spieler("", "", "");
    _spieler!.spielerID = -1;
    _spieler!.abwesendStrLeeren();
    _tableauList!.forEach((element) {
      element.isSelected = false;
    });
    setState(() {
      _txtName.text = '';
      _txtVorname.text = '';
      _txtEmail.text = '';
      _txtId.text = "-1";
    });
  }

  void _showDeleteDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
        child: Text("Abbrechen"),
      onPressed: () => Navigator.pop(context)
    );
    Widget deleteButton = ElevatedButton(
      child: Text("Löschen"),
      onPressed: () => _spielerLoeschen(),

    );
        // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Spieler löschen"),
      content: Text("Soll Spieler gelöscht werden?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _spielerLoeschen() async {
    String result = await _spieler!.deleteSpieler();
    if (result.startsWith('SQL')) {
      AlertPopup alert = AlertPopup('Spieler löschen', result, context);
      await alert.showMyDialog();
    }
    else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
