import 'package:abwesend/model/local_storage.dart';
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
          const Text(
            'Setup',
            style: TextStyle(fontSize: 20),
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
              Icon(Icons.person_add),
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
              Icon(Icons.person_add),
              Text(
                ' Config verwalten',
                style: TextStyle(fontSize: 20.0),
              ),
            ]),
          ),
          TextButton(
            onPressed: () => _passwortAendern(context),
            child: Row(children: <Widget>[
              Icon(Icons.person_add),
              Text(
                ' Passwort ändern',
                style: TextStyle(fontSize: 20.0),
              ),
            ]),
          ),
          ElevatedButton(
            child: const Text('App Info'),
            onPressed: () => _showAppInfo(context),
          ),
          ElevatedButton(
            onPressed: () => _logout(context),
            child: const Text('Logout'),
          ),
          // ElevatedButton(
          // onPressed: _closeDrawer,
          // child: const Text('Close Drawer'),
          // ),
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
    LocalStorage localStorage = LocalStorage();
    Uri uri = Uri(
        scheme: localStorage.scheme,
        host: localStorage.host,
        path: localStorage.path + "/userSet.php");
    try {
      final response = await http.post(uri, body: {
        "userName": global.userName,
        "passwort": txtPasswort.text,
      });

      if (response.statusCode == 200) {
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
