import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'file:///D:/Daten/Flutter/abwesend/lib/model/spieler.dart';
import 'package:abwesend/pages/spieler_import.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

/// Der Hauptscreen
class _HomeState extends State<Home> {
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
              Navigator.pushNamed(context, '/loading');
            },
          ),
        ],
      ),
      //getActions(context)

      drawer: AbwMenu(),
      //    body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Spieler').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Spieler.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(record.name),
            trailing: Text(record.vorname),
            //           onTap: (), // Detail von Spieler anzeigen
          )),
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
            onTap: () => {
              Navigator.pushNamed(context, '/spieler_select')
            },
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
      SpielerImport();
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
