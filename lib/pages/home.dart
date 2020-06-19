import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final DateFormat dateFormShort = new DateFormat('d.M');
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

        drawer: SideMenu(),
        body: Container(
          child: Column(children: <Widget>[
            FlatButton(
              color: Colors.orange[500],
              textColor: Colors.white,
              padding: EdgeInsets.all(10.0),
              onPressed: () {
                global.tableauId = -1;
                Navigator.pushNamed(context, '/spieler_select', arguments: {
                'tableauId' : -1,
                });
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
                Navigator.pushNamed(context, '/tableau_select');
              },
              child: Row(children: <Widget>[
                Icon(Icons.people),
                Text(
                  '  Tableau wählen',
                  style: TextStyle(fontSize: 20.0),
                ),
              ]),
            ),
            getStartDatum(),
            Text(global.dbname),
          ]),
        ));
  }

  /// Die Wahl des Startdatums
  Widget getStartDatum() {
    return Column(children: <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Anzeige der Abwesenheiten ab: '),
          Text( dateForm.format(global.startDatumAnzeigen)),
        ],
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ButtonBar(
          mainAxisSize: MainAxisSize
              .min, // this will take space as minimum as posible(to center)
          buttonHeight: 25.0,
          buttonPadding: EdgeInsets.all(2.0),
          children: getDatumButtons(),
        ),
      )
    ]);
  }

  /// Die Liste mit allen möglichen Datum
  List<Widget> getDatumButtons() {
    List<RaisedButton> list = new List<RaisedButton>();
    DateTime datum = global.startDatum;
    while (datum.compareTo(global.endDatum) < 0) {
      DateTime datumButton = datum;
      list.add(
        new RaisedButton(
          color: Colors.orange[400],
          padding: const EdgeInsets.all(0.0),
          child: Text(dateFormShort.format(datumButton)),
          onPressed: () {
            getSelectedDatum(datumButton);
          },
          highlightColor: Colors.orange[900],
        ),
      );
      datum = datum.add(Duration(days: 2));
    }
    return list;
  }

  void getSelectedDatum(DateTime datum) {
    global.startDatumAnzeigen = datum;
    Duration duration = datum.difference(global.startDatum);
    global.arrayStart = duration.inDays;
    setState(() {
    });
  }

}

/// Das Menu links mit der Haupt-Navigation
class SideMenu extends StatelessWidget {
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
