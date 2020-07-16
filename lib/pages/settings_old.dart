import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Spieler import'),
            onTap: () {
              Navigator.pushNamed(context, '/spieler_import');
            },
          )
        ],
      )
    );
  }
}
