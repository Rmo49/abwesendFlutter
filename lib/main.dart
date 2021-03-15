import 'package:flutter/material.dart';

import 'package:abwesend/pages/abwesend_show.dart';
import 'package:abwesend/pages/loading.dart';
import 'package:abwesend/pages/home.dart';
import 'package:abwesend/pages/einstellungen.dart';
import 'package:abwesend/pages/spieler_admin.dart';
import 'package:abwesend/pages/tableau_verwalten.dart';
import 'package:abwesend/pages/abwesend_edit.dart';

void main() => runApp(MaterialApp(
      // dieses Widget wird zuerst geladen
      initialRoute: '/loading',
      routes: {
        '/home': (context) => Home(),
        '/loading': (context) => Loading(),
        // '/spieler_select': (context) => SpielerSelect(),
        '/abwesend_show': (context) => AbwesendShow(),
        '/abwesend_edit': (context) => AbwesendEdit(),
        '/spieler_admin': (context) => SpielerAdmin(),
        '/tableau_verwalten': (context) => TableauVerwalten(),
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
