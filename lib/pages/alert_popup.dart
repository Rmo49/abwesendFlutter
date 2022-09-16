import 'package:flutter/material.dart';

/// Anzeige von Meldungen
class AlertPopup {
  late String _title;
  TextEditingController? _textContr;
  int zeilen = 1;

  late BuildContext _context;

  AlertPopup(String title, String meldung, BuildContext context) {
    _title = title;
    _textContr = TextEditingController();
    _textContr!.text = meldung;
    _context = context;
    double len = meldung.length / 20;
    zeilen = len.round();
    if (zeilen > 6) {
      zeilen = 6;
    }
  }

  Future<void> showMyDialog() async {
      return showDialog<void>(
        context: _context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(_title),
            content: SingleChildScrollView(
              child: TextField(
                controller: _textContr,
                maxLines: zeilen,
                enabled: false,
              ),
            ),

            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


}