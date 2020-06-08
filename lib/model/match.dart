/// Alle Matches eines Spielers
class Matches {
  List<Match> matches;

  Matches.fromList(List<dynamic> matchList) {
    if (matchList.length > 0) {
      matches = new List<Match>();
      matchList.forEach((element) {
        Match match = Match.fromMap(element);
        matches.add(match);
      });
    }
  }
}

/// Attribute von einem Match
class Match {
  final String time;
  final String type;

  Match(this.time, this.type);

  Match.fromMap(Map<String, dynamic> map)
      : time = map['time'],
        type = map['type'];
}
