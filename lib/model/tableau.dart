class Tableau {
  int id;
  final String bezeichnung;
  final String position;

  Tableau(this.id, this.bezeichnung, this.position);

  Tableau.fromMap(Map<String, dynamic> map)
      : id = int.parse(map['id']),
        bezeichnung = map['bezeichnung'],
        position = map['position'];

}