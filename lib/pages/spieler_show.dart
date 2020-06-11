import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/pages/abwesend_table.dart';

class SpielerShow extends StatefulWidget {
  @override
  _SpielerShowState createState() => _SpielerShowState();
}

class _SpielerShowState extends State<SpielerShow> {
  // lokale Vars
  Map _selection = {};
  String _spielerId;
  Spieler _spieler;

  TextEditingController _txtController;

  @override
  void initState() {
    super.initState();
    _txtController = TextEditingController();
    _txtController.text = "lese Spieler von DB";
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    _selection = ModalRoute.of(context).settings.arguments;
    _spielerId = _selection['spielerId'];
    readSpieler(_spielerId);

    if (_spieler != null) {
      _txtController.text = _spieler.name;
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spieler anzeigen"),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _txtController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Spieler wählen',
            ),
          ),
          AbwesendTable(
            spieler: _spieler,
          ),
        ],
      ),
    );
  }

  /// Spieler von der DB lesen, dieser werden in json-format geliefert
  Future readSpieler(String spielerId) async {
    var url = "https://nomadus.ch/tca/db/readSpieler.php";
    final response = await http.post(url, body: {
      "id": spielerId,
    });
    if (response.statusCode != 200) {
      print(response.headers['error']);
    } else {
      LineSplitter ls = new LineSplitter();
      List<String> lines = ls.convert(response.body);
      // die erste Zeile enthält keine Daten
      final Map<String, dynamic> data = json.decode(lines.elementAt(1));
      _spieler = Spieler.fromMap(data['spieler']);
      _spieler.setMatches(data['matches']);
    }
    setState(() {});
  }
}
