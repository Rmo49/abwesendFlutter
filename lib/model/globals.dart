library my_pri.globals;

import 'package:intl/intl.dart';

// das Datenformat in der DB
final DateFormat dateFormDb = new DateFormat('yyyy-MM-dd');

// der Name der DB
String dbname = "tennis2";
// Die Werte der Config
Map<String, dynamic> configData;
// Start-Datum des Turniers
DateTime startDatum;
// die Länge des Arrays
int arrayLen = 0;


