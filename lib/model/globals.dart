library my_pri.globals;

import 'package:intl/intl.dart';

// das Datenformat in der DB
final DateFormat dateFormDb = new DateFormat('yyyy-MM-dd');

// der Name der DB
String dbname = "tennis2";
// Die Werte der Config
Map<String, dynamic> configData;
// Start- und Edd-Datum des Turniers
DateTime startDatum;
DateTime endDatum;
// ab diesem Datum anzeigen
DateTime startDatumAnzeigen;
// die Länge des Arrays für alle Tage
int arrayLen = 0;
// die selektierte TableauId im Tableau-Screen
// Ersatz für modale transformation, da im build zu spät
int tableauId = -1;


