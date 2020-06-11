import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:abwesend/model/spieler.dart';

class AbwesendTable extends StatelessWidget {
//  Intl.defaultLocal = 'de_DE';
  final DateFormat dateFormDb = new DateFormat('yyyy-MM-dd');
  final int weekBegin = 17;
  final int weekEnd = 22;
  final int weekendBegin = 10;
  final int weekendEnd = 17;

  final Spieler spieler;
//  List abwesendList;
//  List<Match> matchList;
//  DateTime startDatum;

  // Konstruktor
  AbwesendTable({this.spieler});

  @override
  Widget build(BuildContext context) {
    if (spieler == null) {
      return Container(
        child: Text("lese Spieler von DB"),
      );
    }

//    var abwL = <TableRow>[];
    return Column(
      children: <Widget>[
        Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FractionColumnWidth(.2),
            1: FractionColumnWidth(.1),
            2: FixedColumnWidth(40.0),
          },
          children: getAbwesendRows(spieler),
//        <TableRow>[
//          TableRow(children: []),
//          abw,
//          TableRow(children: []),
        ),
      ],
    );
  }

  TableRow getRows() {
    return new TableRow(children: []);
  }

  /// Die Zeilen mit den Abwesenheiten
  List<TableRow> getAbwesendRows(Spieler spieler) {
    // die lokale Vars
    List abwesendList = spieler.abwesend.split(';');
    DateTime startDatum = dateFormDb.parse(spieler.begin);

    bool isWeekend = false;
    List<TableRow> list = new List<TableRow>();
    // das ist der Header
    list.add(
      TableRow(children: [
        TableCell(
          child: Text('Datum'),
        ),
        TableCell(
          child: Text(spieler.name,
          ),
        ),
        TableCell(
          child: Text(spieler.vorname),
        ),
      ]),
    );
    // iteration ueber alle Tage
    for (int i = 0; i < abwesendList.length; i++) {
      // die Werte für diesen Tag
      isWeekend = (startDatum.weekday >= 6);
      // abwesend
      String abwTag = abwesendList[i];
      double abwStart = getPosStart(abwTag, isWeekend);
      double abwEnd = getPosEnd(abwTag, isWeekend, abwStart);
      // matches, wenn von diesem Tag
      List<MatchDisplay> matchDisplayList = getMatches(i, isWeekend);
      list.add(
        TableRow(children: [
          TableCell(
              child: Container(
            child: Text(dateFormDb.format(startDatum)),
            color: isWeekend ? Colors.grey : Colors.white,
          )),
          TableCell(child: Text('$abwTag')),
          TableCell(
              child: Container(
            height: 20.0,
            child: CustomPaint(
                painter: MyPainter(abwStart, abwEnd, matchDisplayList)),
          )),
        ]),
      );
      startDatum = startDatum.add(Duration(days: 1));
    }
    return list;
  }

  /// Berechnet die Start Position, 0..1 innerhalb der Zeitspannen
  /// von Start-Zeit und Ende
  double getPosStart(String abwTag, bool isWeekend) {
    if ((abwTag == null) || (abwTag.length <= 0)) {
      // nichts zeichnen
      return 1;
    }
    if (abwTag.startsWith('-') || (abwTag.compareTo('0') == 0)) {
      return 0;
    }
    String zeit = abwTag.substring(0, abwTag.indexOf('-'));
    if (zeit.length > 0) {
      return getPosTime(zeit, isWeekend);
    }
    return 1.0;
  }

  /// Berechnet die Start Position, von 0..1 innerhalb der Zeitspannen
  /// von Start-Zeit und Ende
  double getPosEnd(String abwTag, bool isWeekend, double posStart) {
    if (posStart >= 1) {
      // nichts zeichnen
      return 1;
    }
    if (abwTag.compareTo('0') == 0) {
      return 1;
    }
    if (abwTag.startsWith('-')) {
      String zeit = abwTag.substring(abwTag.indexOf('-') + 1, abwTag.length);
      if (zeit.length > 0) {
        return getPosTime(zeit, isWeekend);
      }
    }
    return 1.0;
  }

  /// Die Position von 0..1 innerhalb der Zeitspannen
  /// wenn 1 dann ausserhalb der Zeitspanne
  double getPosTime(String time, bool isWeekend) {
    // wenn Zeit 18:30, dann minuten weglassen
    int index = time.indexOf(':');
    if (index > 0) {
      time = time.substring(0, index);
    }
    index = time.indexOf('.');
    if (index > 0) {
      time = time.substring(0, index);
    }

    double pos = 1.0;
    int zeit = int.parse(time);
    if (isWeekend) {
      pos = (zeit - weekendBegin) / (weekendEnd - weekendBegin);
    } else {
      pos = (zeit - weekBegin) / (weekEnd - weekBegin);
    }
    return pos;
  }

  List<MatchDisplay> getMatches(int day, bool isWeekend) {
    List<MatchDisplay> matchDispalyList = new List<MatchDisplay>();
    for (int i = 0; i < spieler.matches.length; i++) {
      MatchDisplay matchDisplay;
      getPosTime(spieler.matches[i].time, isWeekend);

      if (spieler.matches[i].day == day) {
        matchDisplay = MatchDisplay(
            getPosTime(spieler.matches[i].time, isWeekend),
            spieler.matches[i].type);
        matchDispalyList.add(matchDisplay);
      }
    }
    return matchDispalyList;
  }
}

/// Der Painter für die grafische Dartstellung
class MyPainter extends CustomPainter {
  final double posStart;
  final double posEnd;
  final List<MatchDisplay> matchDisplayList;
  // Konstruktor
  MyPainter(this.posStart, this.posEnd, this.matchDisplayList);

  final painterAbw = Paint()..color = Colors.deepOrangeAccent;
  final painterEinzel = Paint()..color = Colors.blue[700];
  final painterDoppel = Paint()..color = Colors.green[700];

  @override
  void paint(Canvas canvas, Size size) {
    if (posStart < 1) {
      double left = posStart * size.width;
      double width = (posEnd * size.width) - left;
      canvas.drawRect(Rect.fromLTWH(left, 0.0, width, size.height), painterAbw);
    }
    if (matchDisplayList != null) {
      matchDisplayList.forEach((match) {
        if (match.pos < 1) {
          double left = match.pos * size.width;
          if (match.type.contains('E')) {
            canvas.drawRect(
                Rect.fromLTWH(left, 0.0, 8, size.height), painterEinzel);
          } else {
            canvas.drawRect(
                Rect.fromLTWH(left, 0.0, 8, size.height), painterDoppel);
          }
        }
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
