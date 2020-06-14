import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:abwesend/pages/bak/spieler_import.dart';
import 'package:abwesend/model/globals.dart' as global;

class Home extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

/// Der Hauptscreen
class _HomeState extends State<Home> {

  final DateFormat dateForm = new DateFormat('d.M.yyyy');
  TextEditingController txtDatumStart = TextEditingController();

  @override
  void initState() {
    super.initState();
    txtDatumStart.text = dateForm.format(global.startDatum);
  }

    @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called

    return new Scaffold(
      appBar: AppBar(
        title: Text('Abwesend TCA'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Setup Screens',
            onPressed: () {
//              Navigator.pushNamed(context, '/loading');
            },
          ),
        ],
      ),
      //getActions(context)

      drawer: AbwMenu(),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(global.dbname),
            FlatButton(
              color: Colors.orange[500],
              textColor: Colors.white,
              padding: EdgeInsets.all(10.0),
              onPressed: () {
                Navigator.pushNamed(context, '/spieler_select');
              },
              child: Row(children: <Widget>[
                Icon(Icons.person),
                Text(
                  '  Spieler wählen',
                  style: TextStyle(fontSize: 20.0),
                ),
              ]),
            ),
            FlatButton(
              color: Colors.orange[700],
              textColor: Colors.white,
              padding: EdgeInsets.all(10.0),
              onPressed: () {
                Navigator.pushNamed(context, '/spieler_select');
              },
              child: Row(children: <Widget>[
                Icon(Icons.people),
                Text(
                  '  Tableau wählen',
                  style: TextStyle(fontSize: 20.0),
                ),
              ]),
            ),
            TextField(
              controller: txtDatumStart,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0, color: Colors.black38),
                ),
                hintText: 'ab Datum anzeigen',
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Das Menu links mit der Haupt-Navigation
class AbwMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Spieler'),
            onTap: () => {Navigator.pushNamed(context, '/spieler_select')},
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Tableau'),
            // onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            //onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}

/// Die Aktionen in der Tast-Liste
/// Hier ausgelagert.
List<Widget> getActions(BuildContext context) {
  List<Widget> widgetList = List<Widget>();

  widgetList.add(IconButton(
    icon: const Icon(Icons.add_alert),
    tooltip: 'Show Snackbar 1',
    onPressed: () {
      //   scaffoldKey.currentState.showSnackBar(snackBar);
    },
  ));

  widgetList.add(
    IconButton(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Setup Screens',
      onPressed: () {
        Navigator.pushNamed(context, '/spieler_import');
      },
    ),
  );
  return widgetList;
}

List<Widget> getActions2(BuildContext context) {
  var widgetList;
  widgetList = <Widget>[
    IconButton(
      icon: const Icon(Icons.add_alert),
      tooltip: 'Show Snackbar 2',
      onPressed: () {
//   scaffoldKey.currentState.showSnackBar(snackBar);
      },
    ),
    IconButton(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Next page 2',
      onPressed: () {
        openPage(context);
      },
    ),
  ];
  return widgetList;
}

/// Eine neue Seite öffnen,
/// diese ist mit der Hauptseite verbunden
void openPage(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(
    builder: (BuildContext context) {
      return SpielerImport();
    },
  ));
}

/// Die zweite Page
Scaffold getPage2() {
  return new Scaffold(
    appBar: AppBar(
      title: const Text('Next page'),
    ),
    body: const Center(
      child: Text(
        'This is Page 2',
        style: TextStyle(fontSize: 24),
      ),
    ),
  );
}
