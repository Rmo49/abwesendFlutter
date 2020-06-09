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
  List abwesendList;
  int abwListLength;
  DateTime startDatum;

  // Konstruktor
  AbwesendTable({this.spieler});

  @override
  Widget build(BuildContext context) {
    if (spieler == null) {
      return Container(
        child: Text("Daten werden geladen"),
      );
    }
    abwesendList = spieler.abwesend.split(';');
    abwListLength = abwesendList.length;

    startDatum = dateFormDb.parse(spieler.begin);
    return Column(
      children: <Widget>[
        Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FractionColumnWidth(.2),
            1: FractionColumnWidth(.1),
            2: FixedColumnWidth(40.0),
          },
          children: getRows(),
//          TableRow(children: listValues = getColValue()),
//          TableRow(children: listPaint = getColPaint()),
        ),
      ],
    );
  }

  List<TableRow> getRows() {
    bool isWeekend = false;
    List<TableRow> list = new List<TableRow>();
    for (int i = 0; i < abwListLength; i++) {
      isWeekend = (startDatum.weekday >= 6);
      String abwTag = abwesendList[i];
      double posStart = getPosStart(abwTag, isWeekend);
      double posEnd = getPosEnd(abwTag, isWeekend, posStart);

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
            child: CustomPaint(painter: MyPainter(posStart, posEnd)),
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
    String zahl = abwTag.substring(0, abwTag.indexOf('-'));
    if (zahl.length > 0) {
      int start = int.parse(zahl);
      if (isWeekend) {
        double relativ = (weekendEnd - start) / (weekendEnd - weekendBegin);
        return relativ;
      } else {
        double relativ = (weekEnd - start) / (weekEnd - weekBegin);
        return 1-relativ;
      }
    }
    return 1;
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
      String zahl = abwTag.substring(abwTag.indexOf('-')+1, abwTag.length);
      if (zahl.length > 0) {
        int end = int.parse(zahl);
        if (isWeekend) {
          double relativ = (end - weekendBegin) / (weekendEnd - weekendBegin);
          return relativ;
        } else {
          double relativ = (end - weekBegin) / (weekEnd - weekBegin);
          return relativ;
        }
      }
    }
    return 1.0;
  }
}

class MyPainter extends CustomPainter {
  final double posStart;
  final double posEnd;
  // Konstruktor
  MyPainter(this.posStart, this.posEnd);

  final painter = Paint()..color = Colors.deepOrangeAccent;

  @override
  void paint(Canvas canvas, Size size) {
    if (posStart < 1) {
      double left = posStart * size.width;
      double width = (posEnd * size.width) - left;
      canvas.drawRect(Rect.fromLTWH(left, 0.0, width, size.height), painter);
    }
    canvas.drawRect(Rect.fromLTWH(20, 0.0, 5, size.height), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
