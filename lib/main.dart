import 'package:abwesend/pages/config_data.dart';
import 'package:flutter/material.dart';

import 'package:abwesend/pages/abwesend_show.dart';
import 'package:abwesend/pages/login.dart';
import 'package:abwesend/pages/home.dart';
import 'package:abwesend/pages/einstellungen.dart';
import 'package:abwesend/pages/spieler_admin.dart';
import 'package:abwesend/pages/tableau_data.dart';
import 'package:abwesend/pages/abwesend_edit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Anzeige der Buttons
  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.orangeAccent[400],
    minimumSize: Size(150, 40),
    elevation: 5,
    textStyle: TextStyle(fontSize: 16),
    padding: EdgeInsets.all(16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    )
  );


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCA CM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: 20.0),
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        ),
        elevatedButtonTheme:
            ElevatedButtonThemeData(style: elevatedButtonStyle),
      ),

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
    );
  }
}
