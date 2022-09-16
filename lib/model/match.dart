/// Alle Matches eines Spielers
class Matches {
  List<Match>? matches;

  Matches.fromList(List<dynamic> matchList) {
    matches = [];
    for (var element in matchList) {
      Match match = Match.fromMap(element);
      matches!.add(match);
    }
  }

  Match? elementAt(int i) {
    if (matches != null) {
      return matches!.elementAt(i);
    }
    return null;
  }
}

/// Attribute von einem Match
class Match {
  final int day;
  final String? time;
  final String? type;

  Match(this.day, this.time, this.type);

  Match.fromMap(Map<String, dynamic> map)
      : day = int.parse(map['day']),
        time = map['time'],
        type = map['type'];
}