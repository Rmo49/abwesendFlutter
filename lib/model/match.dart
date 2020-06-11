/// Alle Matches eines Spielers
class Matches {
  List<Match2> matches = null;

  Matches.fromList(List<dynamic> matchList) {
      matches = new List<Match2>();
      matchList.forEach((element) {
        Match2 match = Match2.fromMap(element);
        matches.add(match);
      });
    }
  }

/// Attribute von einem Match
class Match2 {
  final int day;
  final String time;
  final String type;

  Match2(this.day, this.time, this.type);

  Match2.fromMap(Map<String, dynamic> map)
      : day = int.parse(map['day']),
        time = map['time'],
        type = map['type'];
}
