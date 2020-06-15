import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  TextEditingController txtMessage = TextEditingController();
  TextEditingController txtError = TextEditingController();

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    txtMessage.text = 'Lese Config von DB';
    readConfig();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Abwesend TCA"),
      ),
      body: Container(
          child: Column(children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: txtMessage,
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: txtError,
            )),
      ])),
    );
  }

  /// Die Configuration von DB lesen, die Daten werden in json-format geliefert
  Future readConfig() async {
    var url = "https://nomadus.ch/tca/db/readConfig.php";
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbname,
      });
      if (response.statusCode != 200) {
        setState(() {
          txtError.text = response.body;
        });
        return;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        setConfigData(data);
      }
    } catch (e) {
      print('Error:  $e');
      setState(() {
        txtError.text =
            'Keine Verbindung zu DB, Internet-Verbindutng vorhanden?';
      });
      return;
    }

    setState(() {});
    Navigator.pushReplacementNamed(context, '/home');
  }

  /// Die Config-Daten setzen
  setConfigData(Map<String, dynamic> data) {
    global.configData = data;

    global.startDatum = global.dateFormDb.parse(data['turnier.beginDatum']);
    global.startDatumAnzeigen = global.startDatum;
    global.endDatum = global.dateFormDb.parse(data['turnier.endDatum']);
    Duration diff = global.endDatum.difference(global.startDatum);
    global.arrayLen = diff.inDays + 1;
    global.arrayLen < 0
        ? global.arrayLen = -global.arrayLen
        : global.arrayLen = global.arrayLen;
    if (global.arrayLen > 21) {
      global.arrayLen = 21;
    }
  }
}
