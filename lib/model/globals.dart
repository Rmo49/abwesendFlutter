library my_pri.globals;
import 'package:intl/intl.dart';

// das Datenformat in der DB
final DateFormat dateFormDb = new DateFormat('yyyy-MM-dd');

// der Name des Benutzers
String userName;
// der Name der DB, wird von login gelesen
String dbName;
// der DB-User, muss bei der DB gesetzt sein
String dbUser;
// das DB-Passwort ist immer gleich
String dbPass;
// Das Schema für Web (http / https)
String scheme;
// Der Host-name für Web
String host;
// Der Pfad, der erweitert wird
String path;
// Start- und Edd-Datum des Turniers
DateTime startDatum;
DateTime endDatum;
// ab diesem Datum anzeigen
DateTime abDatumAnzeigen;
// ab dieser Position anzeigen
int arrayStart = 0;
// die max. Länge des Arrays für alle Tage
int arrayLen = 0;
// die selektierte TableauId im Tableau-Screen
// Ersatz für modale transformation, da im build zu spät
int tableauID = -1;
// Die Liste der Spieler für die Anzeige der Abwesenheiten
List<int> spielerIdList = [];
// wenn nur die Grafik in der Abwesend-Tabelle angezeigt werden soll
bool nurGrafik = false;
// Anfang und End-Zeiten für die Anzeige
double zeitWeekBegin = 17.0;
double zeitWeekEnd = 22.0;
double zeitWeekendBegin = 10.0;
double zeitWeekendEnd = 17.0;

