import 'package:flutter/material.dart';

import 'package:abwesend/pages/config_data.dart';
import 'package:abwesend/pages/abwesend_show.dart';
import 'package:abwesend/pages/login.dart';
import 'package:abwesend/pages/home.dart';
import 'package:abwesend/pages/einstellungen.dart';
import 'package:abwesend/pages/spieler_admin.dart';
import 'package:abwesend/pages/tableau_data.dart';
import 'package:abwesend/pages/abwesend_edit.dart';

import 'package:abwesend/model/globals.dart' as global;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  
  // Anzeige der Buttons
  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.orangeAccent[400],
    minimumSize: const Size(150, 40),
    elevation: 5,
    textStyle: const TextStyle(fontSize: 16),
    padding: const EdgeInsets.all(16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    )
  );

  final ButtonStyle textButtonStyle = TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: Colors.blue[300],
    padding: const EdgeInsets.all(16),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCA Clubmeisterschaft',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: Colors.blue,
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontSize: 16.0),
//          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//          headline6: TextStyle(fontSize: 20.0),
        ),
        elevatedButtonTheme:
            ElevatedButtonThemeData(style: elevatedButtonStyle),
        textButtonTheme:
        TextButtonThemeData(style: textButtonStyle),
      ),

      initialRoute: '/login',
      routes: {
        '/home': (context) => const Home(),
        '/login': (context) => const Login(),
        '/abwesend_show': (context) => const AbwesendShow(),
        '/abwesend_edit': (context) => const AbwesendEdit(),
        '/spieler_admin': (context) => const SpielerAdmin(),
        '/tableau_data': (context) => const TableauData(),
        '/config_data': (context) => const ConfigData(),
        '/einstellungen': (context) => const Einstellungen(),
      },
      // damit kein BuildContext across async gaps.
      navigatorKey: global.navigatorKey,
    );
  }
}
