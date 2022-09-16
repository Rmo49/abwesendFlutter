import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;

/// zeigt die Tabelle Abwesend aller Spieler
class AbwesendTable extends StatelessWidget {

  final double sizeName = 65.0;
  final double sizeDay = 40.0;
//  double screenWidth = 500;
//  int displayDays = 10;
  final DateFormat dateFormList = DateFormat('d.M.');
  final BorderSide borderSide =
      const BorderSide(color: Colors.blueGrey, width: 1.0, style: BorderStyle.solid);

//  final Spieler spieler;
  final List<Spieler?>? spielerList;

  // Konstruktor
  AbwesendTable({Key? key, this.spielerList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // die Weite des screen bestimmen
    double screenWidth = MediaQuery.of(context).size.width;
    _calculateRows(screenWidth);
    return Column(
      children: getTableList(context),
    );
  }

  /// die Anzahl Spalten berechnen
  void _calculateRows(double screenWidth) {
    double rows = (screenWidth - sizeName) / sizeDay;
    int displayDays = rows.toInt();
    displayDays--;
    if (displayDays > global.arrayLenMax) {
      displayDays = global.arrayLenMax;
    }
    global.arrayEnd = global.arrayStart + displayDays;
    Duration diff = global.endDatum.difference(global.startDatumAnzeigen);
    // wenn das Ende der Anzeige erreicht ist
    int daysMax = diff.inDays + 1;
    if (daysMax < displayDays) {
      global.arrayEnd = global.arrayStart + daysMax;
    }
  }

  /// alle Zeilen der Tabelle anzeigen, iteration über alle Spieler
  List<Table> getTableList(BuildContext context) {
    List<Table> tableList = [];
    // die Zeile mit dem Datum
    tableList.add(getTableDatum(context));

    // iteration über alle Spieler
    for (var element in spielerList!) {
      tableList.add(getTableSpieler(context, element!));
    }
    return tableList;
  }

  /// Tabelle mit Datum
  Table getTableDatum(BuildContext context) {
    List<TableRow> rowList = [];
    rowList.add(getRowDatum(context, '', global.startDatumAnzeigen));

    return Table(
      border: TableBorder(bottom: borderSide, verticalInside: borderSide),
      defaultColumnWidth: FixedColumnWidth(sizeDay),
      columnWidths: {
        0: FixedColumnWidth(sizeName),
      },
      children: rowList,
    );
  }

  /// Zeile Datum
  TableRow getRowDatum(BuildContext context, String header, DateTime? startDatum) {
    return TableRow(children: getCellsDatum(context, header, startDatum));
  }

  /// alle Zellen mit einem Datum
  List<TableCell> getCellsDatum(BuildContext context, String header, DateTime? startDatum) {
    // Die Zeile mit dem Datum
    DateTime? datum = startDatum;
    List<TableCell> list = [];
    list.add(TableCell(child: Text(header)));

    for (int i = global.arrayStart; i < global.arrayEnd; i++) {
      list.add(
        TableCell(
            child: Container(
          color: isWeekend(i) ? Colors.lightBlueAccent : Colors.white,
          child: Text(dateFormList.format(datum!),
              style: Theme.of(context).textTheme.labelLarge),
        )),
      );
      datum = datum.add(const Duration(days: 1));
    }
    return list;
  }

  /// Die Tabelle eines Spielers
  Table getTableSpieler(BuildContext context, Spieler spieler) {
    List abwesendList = spieler.abwesendStr!.split(';');
    List<TableRow> rowList = [];
    if (!global.nurGrafik!) {
      rowList.add(getRowAbwesend(context, spieler.vorname!, abwesendList));
    }
    rowList.add(getRowGrafik(context, spieler, abwesendList));

    return Table(
      border: TableBorder(bottom: borderSide, verticalInside: borderSide),
      defaultColumnWidth: FixedColumnWidth(sizeDay),
      columnWidths: {
        0: FixedColumnWidth(sizeName),
      },
      children: rowList,
    );
  }

  /// Row mit den Abwesenheiten eines Spielers
  TableRow getRowAbwesend(BuildContext context, String header, List abwesendList) {
    return TableRow(children: getCellAbwesend(context, header, abwesendList));
  }

  List<TableCell> getCellAbwesend(BuildContext context, String header, List abwesendList) {
    List<TableCell> list = [];
    list.add(TableCell(
        child: Text(
      header, style: Theme.of(context).textTheme.labelLarge,
      overflow: TextOverflow.ellipsis,
    )));
    // die Abwesenheiten in Textform anzeigen
    for (int i = global.arrayStart; i < global.arrayEnd; i++) {
      if (i < abwesendList.length) {
        list.add(
          TableCell(child: Text(abwesendList[i],
              style: Theme.of(context).textTheme.labelLarge),
    ),
        );
      }
    }
    return list;
  }

  /// Row mit den grafischer Darstellung der Abwesenheiten eines Spielers
  TableRow getRowGrafik(BuildContext context, Spieler spieler, List abwesendList) {
    return TableRow(children: getCellGrafik(context, spieler, abwesendList));
  }

  /// Die einzelne Zelle zeichnen
  List<TableCell> getCellGrafik(BuildContext context, Spieler spieler, List abwesendList) {
    List<TableCell> list = [];
    list.add(TableCell(
        child: Text(
      spieler.name!, style: Theme.of(context).textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
    )));
    for (int i = global.arrayStart; i < global.arrayEnd; i++) {
      if (i < abwesendList.length) {
        String abwTag = abwesendList[i];
        abwTag = abwTag.trim();
        double abwStart = getPosStart(abwTag, isWeekend(i));
        double abwEnd = getPosEnd(abwTag, isWeekend(i), abwStart);
        // matches, wenn von diesem Tag
        List<MatchDisplay> matchDisplayList = getMatches(spieler, i);
        MyPainter painter = MyPainter(abwStart, abwEnd, matchDisplayList);
        list.add(
          TableCell(
              child: SizedBox(
            height: 20.0,
            child: CustomPaint(painter: painter),
          )),
        );
      }
    }
    return list;
  }

  /// Gibt für einen Tag in der Liste die Matches zurück
  List<MatchDisplay> getMatches(Spieler spieler, int day) {
    List<MatchDisplay> matchDispalyList = [];
    for (int i = 0; i < spieler.matches.length; i++) {
      MatchDisplay matchDisplay;
      // wenn Spiele an diesem Tag
      if (spieler.matches.elementAt(i).day == day) {
        double pos = getPosTime(spieler.matches[i].time!, isWeekend(day));
        if (pos >= 0.8) {
          pos = 0.8;
        }
        matchDisplay = MatchDisplay(pos, spieler.matches[i].type);
        matchDispalyList.add(matchDisplay);
      }
    }
    return matchDispalyList;
  }

  /// Berechnet die Start Position, 0..1 innerhalb der Zeitspannen
  /// von Start-Zeit und Ende
  double getPosStart(String abwTag, bool isWeekend) {
    if (abwTag.isEmpty) {
      // nichts zeichnen
      return 1;
    }
    if (abwTag.startsWith('-') || (abwTag.compareTo('0') == 0)) {
      return 0;
    }
    int posEnd = abwTag.indexOf('-');
    if (posEnd > 0) {
      String zeit = abwTag.substring(0, posEnd);
      if (zeit.isNotEmpty) {
        return getPosTime(zeit, isWeekend);
      }
    } else {
      // kein '-' gefunden
      return 0;
    }
    return 1.0;
  }

  /// Berechnet die End Position, von 0..1 innerhalb der Zeitspannen
  /// von Start-Zeit und Ende
  double getPosEnd(String abwTag, bool isWeekend, double posStart) {
    if (posStart >= 1) {
      // nichts zeichnen
      return 1.0;
    }
    if (abwTag.compareTo('0') == 0) {
      return 1.0;
    }
    if (abwTag.startsWith('-')) {
      String zeit = abwTag.substring(abwTag.indexOf('-') + 1, abwTag.length);
      if (zeit.isNotEmpty) {
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
      pos = (zeit - global.zeitWeekendBegin) /
          (global.zeitWeekendEnd - global.zeitWeekendBegin);
    } else {
      pos = (zeit - global.zeitWeekBegin) /
          (global.zeitWeekEnd - global.zeitWeekBegin);
    }
    if (pos < 0) {
      pos = 0.0;
    }
    return pos;
  }

  /// Ist die Position im Array ein Weekend?
  bool isWeekend(int pos) {
    DateTime? datum = global.startDatum;
    datum = global.startDatum.add(Duration(days: pos));
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

  final painterAbw = Paint()..color = global.colorAbw;
  final painterEinzel = Paint()..color = global.colorEinzel;
  final painterDoppel = Paint()..color = global.colorDoppel;

  @override
  void paint(Canvas canvas, Size size) {
    if (posStart < 1) {
      double left = posStart * size.width;
      double width = (posEnd * size.width) - left;
      canvas.drawRect(Rect.fromLTWH(left, 0.0, width, size.height), painterAbw);
    }
    if (matchDisplayList.isNotEmpty) {
      for (var match in matchDisplayList) {
        if (match.pos < 1) {
          double left = match.pos * size.width;
          if (match.type!.contains('E')) {
            canvas.drawRect(
                Rect.fromLTWH(left, 0.0, 8, size.height), painterEinzel);
          } else {
            canvas.drawRect(
                Rect.fromLTWH(left, 0.0, 8, size.height), painterDoppel);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
