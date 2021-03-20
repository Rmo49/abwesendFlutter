import 'package:abwesend/model/config.dart';
import 'package:flutter/material.dart';
import 'package:abwesend/model/globals.dart' as global;

class ConfigData extends StatefulWidget {
  @override
  _ConfigDataState createState() => _ConfigDataState();
}

class _ConfigDataState extends State<ConfigData> {
  String _selectedKey = "x";
  TextEditingController _txtValue = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readData();
  }

  void _readData() async {
    _selectedKey = "y";
    await Config.readConfig();
    setState(() {
      // _conifgList
    });
  }

  @override
  Widget build(BuildContext context) {
    if (global.userName.compareTo("ruedi") == 0) {
      return new Scaffold(
          appBar: AppBar(
            title: Text('Config data'),
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
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _txtValue,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Wert eingeben';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: "neuer Wert",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)))),
              ),
            ),
            Expanded(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('key')),
                  DataColumn(label: Text('value')),
                ],
                rows: _getConfigRows(),
                columnSpacing: 8,
                dataRowHeight: 30,
              ),
            ),
          ]));
    }
    return new Scaffold(
        appBar: AppBar(
      title: Text('Du darfst das nicht'),
    ));
  }

  // Die Liste alle Tableau
  List<DataRow> _getConfigRows() {
    List<DataRow> rowList = new List<DataRow>();
    Config.configMap.forEach((key, value) {
      DataRow row = DataRow(
          cells: [
            DataCell(Text(key)),
            DataCell(Text(value)),
          ],
          selected: key == _selectedKey,
          onSelectChanged: (val) {
            _fillEditTxt(key);
          });
      rowList.add(row);
    });
    return rowList;
  }

  /// Die Eingabe füllen
  void _fillEditTxt(String key) {
    _txtValue.text = Config.configMap[key];
    setState(() {
      _selectedKey = key;
    });
  }

  /// Speichern, wenn was geändert
  void _speichern() {
    // TODO noch Berechtigung abfragen
    Config.updateConfig(_selectedKey, _txtValue.text);
    Config.saveConfig();
    setState(() {
      _selectedKey = " ";
      _txtValue.text = "";
    });
  }
}
