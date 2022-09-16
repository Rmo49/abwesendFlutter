import 'package:abwesend/model/config.dart';
import 'package:flutter/material.dart';

class ConfigData extends StatefulWidget {
  const ConfigData({Key? key}) : super(key: key);

  @override
  ConfigDataState createState() => ConfigDataState();
}

class ConfigDataState extends State<ConfigData> {
  String _selectedKey = "x";
  final TextEditingController _txtValue = TextEditingController();

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Config data'),
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
                if (value!.isEmpty) {
                  return 'Wert eingeben';
                }
                return null;
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: "neuer Wert",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)))),
            ),
          ),
          Expanded(
            child: DataTable(
              columns: const [
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

  // Die Liste alle Tableau
  List<DataRow> _getConfigRows() {
    List<DataRow> rowList = [];
    Config.configMap!.forEach((key, value) {
      DataRow row = DataRow(
          cells: [
            DataCell(Text(key,
              style: Theme.of(context).textTheme.labelMedium)),
            DataCell(Text(value,
              style: Theme.of(context).textTheme.labelMedium)),
          ],
          selected: key == _selectedKey,
          onSelectChanged: (val) {
            _fillEditTxt(key);
          });
      rowList.add(row);});
    return rowList;
  }

  /// Die Eingabe füllen, damit editiert werden kann
  void _fillEditTxt(String key) {
    _txtValue.text = Config.configMap![key];
    setState(() {
      _selectedKey = key;
    });
  }

  /// Speichern, wenn was geändert
  Future _speichern() async {
    if (_txtValue.text.isNotEmpty) {
      String message = await Config.saveConfig(_selectedKey, _txtValue.text);
      if (message.startsWith('OK')) {
        Config.updateConfig(_selectedKey, _txtValue.text);
      }
      _txtValue.text = message;
    }
    setState(() {
      _selectedKey = " ";
    });
  }
}
