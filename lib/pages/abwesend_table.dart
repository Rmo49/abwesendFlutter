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

//    List<TableRow> listRow = [];

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
      String value = abwesendList[i];
      list.add(
        TableRow(children: [
          TableCell(
              child: Container(
            child: Text(dateFormDb.format(startDatum)),
                color: isWeekend ? Colors.grey : Colors.white,
          )),
          TableCell(child: Text('$value')),
          TableCell(
              child: Container(
            height: 20.0,
//                color: Colors.yellow,
            child: CustomPaint(painter: MyPainter()),
//                child: FittedBox(
//                  fit: BoxFit.contain,
//                  child: CustomPaint(painter: MyPainter()),
//                )),
          )),
        ]),
      );
      startDatum = startDatum.add(Duration(days: 1));
    }
    return list;
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define a paint object
//    final paint = Paint()
//      ..style = PaintingStyle.stroke
//      ..strokeWidth = 1.0
//      ..color = Colors.indigo;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, 10.0, 10.0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
