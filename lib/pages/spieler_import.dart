import 'dart:convert';
import 'package:abwesend/db_service/db_spieler.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:collection';

class SpielerImport extends StatefulWidget {
  @override
  _SpielerImportState createState() => _SpielerImportState();
}

final databaseReference = FirebaseDatabase.instance.reference();

class _SpielerImportState extends State<SpielerImport> {
  TextEditingController name = new TextEditingController();
  TextEditingController result = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Spieler Import'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Username",
              style: TextStyle(fontSize: 18.0),
            ),
            TextField(
              controller: name,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            new RaisedButton(
              child: Text("Add Spieler on DB tennis2"),
              onPressed: () {
                addSpieler(new Spieler(name.text, "Vorname1", "email1"));
//                _saveDate(new Spieler(
//                    "Json1", "VornameJson", "emailJson", ";-19;;;12-;"));
              },
            ),
            TextField(
              controller: result,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Result',
              ),
            ),
          ],
        ),
      ),
    );
  }

  addSpieler(Spieler spieler) async {
    var url = "https://nomadus.ch/tca/db/insertSpieler.php";
    final response = await http.post(url,
        body: {"name": spieler.name, "vorname": "Rudolf", "email": "mail"});
    if (response.statusCode == 200) {
      result.text = "gespeichert";
    } else {
      var fehler = response.headers['error'];
      result.text = "Fehler:  $fehler";
    }
  }
}
