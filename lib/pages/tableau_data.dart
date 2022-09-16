import 'package:abwesend/model/tableau.dart';
import 'package:abwesend/pages/alert_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TableauData extends StatefulWidget {
  const TableauData({Key? key}) : super(key: key);

  @override
  TableauDataState createState() => TableauDataState();
}

class TableauDataState extends State<TableauData> {
  final _formKey = GlobalKey<FormState>();
  // Die angezeigte Liste der Tableau
  List<Tableau>? _tableauList = [];
  int _selectedID = -1;
  final TextEditingController _txtPos = TextEditingController();
  final TextEditingController _txtBezeichnung = TextEditingController();
  final TextEditingController _txtKonkurren = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau verwalten'),
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
                    decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
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
                    columns: const [
                      DataColumn(label: Text('pos'), numeric: true),
                      DataColumn(label: Text('bezeichnung')),
                      DataColumn(label: Text('konkurrenz')),
                      DataColumn(label: Text('id'), numeric: true)
                    ],
                    rows: _getTableauRows(context),
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
  List<DataRow> _getTableauRows(BuildContext context) {
    List<DataRow> rowList = [];
    for (var element in _tableauList!) {
      DataRow row = DataRow(
          cells: [
            DataCell(Text(element.position.toString(),
              style: Theme.of(context).textTheme.labelLarge)),
            DataCell(Text(element.bezeichnung.toString(),
              style: Theme.of(context).textTheme.labelLarge)),
            DataCell(Text(element.konkurrenz.toString(),
              style: Theme.of(context).textTheme.labelLarge)),
            DataCell(Text(element.tableauID.toString(),
              style: Theme.of(context).textTheme.labelLarge))
          ],
          selected: element.tableauID == _selectedID,
          onSelectChanged: (val) {
            _fillEditTxt(element.tableauID);
          });
      rowList.add(row);
    }
    return rowList;
  }

  /// Die Anzeige mit selektierte füllen
  void _fillEditTxt(int selectedID) {
    for (var element in _tableauList!) {
      if (element.tableauID == selectedID) {
        _txtPos.text = element.position.toString();
        _txtBezeichnung.text = element.bezeichnung!;
        _txtKonkurren.text = element.konkurrenz!;
      }
    }
    setState(() {
      _selectedID = selectedID;
    });
  }

  /// Ein neues Tableau eingeben
  void _neuesTableau() {
    _txtPos.clear();
    _txtBezeichnung.clear();
    _txtKonkurren.clear();
    setState(() {
      _selectedID = -1;
    });
  }

  /// Speichern der bestehenden Eingabe
  void _speichern() async {
    if (_formKey.currentState!.validate()) {
      Tableau tableau = Tableau(
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
    Tableau tableau = Tableau(_selectedID, _txtPos.text, _txtBezeichnung.text, _txtKonkurren.text);
    String message = await tableau.delete();
    if (message.length > 10) {
      // ignore: use_build_context_synchronously
      AlertPopup popup = AlertPopup("Tableau löschen", message, context);
      popup.showMyDialog();
    }
    _neuesTableau();
    // damit neue Liste angezeigt wird
    _tableauList!.clear();
    _readData();
  }
}
