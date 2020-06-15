import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;

class AbwesendTable extends StatelessWidget {
//  Intl.defaultLocal = 'de_DE';
  final DateFormat dateFormList = new DateFormat('d.M.');

  final int weekBegin = 17;
  final int weekEnd = 22;
  final int weekendBegin = 10;
  final int weekendEnd = 17;

  final Spieler spieler;

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(),
        defaultColumnWidth: FixedColumnWidth(40.0),
        columnWidths: {
          0: FixedColumnWidth(60.0),
        },
        children: getSpielerRows(spieler),
      ),
    );
  }

  /// Die Zeilen mit allen Abwesenheiten eines Spielers
  List<TableRow> getSpielerRows(Spieler spieler) {
    // die lokale Vars
    List abwesendList = spieler.abwesend.split(';');
    if (abwesendList.length < global.arrayLen) {
      global.arrayLen = abwesendList.length;
    }

    List<TableRow> rowList = new List<TableRow>();
    // die einzelnen Rows
    rowList.add(getRowDatum('Datum', global.startDatum));
    rowList.add(getRowAbwesend(spieler.vorname, abwesendList));
    rowList.add(getRowGrafik(spieler.name, abwesendList));
    return rowList;
  }

  /// Zeile Datum
  TableRow getRowDatum(String header, DateTime startDatum) {
    return TableRow(children: getCellDatum(header, startDatum));
  }

  List<TableCell> getCellDatum(String header, DateTime startDatum) {
    // Die Zeile mit dem Datum
    DateTime datum = startDatum;
    List<TableCell> list = new List<TableCell>();
    list.add(TableCell(child: Text(header)));

    for (int i = 0; i < global.arrayLen; i++) {
      list.add(
        TableCell(
            child: Container(
          child: Text(dateFormList.format(datum)),
          color: isWeekend(i) ? Colors.grey : Colors.white,
        )),
      );
      datum = datum.add(Duration(days: 1));
    }
    return list;
  }

  /// Row mit den Abwesenheiten eines Spielers
  TableRow getRowAbwesend(String header, List abwesendList) {
    return TableRow(children: getCellAbwesend(header, abwesendList));
  }

  List<TableCell> getCellAbwesend(String header, List abwesendList) {
    List<TableCell> list = new List<TableCell>();
    list.add(TableCell(child: Text(header)));
    for (int i = 0; i < global.arrayLen; i++) {
      list.add(
        TableCell(child: Text(abwesendList[i])),
      );
    }
    return list;
  }

  /// Row mit den Abwesenheiten eines Spielers
  TableRow getRowGrafik(String header, List abwesendList) {
    return TableRow(children: getCellGrafik(header, abwesendList));
  }

  List<TableCell> getCellGrafik(String header, List abwesendList) {
    List<TableCell> list = new List<TableCell>();
    list.add(TableCell(child: Text(header)));
    for (int i = 0; i < global.arrayLen; i++) {
      String abwTag = abwesendList[i];
      double abwStart = getPosStart(abwTag, isWeekend(i));
      double abwEnd = getPosEnd(abwTag, isWeekend(i), abwStart);
      // matches, wenn von diesem Tag
      List<MatchDisplay> matchDisplayList = getMatches(i);
      MyPainter painter = MyPainter(abwStart, abwEnd, matchDisplayList);
      list.add(
        TableCell(
            child: Container(
          height: 20.0,
          child: CustomPaint(painter: painter),
        )),
      );
    }
    return list;
  }

  /// Gibt für einen Tag in der Liste die Matches zurück
  List<MatchDisplay> getMatches(int day) {
    List<MatchDisplay> matchDispalyList = new List<MatchDisplay>();
    for (int i = 0; i < spieler.matches.length; i++) {
      MatchDisplay matchDisplay;
      // wenn Spiele an diesem Tag
      if (spieler.matches[i].day == day) {
        matchDisplay = MatchDisplay(
            getPosTime(spieler.matches[i].time, isWeekend(i)),
            spieler.matches[i].type);
        matchDispalyList.add(matchDisplay);
      }
    }
    return matchDispalyList;
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

  /// Ist die Position im Array ein Weekend?
  bool isWeekend(int pos) {
    DateTime datum = global.startDatum;
    datum =  global.startDatum.add(Duration(days: pos));
//    for (int i = 0; i < global.arrayLen; i++) {
      return (datum.weekday >= 6);
 //   }
  }
}

//-------------------------
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
