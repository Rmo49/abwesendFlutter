import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/login_storage.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  final LoginStorage loginStorage = new LoginStorage();

  TextEditingController txtUser = TextEditingController();
  TextEditingController txtPasswort = TextEditingController();
  TextEditingController txtError = TextEditingController();

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    readBasicData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("TCA CM abwesend"),
      ),
      body: Container(
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: txtUser,
                decoration: InputDecoration(
                    labelText: "Benutzer Name",
                    hintText: "Vorname",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: txtPasswort,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Passwort",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
              ),
            ),

        RaisedButton(
          child: const Text('Login', style: TextStyle(fontSize: 16)),
          onPressed: () {
            loginCheck();
          },
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              controller: txtError,
              readOnly: true,
            )),
      ])),
    );
  }

  /// login service zum prüfen, ob erlaubt, wenn ja, ruft home auf.
  Future loginCheck() async {
    var url = "https://nomadus.ch/tca/db/userCheck.php";
    try {
      final response = await http.post(url, body: {
        "userName": txtUser.text.trim(),
        "passwort": txtPasswort.text.trim(),
      });

      if (response.statusCode == 200) {
        if (response.body.startsWith("OK")) {
          saveLogin(txtUser.text, txtPasswort.text);
          // weitermachen
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (response.body.startsWith("NOK")) {
          setState(() {
            txtError.text = "falscher Benutzer Name oder Passwort";
          });
          return;
        }
      } else {
        setState(() {
          txtError.text = "falscher Benutzer Name oder Passwort";
        });
      }
    } catch (e) {
      print('Error:  $e');
      setState(() {
        txtError.text =
            'Keine Verbindung zur DB, ist eine Internet-Verbindung vorhanden?';
      });
      return;
    }
  }

  /// Die Login-Infos in File speichern
  void saveLogin(String user, String password) {
    String userPw = user + ";" + password;
    loginStorage.writeLogin(userPw);
  }

  /// Die Basisdaten lesen, zuerst Name der DB, dann Config
  Future readBasicData() async {
    readLogin();
    await readDbName();
    readConfig();
  }

  Future readLogin() async {
    var result = await loginStorage.readLogin();
    String userPw = result;
    List<String> login = userPw.split(";");
    if (login.length == 2) {
      txtUser.text = login.elementAt(0);
      txtPasswort.text = login.elementAt(1);
    }
    setState(() {
    });
  }

  /// den Namen der Datenbank
  Future readDbName() async {
    var url = "https://nomadus.ch/tca/db/readDbName.php";
    try {
      final response = await http.post(url, body: {
        "passwort": "tcaDb4123",
      });
      if (response.statusCode == 200) {
        global.dbname = response.body.trim();
      } else {
        setState(() {
          txtError.text = response.body;
        });
        return;
      }
    } catch (e) {
      print('Error:  $e');
      setState(() {
        txtError.text =
            'Keine Verbindung zur DB, ist eine Internet-Verbindung vorhanden?';
      });
      return;
    }
  }

  /// Die Configuration von DB lesen, die Daten werden in json-format geliefert
  Future readConfig() async {
    var url = "https://nomadus.ch/tca/db/readConfig.php";
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbname,
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setConfigData(data);
      } else {
        setState(() {
          txtError.text = response.body;
        });
        return;
      }
    } catch (e) {
      print('Error:  $e');
      setState(() {
        txtError.text =
            'Keine Verbindung zur DB, ist eine Internet-Verbindung vorhanden?';
      });
      return;
    }
  }

  /// Die Config-Daten setzen
  setConfigData(Map<String, dynamic> data) {
    global.configData = data;

    global.startDatum = global.dateFormDb.parse(data['turnier.beginDatum']);
    global.startDatumAnzeigen = global.startDatum;
    global.endDatum = global.dateFormDb.parse(data['turnier.endDatum']);
    Duration diff = global.endDatum.difference(global.startDatum);
    // die Anzahl tage für die Anzeige
    global.arrayLen = diff.inDays + 1;
    global.arrayLen < 0
        ? global.arrayLen = -global.arrayLen
        : global.arrayLen = global.arrayLen;
    if (global.arrayLen > 21) {
      global.arrayLen = 21;
    }
  }
}
