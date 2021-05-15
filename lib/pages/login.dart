import 'package:abwesend/model/my_uri.dart';
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

  TextEditingController _txtScheme = TextEditingController();
  TextEditingController _txtHost = TextEditingController();
  TextEditingController _txtPort = TextEditingController();
  TextEditingController _txtPath = TextEditingController();
  TextEditingController _txtDbPw = TextEditingController();
  TextEditingController _txtUser = TextEditingController();
  TextEditingController _txtUserPw = TextEditingController();
  TextEditingController _txtInfo = TextEditingController();

  bool _showUserPw = false;
  int _txtErrorLines = 0;

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
      _displayInfo(error);
    }
    global.abDatumAnzeigen = global.dateFormDb.parse(localStorage.showAbDatum!);

  }

  _setVars() async {
    _txtErrorLines = 1;
    setState(() {
      _txtScheme.text = localStorage.scheme;
      _txtHost.text = localStorage.host;
      _txtPort.text = localStorage.port.toString();
      _txtPath.text = localStorage.path;
      _txtDbPw.text = localStorage.dbPw;
      _txtUser.text = localStorage.userName!;
      _txtUserPw.text = localStorage.userPw!;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_txtErrorLines <= 0) {
      _txtErrorLines = 1;
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(global.titel),
      ),
      body: Container(
          child: Column(children: <Widget>[
            Text('Verbindung zum Server',
                style: Theme.of(context).textTheme.bodyText1),
            Expanded(
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  controller: _txtScheme,
                  decoration: InputDecoration(
                      labelText: "Scheme",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                ),
              ),
              Flexible(
                flex: 2,
                child: TextField(
                  controller: _txtHost,
                  decoration: InputDecoration(
                      labelText: "Host",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                ),
              ),
              Flexible(
                flex: 1,
                child: TextField(
                  controller: _txtPort,
                  decoration: InputDecoration(
                      labelText: "Port",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                ),
              ),
              Flexible(
                flex: 2,
                child: TextField(
                  controller: _txtPath,
                  decoration: InputDecoration(
                      labelText: "Pfad",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: ElevatedButton(
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
                    ),
                    obscureText: true,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
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
          child: ElevatedButton(
            child: const Text('Login', style: TextStyle(fontSize: 16)),
            onPressed: () {
              _loginCheck();
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              maxLines: _txtErrorLines,
              controller: _txtInfo,
              readOnly: true,
            )),
      ])),
    );
  }

  /// Verbindung zu PHP-funktionen testen
  Future _connectTest() async {
    _displayInfo("bitte warten...");
    if (_txtHost.text.length < 5) {
      _displayInfo("Eine Web-Adresse eingeben");
    } else {
      localStorage.scheme = _txtScheme.text.trim();
      localStorage.host = _txtHost.text.trim();
      if (_txtPort.text.length > 0) {
        localStorage.port = int.parse(_txtPort.text.trim());
      }
      else {
        localStorage.port = 0;
      }
      localStorage.path = _txtPath.text.trim();
      localStorage.saveLocalData();

      try {
        final response = await http.post(MyUri.getUri("/testConnect.php"));
        if (response.statusCode == 200) {
          _displayInfo(response.body);
        } else {
          _displayInfo("Konnte keine Verbindung aufbauen, Status: " +
              response.statusCode.toString());
        }
      } catch (e) {
        print('Fehler:  $e');
        _displayInfo('Ist eine Internet-Verbindung vorhanden? \n $e');
      }
    }
  }

  /// DB-Verbindung testen, ist passwort ok?
  Future _dbTest() async {
    if (_txtDbPw.text.length < 3) {
      _displayInfo("DB-Passwort zu kurz");
      return;
    } else {
      await _readDbName();
      localStorage.dbPw = _txtDbPw.text.trim();
      localStorage.saveLocalData();
      global.dbPass = localStorage.dbPw;

      try {
        final response =
            await http.post(MyUri.getUri("/testDbPost.php"), body: {
          "dbname": global.dbName,
          "dbuser": global.dbUser,
          "dbpass": global.dbPass,
        });

        if (response.statusCode == 200) {
          _displayInfo(response.body);
        } else {
          _displayInfo(
              "Passwort falsch, Status: " + response.statusCode.toString());
        }
      } catch (e) {
        print('Fehler:  $e');
        _displayInfo('Ist eine Internet-Verbindung vorhanden? \n $e');
      }
    }
  }

  /// login service zum prüfen, ob erlaubt, wenn ja, ruft home auf.
  Future _loginCheck() async {
    if ((_txtUser.text.length < 1) || (_txtUserPw.text.length < 1)) {
      _displayInfo("Du musst schon etwas eingeben");
      return;
    }
    String brand = "Browser";
    String device = "";
    if (!kIsWeb) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      brand = androidInfo.brand;
      device = androidInfo.device;
    }

    try {
      final response = await http.post(MyUri.getUri("/userCheck.php"), body: {
        "userName": _txtUser.text.trim(),
        "passwort": _txtUserPw.text.trim(),
        "dbpass": _txtDbPw.text.trim(),
        "brand": brand,
        "device": device,
      });

      if (response.statusCode == 200) {
        if (response.body.startsWith("OK")) {
          await _setAllData();
          // weitermachen
          await _readDbName();
          if (global.dbName!.length > 0) {
            // await Config.readConfig();
          }
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (response.body.startsWith("NOK")) {
          _displayInfo("falscher Benutzer Name oder Passwort");
          return;
        } else {
          _displayInfo(response.body);
        }
      } else {
        _displayInfo("falscher Benutzer Name oder Passwort");
      }
    } catch (e) {
      print('Fehler:  $e');
      _displayInfo(
          'Kann Login-Check nicht ausführen, ist eine Internet-Verbindung vorhanden? \n $e');
      return;
    }
  }

  Future _setAllData() async {
    localStorage.scheme = _txtScheme.text.trim();
    localStorage.host = _txtHost.text.trim();
    String lPort = _txtPort.text.trim();
    if (lPort.length > 0) {
      localStorage.port = int.parse(_txtPort.text.trim());
    }
    else {
      localStorage.port = 0;
    }
    localStorage.path = _txtPath.text.trim();
    localStorage.userName = _txtUser.text.trim();
    localStorage.userPw = _txtUserPw.text.trim();
    localStorage.dbPw = _txtDbPw.text.trim();
    localStorage.saveLocalData();
    global.userName = localStorage.userName!;
    global.dbPass = localStorage.dbPw;
    global.scheme = localStorage.scheme;
    global.host = localStorage.host;
    global.port = localStorage.port;
    global.path = localStorage.path;
  }

  /// den Namen der Datenbank und DB-User lesen von Text-file auf Server
  Future _readDbName() async {
    try {
      final response = await http.post(MyUri.getUri("/readDbName.php"), body: {
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
        _displayInfo(response.body);
        return;
      }
    } catch (e) {
      print('Fehler:  $e');
      _displayInfo(
          'Kann DB-Name nicht lesen, ist eine Internet-Verbindung vorhanden? \n $e');
      return;
    }
  }

  /// Die Error-Message anzeigen
  void _displayInfo(String message) {
    double zeilen = message.length / 40;
    _txtErrorLines = zeilen.round();
    if (_txtErrorLines > 6) {
      _txtErrorLines = 6;
    }
    setState(() {
      _txtInfo.text = message;
    });
  }
}
