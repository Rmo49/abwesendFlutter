import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:abwesend/model/globals.dart' as global;
import 'package:abwesend/model/login_storage.dart';
import 'package:abwesend/model/menu_settings.dart';
import 'package:abwesend/pages/app_info.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

/// Der Hauptscreen
class _HomeState extends State<Home> {
  final DateFormat dateForm = new DateFormat('d.M.yyyy');
  final DateFormat dateFormShort = new DateFormat('d.M.');
  TextEditingController txtDatumStart = TextEditingController();
  TextEditingController txtPasswort = TextEditingController();
  TextEditingController txtError = TextEditingController();

  @override
  void initState() {
    super.initState();
    txtDatumStart.text = dateForm.format(global.startDatum);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called

    return new Scaffold(
        appBar: AppBar(
          title: Text('Abwesend TCA'),
          actions: <Widget>[
            PopupMenuButton<String>(
                onSelected: menuAction,
                itemBuilder: (BuildContext context) {
                  return MenuSetting.menu.map((String wahl) {
                    return PopupMenuItem<String>(
                      value: wahl,
                      child: Text(wahl),
                    );
                  }).toList();
                }),
          ],
        ),

        body: Container(
          padding: EdgeInsets.all(4.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  color: Colors.orange[500],
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  onPressed: () {
                    global.tableauId = -1;
                    Navigator.pushNamed(context, '/spieler_select', arguments: {
                      'tableauId': -1,
                    });
                  },
                  child: Row(children: <Widget>[
                    Icon(Icons.person),
                    Text(
                      '  Spieler wählen',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ]),
                ),
                FlatButton(
                  color: Colors.orange[700],
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  onPressed: () {
                    Navigator.pushNamed(context, '/tableau_select');
                  },
                  child: Row(children: <Widget>[
                    Icon(Icons.people),
                    Text(
                      '  Tableau wählen',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ]),
                ),
                getStartDatum(),
                Text(' '),
                Container(
                  color: Colors.orange[300],
                  child: CheckboxListTile(
                    title: Text(
                      'nur Grafik anzeigen',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: global.nurGrafik,
                    onChanged: (bool value) {
                      setState(() {
                        global.nurGrafik = value;
                      });
                    },
                  ),
                ),
              ]),
        ));
  }

  /// Die Wahl des Menues
  void menuAction(String wahl) {
    if(wahl == MenuSetting.PasswordChange) {
      _passwortAendern();
    }
    if(wahl == MenuSetting.Infos) {
      AppInfo appInfo = new AppInfo();
      appInfo.showAppInfo(context);
    }
    if(wahl == MenuSetting.Logount) {
      print ("Logout");
    }
  }

  /// Das Menu an der rechten Seite
  void _passwortAendern() {
    txtPasswort.text = "";
    txtError.text = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SimpleDialog(
          title: new Text("Passwort ändern"),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: txtPasswort,
                decoration: InputDecoration(
                    labelText: "Neues Passwort eingeben",
                    hintText: "Passwort",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text("Speichern"),
                onPressed: _setNewPassword,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                controller: txtError,
                readOnly: true,
              ),
            ),
            // usually buttons at the bottom of the dialog
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: new Text("Schliessen"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _setNewPassword() async {
    if (txtPasswort.text.length < 4) {
      txtError.text = "mindestens 4 Zeichen";
      return;
    }
    _savePassword();
  }

  void _savePassword() async {
    var url = "https://nomadus.ch/tca/db/userSet.php";
    try {
      final response = await http.post(url, body: {
        "userName": global.userName,
        "passwort": txtPasswort.text,
      });

      if (response.statusCode == 200) {
        if (response.body.startsWith("OK")) {
          LoginStorage loginStorage = new LoginStorage();
          loginStorage.saveLoginToFile(global.userName, txtPasswort.text);
          txtError.text = "neues Passwort gespeichert";
        }
        if (response.body.startsWith("NOK")) {
          txtError.text = "kann Passwort nicht ändern";
          return;
        }
      } else {
        String fehler = response.body;
        txtError.text = "konnte Passwort nicht speichern \n $fehler";
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

  /// Die Wahl des Startdatums
  Widget getStartDatum() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(' '),
          Text(
            'Anzeige',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ButtonBar(
              mainAxisSize: MainAxisSize
                  .min, // this will take space as minimum as posible(to center)
              buttonHeight: 25.0,
              buttonPadding: EdgeInsets.all(2.0),
              children: getDatumButtons(),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ab Datum: ', style: TextStyle(fontSize: 18.0)),
              Text(
                dateForm.format(global.startDatumAnzeigen),
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ]);
  }

  /// Die Liste mit allen möglichen Datum
  List<Widget> getDatumButtons() {
    List<RaisedButton> list = new List<RaisedButton>();
    DateTime datum = global.startDatum;
    while (datum.compareTo(global.endDatum) < 0) {
      DateTime datumButton = datum;
      list.add(
        new RaisedButton(
          color: Colors.orange[400],
          padding: const EdgeInsets.all(0.0),
          child: Text(dateFormShort.format(datumButton)),
          onPressed: () {
            getSelectedDatum(datumButton);
          },
          highlightColor: Colors.orange[900],
        ),
      );
      datum = datum.add(Duration(days: 2));
    }
    return list;
  }

  void getSelectedDatum(DateTime datum) {
    global.startDatumAnzeigen = datum;
    Duration duration = datum.difference(global.startDatum);
    global.arrayStart = duration.inDays;
    setState(() {});
  }
}

