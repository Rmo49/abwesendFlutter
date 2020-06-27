import 'package:flutter/material.dart';

import 'package:abwesend/pages/tableau_select.dart';
import 'package:abwesend/pages/abwesend_show.dart';
import 'package:abwesend/pages/loading.dart';
import 'package:abwesend/pages/home.dart';
import 'package:abwesend/pages/settings.dart';
import 'package:abwesend/pages/spieler_select.dart';

void main() => runApp(MaterialApp(
      // diese Widget wird zuerst geladen
      initialRoute: '/loading',
      routes: {
        '/home': (context) => Home(),
        '/loading': (context) => Loading(),
        '/settings': (context) => Settings(),
        '/tableau_select': (context) => TableauSelect(),
        '/spieler_select': (context) => SpielerSelect(),
        '/abwesend_show': (context) => AbwesendShow(),
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
