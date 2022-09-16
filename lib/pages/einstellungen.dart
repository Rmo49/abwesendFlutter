import 'package:abwesend/model/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:abwesend/model/globals.dart' as global;

import 'package:intl/intl.dart';

class Einstellungen extends StatefulWidget {
  const Einstellungen({Key? key}) : super(key: key);

  @override
  EinstellungenState createState() => EinstellungenState();
}

class EinstellungenState extends State<Einstellungen> {
  final DateFormat _dateLong = DateFormat('d.M.yyyy');
  final DateFormat _dateShort = DateFormat('d.M.');
  String _abDatum = "xx";

  @override
  void initState() {
    super.initState();
    _abDatum = _dateLong.format(global.startDatumAnzeigen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Column(children: <Widget>[
        _showStartDatum(),
        const Text(' '),
        Container(
          color: Colors.orange[300],
          width: 300,
          child: CheckboxListTile(
            title: const Text(
              'nur Grafik anzeigen',
              style: TextStyle(fontSize: 20.0),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            value: global.nurGrafik,
            onChanged: (bool? value) {
              setState(() {
                global.nurGrafik = value;
              });
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
        ),
      ]),
    );
  }

  /// Die Wahl des Startdatums
  Widget _showStartDatum() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(' '),
          const Text(
            'Anzeige',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ButtonBar(
              mainAxisSize: MainAxisSize
                  .min, // this will take space as minimum as posible(to center)
              buttonHeight: 25.0,
              buttonPadding: const EdgeInsets.all(2.0),
              children: _getDatumButtons(),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ab Datum: ', style: TextStyle(fontSize: 18.0)),
              Text(_abDatum, style: const TextStyle(fontSize: 18.0)),
            ],
          ),
        ]);
  }

  /// Die Liste mit allen möglichen Datum
  List<Widget> _getDatumButtons() {
    List<GestureDetector> list = [];
    DateTime datum = global.startDatum;
    while (datum.compareTo(global.endDatum) < 0) {
      DateTime datumButton = datum;
      list.add(
        GestureDetector(
          child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.orange,
              child: Text(
                _dateShort.format(datumButton),
                style: const TextStyle(fontSize: 16),
              )),
          onTap: () {
            _getSelectedDatum(datumButton);
          },
        ),
      );
      datum = datum.add(const Duration(days: 2));
    }
    return list;
  }

  void _getSelectedDatum(DateTime datumVon) {
    Duration duration = datumVon.difference(global.startDatum);
    global.arrayStart = duration.inDays;
    setState(() {
      _abDatum = _dateLong.format(datumVon);
    });
    LocalStorage localStorage = LocalStorage();
    localStorage.showAbDatum = global.dateFormDb.format(datumVon);
    localStorage.saveLocalData();
    global.startDatumAnzeigen = datumVon;
  }
}
