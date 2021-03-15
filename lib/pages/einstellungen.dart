import 'package:flutter/material.dart';
import 'package:abwesend/model/globals.dart' as global;

import 'package:intl/intl.dart';

class Einstellungen extends StatefulWidget {
  @override
  _EinstellungenState createState() => _EinstellungenState();
}

class _EinstellungenState extends State<Einstellungen> {
  final DateFormat _dateLong = new DateFormat('d.M.yyyy');
  final DateFormat _dateShort = new DateFormat('d.M.');

  TextEditingController _txtStartDatum = TextEditingController();

  @override
  void initState() {
    super.initState();
    _txtStartDatum.text = _dateLong.format(global.startDatum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: Column(children: <Widget>[
        _showStartDatum(),
        Text(' '),
        Container(
          color: Colors.orange[300],
          child: CheckboxListTile(
            title: Text(
              'nur Grafik anzeigen',
              style: TextStyle(fontSize: 20.0),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            value: global.nurGrafik,
            onChanged: (bool value) {
              setState(() {
                global.nurGrafik = value;
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30),
        ),
      ]),
    );
  }

  /// Die Wahl des Startdatums
  Widget _showStartDatum() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(' '),
          Text(
            'Anzeige',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ButtonBar(
              mainAxisSize: MainAxisSize
                  .min, // this will take space as minimum as posible(to center)
              buttonHeight: 25.0,
              buttonPadding: EdgeInsets.all(2.0),
              children: _getDatumButtons(),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ab Datum: ', style: TextStyle(fontSize: 18.0)),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _txtStartDatum,
                  maxLines: 1,
                  readOnly: true,
                ),
              ),
            ],
          ),
        ]);
  }

  /// Die Liste mit allen möglichen Datum
  List<Widget> _getDatumButtons() {
    List<RaisedButton> list = new List<RaisedButton>();
    DateTime datum = global.startDatum;
    while (datum.compareTo(global.endDatum) < 0) {
      DateTime datumButton = datum;
      list.add(
        new RaisedButton(
          color: Colors.orange[400],
          padding: const EdgeInsets.all(0.0),
          child: Text(_dateShort.format(datumButton)),
          onPressed: () {
            _getSelectedDatum(datumButton);
          },
          highlightColor: Colors.orange[900],
        ),
      );
      datum = datum.add(Duration(days: 2));
    }
    return list;
  }

  void _getSelectedDatum(DateTime datumVon) {
    Duration duration = datumVon.difference(global.startDatum);
    global.arrayStart = duration.inDays;
    setState(() {
      _txtStartDatum.text = _dateLong.format(datumVon);
    });
  }
}
