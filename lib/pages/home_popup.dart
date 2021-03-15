import 'package:abwesend/model/local_storage.dart';
import 'package:abwesend/model/menu_settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:abwesend/model/globals.dart' as global;

class HomePopup {

  TextEditingController txtPasswort = TextEditingController();
  TextEditingController txtError = TextEditingController();
  BuildContext context;

    PopupMenuButton getPopup(BuildContext context) {
    return PopupMenuButton<String>(
        onSelected: menuAction,
        itemBuilder: (BuildContext context) {
          return MenuSetting.menu.map((String wahl) {
            return PopupMenuItem<String>(
              value: wahl,
              child: Text(wahl),
            );
          }).toList();
        });
  }

  /// Die Wahl des Menues
  void menuAction(String wahl) {
    if (wahl == MenuSetting.PasswordChange) {
      _passwortAendern();
    }
    if (wahl == MenuSetting.Infos) {
      // AppInfo appInfo = new AppInfo();
      // appInfo.showAppInfo(context);
    }
    if (wahl == MenuSetting.Logount) {
      // Navigator.pushReplacementNamed(context, '/loading');
    }
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
    var url = localStorage.webAdress + "/userSet.php";
    try {
      final response = await http.post(url, body: {
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
}