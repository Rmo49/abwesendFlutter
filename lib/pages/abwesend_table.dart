import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:abwesend/model/spieler.dart';
import 'package:abwesend/model/globals.dart' as global;

/// zeigt die Tabelle Abwesend aller Spieler
class AbwesendTable extends StatelessWidget {
//  Intl.defaultLocal = 'de_DE';
  final double sizeName = 65.0;
  final DateFormat dateFormList = new DateFormat('d.M.');
  final BorderSide borderSide = BorderSide(color: Colors.blueGrey, width: 1.0, style: BorderStyle.solid);

//  final Spieler spieler;
  final List<Spieler> spielerList;

  // Konstruktor
  AbwesendTable({this.spielerList});

  @override
  Widget build(BuildContext context) {
//    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: getTableList(),
      ),
    );
  }

  /// alle Zeilen der Tabelle anzeigen, iteration über alle Spieler
  List<Table> getTableList() {
    List<Table> tableList = new List<Table>();
    tableList.add(getTableDatum());
    // iteration über alle Spieler
    spielerList.forEach((element) {
      tableList.add(getTableSpieler(element));
    });
    return tableList;
  }


  /// Tabelle mit Datum
  Table getTableDatum() {
    List<TableRow> rowList = new List<TableRow>();
    rowList.add(getRowDatum('', global.startDatumAnzeigen));

    return Table(
      border: TableBorder(bottom: borderSide, verticalInside: borderSide),
      defaultColumnWidth: FixedColumnWidth(40.0),
      columnWidths: {
        0: FixedColumnWidth(sizeName),
      },
      children: rowList,
    );
  }

  /// Zeile Datum
  TableRow getRowDatum(String header, DateTime startDatum) {
    return TableRow(children: getCellsDatum(header, startDatum));
  }

  List<TableCell> getCellsDatum(String header, DateTime startDatum) {
    // Die Zeile mit dem Datum
    DateTime datum = startDatum;
    List<TableCell> list = new List<TableCell>();
    list.add(TableCell(child: Text(header)));

    for (int i = global.arrayStart; i < global.arrayLen; i++) {
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

  /// Die Tabelle eines Spielers
  Table getTableSpieler(Spieler spieler) {
    List abwesendList = spieler.abwesend.split(';');
    List<TableRow> rowList = new List<TableRow>();
    if (!global.nurGrafik) {
      rowList.add(getRowAbwesend(spieler.vorname, abwesendList));
    }
    rowList.add(getRowGrafik(spieler, abwesendList));

    return Table(
      border: TableBorder(bottom: borderSide, verticalInside: borderSide),
      defaultColumnWidth: FixedColumnWidth(40.0),
      columnWidths: {
        0: FixedColumnWidth(sizeName),
      },
      children: rowList,
    );
  }

  /// Row mit den Abwesenheiten eines Spielers
  TableRow getRowAbwesend(String header, List abwesendList) {
    return TableRow(children: getCellAbwesend(header, abwesendList));
  }

  List<TableCell> getCellAbwesend(String header, List abwesendList) {
    List<TableCell> list = new List<TableCell>();
    list.add(TableCell(child: Text(header, overflow: TextOverflow.ellipsis,)));
    for (int i = global.arrayStart; i < global.arrayLen; i++) {
      if (i < abwesendList.length) {
        list.add(
          TableCell(child: Text(abwesendList[i])),
        );
      }
    }
    return list;
  }

  /// Row mit den Abwesenheiten eines Spielers
  TableRow getRowGrafik(Spieler spieler, List abwesendList) {
    return TableRow(children: getCellGrafik(spieler, abwesendList));
  }

  List<TableCell> getCellGrafik(Spieler spieler, List abwesendList) {
    List<TableCell> list = new List<TableCell>();
    list.add(TableCell(child: Text(spieler.name, overflow: TextOverflow.ellipsis,)));
    for (int i = global.arrayStart; i < global.arrayLen; i++) {
      if (i < abwesendList.length) {
        String abwTag = abwesendList[i];
        double abwStart = getPosStart(abwTag, isWeekend(i));
        double abwEnd = getPosEnd(abwTag, isWeekend(i), abwStart);
        // matches, wenn von diesem Tag
        List<MatchDisplay> matchDisplayList = getMatches(spieler, i);
        MyPainter painter = MyPainter(abwStart, abwEnd, matchDisplayList);
        list.add(
          TableCell(
              child: Container(
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
    List<MatchDisplay> matchDispalyList = new List<MatchDisplay>();
    for (int i = 0; i < spieler.matches.length; i++) {
      MatchDisplay matchDisplay;
      // wenn Spiele an diesem Tag
      if (spieler.matches.elementAt(i).day == day) {
        double pos = getPosTime(spieler.matches[i].time, isWeekend(day));
        if (pos >= 0.8) {
          pos = 0.8;
          }
         matchDisplay = MatchDisplay(
            pos,
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
    int posEnd = abwTag.indexOf('-');
    if (posEnd > 0) {
      String zeit = abwTag.substring(0, posEnd);
      if (zeit.length > 0) {
        return getPosTime(zeit, isWeekend);
      }
    }
    else {
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
      pos = (zeit - global.zeitWeekendBegin) / (global.zeitWeekendEnd - global.zeitWeekendBegin);
    } else {
      pos = (zeit - global.zeitWeekBegin) / (global.zeitWeekEnd - global.zeitWeekBegin);
    }
    if (pos < 0) {
      pos = 0.0;
    }
    return pos;
  }

  /// Ist die Position im Array ein Weekend?
  bool isWeekend(int pos) {
    DateTime datum = global.startDatum;
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
