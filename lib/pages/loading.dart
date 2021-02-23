import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/local_storage.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  final LocalStorage localStorage = LocalStorage();

  TextEditingController txtUrl = TextEditingController();
  TextEditingController txtDbPw = TextEditingController();
  TextEditingController txtUser = TextEditingController();
  TextEditingController txtUserPw = TextEditingController();
  TextEditingController txtError = TextEditingController();

  bool _showDbPw = false;
  bool _showUserPw = false;

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    _readBasicData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("TCA CM abwesend"),
      ),
      body: Container(
          child: Column(children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: txtUrl,
              decoration: InputDecoration(
                  labelText: "Verbindung",
                  hintText: "http://",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)))),
            ),
          ),
        ),
        Expanded(
          child: RaisedButton(
            child:
                const Text('Verbindung testen', style: TextStyle(fontSize: 16)),
            onPressed: () {
              _connectTest();
            },
          ),
        ),
        Expanded(
          child: Container(
            child: Row(children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextField(
                    controller: txtDbPw,
                    decoration: InputDecoration(
                      labelText: "DB Passwort",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showDbPw = !_showDbPw;
                          });
                        },
                        child: Icon(
                          _showDbPw ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    obscureText: !_showDbPw,
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  child:
                      const Text('DB testen', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    _dbTest();
                  },
                ),
              ),
            ]),
          ),
        ),
        Expanded(
          child: Container(
            child: Row(children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextField(
                    controller: txtUser,
                    decoration: InputDecoration(
                        labelText: "Benutzer Name",
                        hintText: "Vorname",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextField(
                    controller: txtUserPw,
                    decoration: InputDecoration(
                      labelText: "Benutzer Passwort",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showUserPw = !_showUserPw;
                          });
                        },
                        child: Icon(
                          _showUserPw ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    obscureText: !_showUserPw,
                  ),
                ),
              ),
            ]),
          ),
        ),
        Expanded(
          child: RaisedButton(
            child: const Text('Login', style: TextStyle(fontSize: 16)),
            onPressed: () {
              _loginCheck();
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              controller: txtError,
              readOnly: true,
            )),
      ])),
    );
  }

  /// Verbindung zu PHP-funktionen testen
  Future _connectTest() async {
    if (txtUrl.text.length < 10) {
      setState(() {
        txtError.text = "Eine Web-Adresse eingeben";
      });
    } else {
      localStorage.webAdress = txtUrl.text.trim();
      localStorage.saveLocalData();

      var url = localStorage.webAdress + "/testConnect.php";
      // var url = "https://nomadus.ch/tca/db/testConnect.php";
      try {
        final response = await http.post(url);
        if (response.statusCode == 200) {
          setState(() {
            txtError.text = response.body;
          });
        } else {
          setState(() {
            txtError.text = "Konnte keine Verbindung aufbauen, Status: " +
                response.statusCode.toString();
          });
        }
      } catch (e) {
        print('Fehler:  $e');
        setState(() {
          txtError.text = 'Ist eine Internet-Verbindung vorhanden? \n $e';
        });
      }
    }
  }

  /// DB-Verbindung testen, ist passwort ok?
  Future _dbTest() async {
    if (txtDbPw.text.length < 3) {
      setState(() {
        txtError.text = "DB-Passwort zu kurz";
      });
      return;
    } else {
      await _readDbName();
      localStorage.dbPw = txtDbPw.text.trim();
      localStorage.saveLocalData();
      global.dbPass = localStorage.dbPw;

      var url = localStorage.webAdress + "/testDbPost.php";
      try {
        var response = await http.post(url, body: {
          "dbname": global.dbName,
          "dbuser": global.dbUser,
          "dbpass": global.dbPass,
        });


        if (response.statusCode == 200) {
          setState(() {
            txtError.text = response.body;
          });
        } else {
          setState(() {
            txtError.text = "Passwort falsch, Status: " +
                response.statusCode.toString();
          });
        }
      } catch (e) {
        print('Fehler:  $e');
        setState(() {
          txtError.text = 'Ist eine Internet-Verbindung vorhanden? \n $e';
        });
      }
    }
  }

  /// login service zum prüfen, ob erlaubt, wenn ja, ruft home auf.
  Future _loginCheck() async {
    if ((txtUser.text.length < 1) || (txtUserPw.text.length < 1)) {
      setState(() {
        txtError.text = "Du musst schon etwas eingeben";
      });
      return;
    }
    String brand = "Browser";
    String device = "";
    if (!kIsWeb) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      brand = androidInfo.brand;
      device = androidInfo.device;
    }

    var url = localStorage.webAdress + "/userCheck.php";
    try {
      final response = await http.post(url, body: {
        "userName": txtUser.text.trim(),
        "passwort": txtUserPw.text.trim(),
        "brand": brand,
        "device": device,
        "dbpass": global.dbPass,
      });

      if (response.statusCode == 200) {
        if (response.body.startsWith("OK")) {
          localStorage.userName = txtUser.text.trim();
          localStorage.userPw = txtUserPw.text.trim();
          localStorage.saveLocalData();
          global.userName = localStorage.userName;
          // weitermachen
          if (global.dbName.length > 0) {
            await readConfig();
          }
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

  /// Die Basisdaten lesen, zuerst Name der DB, dann Config
  Future _readBasicData() async {
    await _readLocalData();
    await _readDbName();
  }

  _readLocalData() async {
    LocalStorage ls = LocalStorage();
    String error = await ls.readLocalData();
    txtUrl.text = localStorage.webAdress;
    txtDbPw.text = localStorage.dbPw;
    txtUser.text = localStorage.userName;
    txtUserPw.text = localStorage.userPw;
    if (error.length > 0) {
      txtError.text = error;
    }
    setState(() {});
  }

  /// den Namen der Datenbank und DB-User lesen von Text-file auf Server
  Future _readDbName() async {
    var url = localStorage.webAdress + "/readDbName.php";
    try {
      final response = await http.post(url, body: {
        "passwort": "tcaDb4123",
      });
      if (response.statusCode == 200) {
        String antwort = response.body;
        List<String> dbInfo = antwort.split(',');
        if (dbInfo.length >= 2) {
          global.dbName = dbInfo[0];
          global.dbUser = dbInfo[1];
          // TODO: global.dbPort auch noch variable impl.
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
    var url = localStorage.webAdress + "/readConfig.php";

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
