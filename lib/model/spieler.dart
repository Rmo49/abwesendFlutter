import 'package:cloud_firestore/cloud_firestore.dart';

class Spieler {
  int id;
  final String name;
  final String vorname;
  String email;
  String abwesend;
  String begin; // Begin datum des Truniers

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

  Spieler.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

  Map<String, dynamic> toJson() =>
      {"name": name, "vorname": vorname, "email": email};

  @override
  String toString() => "Spieler <$name: $vorname>";

  void addAbwesend(String) {}
}

/// Spieler kurzform, um in einer Liste anzuzeigen
class SpielerShort {
  final String id;
  final String names;

  SpielerShort(this.id, this.names);

  SpielerShort.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        names = map['names'];
}
