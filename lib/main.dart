import 'package:abwesend/pages/config_data.dart';
import 'package:flutter/material.dart';

import 'package:abwesend/pages/abwesend_show.dart';
import 'package:abwesend/pages/login.dart';
import 'package:abwesend/pages/home.dart';
import 'package:abwesend/pages/einstellungen.dart';
import 'package:abwesend/pages/spieler_admin.dart';
import 'package:abwesend/pages/tableau_data.dart';
import 'package:abwesend/pages/abwesend_edit.dart';

void main() => runApp(MaterialApp(
      // dieses Widget wird zuerst geladen
      initialRoute: '/login',
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => Login(),
        '/abwesend_show': (context) => AbwesendShow(),
        '/abwesend_edit': (context) => AbwesendEdit(),
        '/spieler_admin': (context) => SpielerAdmin(),
        '/tableau_data': (context) => TableauData(),
        '/config_data': (context) => ConfigData(),
        '/einstellungen': (context) => Einstellungen(),
      },
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.orange[200],
          shape: RoundedRectangleBorder(),
          minWidth: 60.0,
        ),
      ),
      home: Home(),
    );
  }
}
