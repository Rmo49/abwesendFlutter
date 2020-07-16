import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  bool _showPassword = false;

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
                decoration: InputDecoration(
                  labelText: "Passwort",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    child: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: !_showPassword,
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
    if ( (txtUser.text.length < 1) || (txtPasswort.text.length < 1) ) {
      setState(() {
        txtError.text = "Du musst schon etwas eingeben";
      });
      return;
    }
    String brand = "Browser";
    String device = "";
    if (! kIsWeb) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      brand = androidInfo.brand;
      device = androidInfo.device;
    }

    var url = "https://nomadus.ch/tca/db/userCheck.php";
    try {
      final response = await http.post(url, body: {
        "userName": txtUser.text.trim(),
        "passwort": txtPasswort.text.trim(),
        "brand": brand,
        "device": device,
        "dbpass": global.dbPass,
      });

      if (response.statusCode == 200) {
        if (response.body.startsWith("OK")) {
          _saveLoginToFile(txtUser.text.trim(), txtPasswort.text.trim());
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
      print('Fehler:  $e');
      setState(() {
        txtError.text =
        'Kann Login-Check nicht ausführen, ist eine Internet-Verbindung vorhanden? \n $e';
      });
      return;
    }
  }

  /// Die Login-Infos in File speichern
  void _saveLoginToFile(String user, String password) {
    LoginStorage loginStorage = new LoginStorage();
    loginStorage.saveLoginToFile(user, password);
    global.userName = user;
  }

  /// Die Basisdaten lesen, zuerst Name der DB, dann Config
  Future readBasicData() async {
    readLogin();
    await readDbName();
    if (global.dbName.length > 0) {
      readConfig();
    }
  }

  Future readLogin() async {
    var result = await loginStorage.readLogin();
    String userPw = result;
    List<String> login = userPw.split(";");
    if (login.length == 2) {
      txtUser.text = login.elementAt(0);
      txtPasswort.text = login.elementAt(1);
    }
    setState(() {});
  }

  /// den Namen der Datenbank und DB-User lesen
  Future readDbName() async {
    var url = "https://nomadus.ch/tca/db/readDbName.php";
    try {
      final response = await http.post(url, body: {
        "passwort": "tcaDb4123",
      });
      if (response.statusCode == 200) {
        String antwort = response.body;
        List<String> dbInfo = antwort.split(',');
        if (dbInfo.length >=2) {
          global.dbName = dbInfo[0];
          global.dbUser = dbInfo[1];
        }
      } else {
        setState(() {
          txtError.text = response.body;
        });
        return;
      }
    } catch (e) {
      print('Fehler:  $e');
      setState(() {
        txtError.text =
        'Kann DB-Name nicht lesen, ist eine Internet-Verbindung vorhanden? \n $e';
      });
      return;
    }
  }

  /// Die Configuration von DB lesen, die Daten werden in json-format geliefert
  Future readConfig() async {
    var url = "https://nomadus.ch/tca/db/readConfig.php";
    try {
      final response = await http.post(url, body: {
        "dbname": global.dbName,
        "dbuser": global.dbUser,
        "dbpass": global.dbPass,
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
      print('Fehler:  $e');
      setState(() {
        txtError.text =
        'Kann Config nicht lesen, ist eine Internet-Verbindung vorhanden? \n $e';
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

    global.zeitWeekBegin = double.parse(data['week.beginZeit']);
    global.zeitWeekEnd = double.parse(data['week.endZeit']);
    global.zeitWeekendBegin = double.parse(data['weekend.beginZeit']);
    global.zeitWeekendEnd = double.parse(data['weekend.endZeit']);
  }
}
