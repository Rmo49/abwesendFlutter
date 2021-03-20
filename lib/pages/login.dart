import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/local_storage.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LocalStorage localStorage = LocalStorage();

  TextEditingController _txtUrl = TextEditingController();
  TextEditingController _txtDbPw = TextEditingController();
  TextEditingController _txtUser = TextEditingController();
  TextEditingController _txtUserPw = TextEditingController();
  TextEditingController _txtError = TextEditingController();

  bool _showDbPw = false;
  bool _showUserPw = false;

  @override
  void initState() {
    // wird genau einmal aufgerufen, wenn das Objekt initialisiert wird
    super.initState();
    _readBasicData();
  }

  /// Die Basisdaten lesen, zuerst Name der DB, dann Config
  Future _readBasicData() async {
    await _readLocalData();
    await _setVars();
  }

  _readLocalData() async {
    String error = await localStorage.readLocalData();
    if (error.length > 0) {
      setState(() {
        _txtError.text = error;
      });
    }
    global.abDatumAnzeigen =
        global.dateFormDb.parse(localStorage.showAbDatum);
  }

  _setVars() async {
    _txtUrl.text = localStorage.webAdress;
    _txtDbPw.text = localStorage.dbPw;
    _txtUser.text = localStorage.userName;
    _txtUserPw.text = localStorage.userPw;
    setState(() {});
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
              controller: _txtUrl,
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
                    controller: _txtDbPw,
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
                    controller: _txtUser,
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
                    controller: _txtUserPw,
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
              maxLines: 6,
              controller: _txtError,
              readOnly: true,
            )),
      ])),
    );
  }

  /// Verbindung zu PHP-funktionen testen
  Future _connectTest() async {
    if (_txtUrl.text.length < 10) {
      setState(() {
        _txtError.text = "Eine Web-Adresse eingeben";
      });
    } else {
      localStorage.webAdress = _txtUrl.text.trim();
      localStorage.saveLocalData();

      var url = localStorage.webAdress + "/testConnect.php";
      // var url = "https://nomadus.ch/tca/db/testConnect.php";
      try {
        final response = await http.post(url);
        if (response.statusCode == 200) {
          setState(() {
            _txtError.text = response.body;
          });
        } else {
          setState(() {
            _txtError.text = "Konnte keine Verbindung aufbauen, Status: " +
                response.statusCode.toString();
          });
        }
      } catch (e) {
        print('Fehler:  $e');
        setState(() {
          _txtError.text = 'Ist eine Internet-Verbindung vorhanden? \n $e';
        });
      }
    }
  }

  /// DB-Verbindung testen, ist passwort ok?
  Future _dbTest() async {
    if (_txtDbPw.text.length < 3) {
      setState(() {
        _txtError.text = "DB-Passwort zu kurz";
      });
      return;
    } else {
      await _readDbName();
      localStorage.dbPw = _txtDbPw.text.trim();
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
            _txtError.text = response.body;
          });
        } else {
          setState(() {
            _txtError.text =
                "Passwort falsch, Status: " + response.statusCode.toString();
          });
        }
      } catch (e) {
        print('Fehler:  $e');
        setState(() {
          _txtError.text = 'Ist eine Internet-Verbindung vorhanden? \n $e';
        });
      }
    }
  }

  /// login service zum prüfen, ob erlaubt, wenn ja, ruft home auf.
  Future _loginCheck() async {
    if ((_txtUser.text.length < 1) || (_txtUserPw.text.length < 1)) {
      setState(() {
        _txtError.text = "Du musst schon etwas eingeben";
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
        "userName": _txtUser.text.trim(),
        "passwort": _txtUserPw.text.trim(),
        "dbpass": _txtDbPw.text.trim(),
        "brand": brand,
        "device": device,
      });

      if (response.statusCode == 200) {
        if (response.body.startsWith("OK")) {
          localStorage.userName = _txtUser.text.trim();
          localStorage.userPw = _txtUserPw.text.trim();
          localStorage.dbPw = _txtDbPw.text.trim();
          localStorage.saveLocalData();
          global.userName = localStorage.userName;
          global.dbPass = localStorage.dbPw;
          global.abDatumAnzeigen =
              global.dateFormDb.parse(localStorage.showAbDatum);

          // weitermachen
          await _readDbName();
          if (global.dbName.length > 0) {
            // await Config.readConfig();
          }
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (response.body.startsWith("NOK")) {
          setState(() {
            _txtError.text = "falscher Benutzer Name oder Passwort";
          });
          return;
        }
        else {
          _txtError.text = response.body;
        }
      } else {
        setState(() {
          _txtError.text = "falscher Benutzer Name oder Passwort";
        });
      }
    } catch (e) {
      print('Fehler:  $e');
      setState(() {
        _txtError.text =
            'Kann Login-Check nicht ausführen, ist eine Internet-Verbindung vorhanden? \n $e';
      });
      return;
    }
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
        }
      } else {
        setState(() {
          _txtError.text = response.body;
        });
        return;
      }
    } catch (e) {
      print('Fehler:  $e');
      setState(() {
        _txtError.text =
            'Kann DB-Name nicht lesen, ist eine Internet-Verbindung vorhanden? \n $e';
      });
      return;
    }
  }
}
