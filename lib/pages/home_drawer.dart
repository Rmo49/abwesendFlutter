import 'package:abwesend/model/local_storage.dart';
import 'package:abwesend/model/my_uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;

import 'app_info.dart';

class HomeDrawer {
  TextEditingController txtPasswort = TextEditingController();
  TextEditingController txtError = TextEditingController();

  getDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30),
          ),
          Text(
            'Setup',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/einstellungen', arguments: {});
            },
            child: Row(children: <Widget>[
              Icon(Icons.settings),
              Text(
                '  Einstellungen',
                style: TextStyle(fontSize: 20.0),
              ),
            ]),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tableau_data', arguments: {
                'tableauID': -1,
              });
            },
            child: Row(children: <Widget>[
              Icon(Icons.article_outlined),
              Text(
                '  Tableau verwalten',
                style: TextStyle(fontSize: 20.0),
              ),
            ]),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/config_data', arguments: {});
            },
            child: Row(children: <Widget>[
              Icon(Icons.apps),
              Text(
                ' Config verwalten',
                style: TextStyle(fontSize: 20.0),
              ),
            ]),
          ),
          TextButton(
            onPressed: () => _passwortAendern(context),
            child: Row(children: <Widget>[
              Icon(Icons.accessibility),
              Text(
                ' Passwort ändern',
                style: TextStyle(fontSize: 20.0),
              ),
            ]),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              child: const Text('App Info'),
              onPressed: () => _showAppInfo(context),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
            onPressed: () => _closeDrawer(context),
            child: const Text('Close'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    AppInfo appInfo = new AppInfo();
    appInfo.showAppInfo(context);
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _closeDrawer(BuildContext context) {
    Navigator.pop(context);
  }

  //---- Popup Paswort ändern --------------------
  /// Passwort ändern, Anzeige der Felder
  void _passwortAendern(BuildContext context) {
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
              child: ElevatedButton(
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
              child: ElevatedButton(
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
    try {
      final response = await http.post(MyUri.getUri("/userSet.php"), body: {
        "userName": global.userName,
        "passwort": txtPasswort.text,
      });

      if (response.statusCode == 200) {
        LocalStorage localStorage = LocalStorage();
        if (response.body.startsWith("OK")) {
          localStorage.userPw = txtPasswort.text;
          localStorage.saveLocalData();
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
      // setState(() {
      //   txtError.text =
      //   'Keine Verbindung zur DB, ist eine Internet-Verbindung vorhanden?';
      // });
      return;
    }
  }
}
