import 'package:abwesend/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:abwesend/pages/home.dart';
import 'package:abwesend/pages/settings.dart';
import 'package:abwesend/pages/bak/spieler_import.dart';
import 'package:abwesend/pages/spieler_select.dart';
import 'package:abwesend/pages/spieler_show.dart';

void main() => runApp(MaterialApp(
      // diese Widget wird zuerst geladen
      initialRoute: '/loading',
      routes: {
        '/home': (context) => Home(),
        '/loading' : (context) => Loading(),
        '/settings': (context) => Settings(),
        '/spieler_import': (context) => SpielerImport(),
        '/spieler_select' : (context) => SpielerSelect(),
        '/spieler_show' : (context) => SpielerShow(),
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
      ),
      home: Home(),
    );
  }
}
