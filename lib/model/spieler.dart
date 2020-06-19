import 'package:cloud_firestore/cloud_firestore.dart';

class Spieler {
  int id;
  final String name;
  final String vorname;
  String email;
  String abwesend;
  String begin; // Begin datum des Truniers
  List<Match> matches;

  Spieler(this.name, this.vorname, this.email);

  Spieler.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        assert(map['vorname'] != null),
        id = int.parse(map['id']),
        name = map['name'],
        vorname = map['vorname'],
        email = map['email'],
        abwesend = map['abwesendArray'],
        begin = map['begin'];

  setMatches(List<dynamic> matchList) {
    matches = new List<Match>();
    matchList.forEach((element) {
      Match match = Match.fromMap(element);
      matches.add(match);
    });
  }

  Spieler.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

  Map<String, dynamic> toJson() =>
      {"name": name, "vorname": vorname, "email": email};

  @override
  String toString() => "Spieler <$name: $vorname>";
}

/// Spieler kurzform, um in einer Liste anzuzeigen
class SpielerShort {
  final String id;
  final String names;
  bool isSelected;

  SpielerShort(this.id, this.names, this.isSelected);

  SpielerShort.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        names = map['names'],
        isSelected = false;
}

/// Attribute von einem Match
class Match {
  final int day;
  final String time;
  final String type;

  Match(this.day, this.time, this.type);

  Match.fromMap(Map<String, dynamic> map)
      : day = int.parse(map['day']),
        time = map['time'],
        type = map['type'];
}

/// Attribute von einem Match zur Darstellung
class MatchDisplay {
  final double pos;
  final String type;

  MatchDisplay(this.pos, this.type);

  MatchDisplay.fromMap(Map<String, dynamic> map)
      : pos = double.parse(map['pos']),
        type = map['type'];
}
