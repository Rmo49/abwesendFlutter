library my_pri.globals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Der Titel, der angezeigt wird
const String titel = "TCA CM (1.24.0)";
// Werte initialisieren 0=Internet, 1=lokal
const int initWerte = 0;

// das Datenformat in der DB
final DateFormat dateFormDb = DateFormat('yyyy-MM-dd');
// das Datenformat in Anzeige
final DateFormat dateFormDisplay = DateFormat('d.M.yyyy');

final navigatorKey = GlobalKey<NavigatorState>();

// der Name des Benutzers
String userName = '';
// der Name der DB, wird von login gelesen
String? dbName;
// der DB-User, muss bei der DB gesetzt sein
String dbUser = 'phpuser';
// das DB-Passwort ist immer gleich
String? dbPass;
// Das Schema für Web (http / https)
String? scheme;
// Der Host-name für Web
String? host;
// Der Port für Web
int? port;
// Der Pfad, der erweitert wird
String? path;
// Start- und Edd-Datum des Turniers
DateTime startDatum = DateTime(2020,1,1);
late DateTime endDatum;
// ab diesem Datum anzeigen
DateTime startDatumAnzeigen = DateTime(2020,1,1);
// ab dieser Position anzeigen
int arrayStart = 0;
// die Max. Länge des Array für die Darstellung der Abwesenheit
const int arrayLenMaxAbsolut = 21;
// die Länge des Arrays (Anzahl cols) für ganze Periode
int arrayLenMax = arrayLenMaxAbsolut;
// die Länge des Arrays (Anzahl cols) für dei aktuelle display-Breite
int arrayEnd = 0;
// die selektierte TableauId im Tableau-Screen
// Ersatz für modale transformation, da im build zu spät
int tableauID = -1;
// Die Liste der Spieler für die Anzeige der Abwesenheiten
List<int> spielerIdList = [];
// die maximale Grösse der Liste der Abwesenheiten
int spielerListMax = 30;
// Berechtigung um Config-Daten zu ändern, Komma getrennt
String canChangeConfig = 'ruedi';
// wenn nur die Grafik in der Abwesend-Tabelle angezeigt werden soll
bool? nurGrafik = false;
// Anfang und End-Zeiten für die Anzeige
double zeitWeekBegin = 17.0;
double zeitWeekEnd = 22.0;
double zeitWeekendBegin = 10.0;
double zeitWeekendEnd = 17.0;
// die Farben bei der grafischen Anzeige
const Color colorAbw = Color(0xFFFF5722);
const Color colorEinzel = Color(0xFF046EF9);
const Color colorDoppel = Color(0xFF4CAF50);

