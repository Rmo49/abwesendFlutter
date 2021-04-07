import 'package:flutter/material.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/pages/abwesend_base.dart';

/// Die Abwesenheiten ändern
class AbwesendEdit extends StatefulWidget {
  @override
  _AbwesendEditState createState() => _AbwesendEditState();
}

class _AbwesendEditState extends State<AbwesendEdit> {
  Spieler? _spieler;
  List<String>? _abwesendList;
  int _anzCol = global.arrayLen;
  late List<TextEditingController> _txtList;
  TextEditingController txtWochenwert = TextEditingController();
  TextEditingController txtMeldung = TextEditingController();

  @override
  void initState() {
    super.initState();
    readSpieler(global.spielerIdList);
  }

  /// Den ersten Spieler von der DB lesen
  Future readSpieler(List<int> spielerIdList) async {
    List<Spieler?> spielerList = [];
    if (spielerIdList.length > 0) {
      Spieler? spieler = await Spieler.readSpieler(spielerIdList.elementAt(0));
      spielerList.add(spieler);
    } else {
      spielerList.clear();
    }
    doSetState(spielerList);
  }

  /// nachedem alles eingelesen wurde
  void doSetState(List<Spieler?> spielerList) {
    _spieler = spielerList.first;
    if (_spieler != null) {
      _abwesendList = _spieler!.abwesend!.split(';');
      _initTxtController();
    }
    setState(() {
      // _spieler;
    });
  }

  /// alle TextController initialisieren mit den init-Wert
  void _initTxtController() {
    _txtList = [];
    for (int i = 0; i < global.arrayLen; i++) {
      _txtList.add(new TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_spieler == null) {
      return new Scaffold(appBar: AppBar(title: Text('Lade Daten')));
    }

    return new Scaffold(
        appBar: AppBar(
          title: Text('Abwesenheiten eintragen'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              iconSize: 30.0,
              tooltip: 'Speichern',
              onPressed: () {
                _speichern();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Text(_spieler!.vorname! + ' ' + _spieler!.name!,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  defaultColumnWidth: FixedColumnWidth(40.0),
                  children: [
                    //Datum Zeile
                    TableRow(
                      children: AbwesendBase.getCellsDatum(
                          global.startDatum, _anzCol),
                    ),
                    TableRow(
                      children: AbwesendBase.getCellsAbwesend(
                          _abwesendList, 0, _anzCol),
                    ),
                    TableRow(
                      children: AbwesendBase.getCellsGrafik(
                          _spieler, _abwesendList, 0, _anzCol),
                    ),
                    TableRow(
                      children: _getTxtField(0, _anzCol, context),
                    )
                  ]),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: txtWochenwert,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Wochenwert",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    child: const Text('Wert in alle Wochentage eintragen'),
                    onPressed: () {
                      _setWochenwert();
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: 3,
                  controller: txtMeldung,
                  readOnly: true,
                ),
              ),
            ),
          ],
        ));
  }

  /// Die Eingabefelder für jeden Tag
  List<TableCell> _getTxtField(int von, int bis, BuildContext context) {
    List<TableCell> rowList = [];
    for (int i = von; i < bis; i++) {
      rowList.add(
        TableCell(
            child: TextField(
          controller: _txtList[i],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onEditingComplete: () => FocusScope.of(context).nextFocus(),
        )),
      );
      _txtList[i].text = _abwesendList![i];
    }
    return rowList;
  }

  /// Wochenwert eintragen
  void _setWochenwert() {
    for (int i = 0; i < _anzCol; i++) {
      if (!AbwesendBase.isWeekend(i)) {
        _txtList[i].text = txtWochenwert.text;
      }
    }
  }

  /// Speichern des geänderten Spieler in DB
  void _speichern() async {
    for (int i = 0; i < _anzCol; i++) {
      _abwesendList![i] = _txtList[i].text;
    }
    _spieler!.abwesend = _abwesendList!.join(';');
    String result = await _spieler!.saveSpieler();
    setState(() {
      txtMeldung.text = result;
    });
  }
}
