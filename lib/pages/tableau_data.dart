import 'package:abwesend/model/tableau.dart';
import 'package:abwesend/pages/alert_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TableauData extends StatefulWidget {
  @override
  _TableauDataState createState() => _TableauDataState();
}

class _TableauDataState extends State<TableauData> {
  final _formKey = GlobalKey<FormState>();
  // Die angezeigte Liste der Tableau
  List<Tableau>? _tableauList = [];
  int _selectedID = -1;
  TextEditingController _txtPos = TextEditingController();
  TextEditingController _txtBezeichnung = TextEditingController();
  TextEditingController _txtKonkurren = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readData();
  }

  void _readData() async {
    TableauList tList = TableauList();
    await tList.readAllTableau();
    setState(() {
      _tableauList = tList.allTableau;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Tableau verwalten'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 30.0,
            tooltip: 'Neues Tableau eingeben',
            onPressed: () {
              _neuesTableau();
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
            icon: const Icon(Icons.delete_forever),
            iconSize: 30.0,
            tooltip: 'löschen',
            onPressed: () {
              _delete();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: _txtPos,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Wert eingeben';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        labelText: "Pos",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    controller: _txtBezeichnung,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Wert eingeben';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: "Bezeichnung",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: TextFormField(
                    controller: _txtKonkurren,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Wert eingeben';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: "Konkurrenz",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                    columns: [
                      DataColumn(label: Text('pos'), numeric: true),
                      DataColumn(label: Text('bezeichnung')),
                      DataColumn(label: Text('konkurrenz')),
                      DataColumn(label: Text('id'), numeric: true)
                    ],
                    rows: _getTableauRows(),
                    columnSpacing: 8,
                    dataRowHeight: 30,
                           ),
            ),
          ),
        ],
      ),
    );
  }

  /// Die Liste alle Tableau
  List<DataRow> _getTableauRows() {
    List<DataRow> rowList = [];
    _tableauList!.forEach((element) {
      DataRow row = DataRow(
          cells: [
            DataCell(Text(element.position.toString())),
            DataCell(Text(element.bezeichnung.toString())),
            DataCell(Text(element.konkurrenz.toString())),
            DataCell(Text(element.tableauID.toString())),
          ],
          selected: element.tableauID == _selectedID,
          onSelectChanged: (val) {
            _fillEditTxt(element.tableauID);
          });
      rowList.add(row);
    });
    return rowList;
  }

  /// Die Anzeige mit selektierte füllen
  void _fillEditTxt(int selectedID) {
    _tableauList!.forEach((element) {
      if (element.tableauID == selectedID) {
        _txtPos.text = element.position.toString();
        _txtBezeichnung.text = element.bezeichnung!;
        _txtKonkurren.text = element.konkurrenz!;
      }
    });
    setState(() {
      _selectedID = selectedID;
    });
  }

  /// Ein neues Tableau eingeben
  void _neuesTableau() {
    // TODO: zuerst verifizieren, ob etwas gespeichert werden muss
    _txtPos.clear();
    _txtBezeichnung.clear();
    _txtKonkurren.clear();
    setState(() {
      _selectedID = -1;
    });
  }

  /// Speichern der bestehenden Eingabe
  void _speichern() async {
    if (_selectedID >= 0) {
      // TODO: zuerst vergleichen mit dem bestehenden Eintrag
    }
    if (_formKey.currentState!.validate()) {
      Tableau tableau = new Tableau(
          _selectedID, _txtPos.text, _txtBezeichnung.text, _txtKonkurren.text);
      await tableau.save();
      // Anzeige leeren
      _neuesTableau();
      // damit neue Liste angezeigt wird
      _tableauList!.clear();
      _readData();
    }
  }

  void _delete() async {
    Tableau tableau = new Tableau(_selectedID, _txtPos.text, _txtBezeichnung.text, _txtKonkurren.text);
    String message = await tableau.delete();
    if (message.length > 10) {
      AlertPopup popup = AlertPopup("Tableau löschen", message, context);
      popup.showMyDialog();
    }
    _neuesTableau();
    // damit neue Liste angezeigt wird
    _tableauList!.clear();
    _readData();
  }
}
