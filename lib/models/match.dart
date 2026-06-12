

class Match {
  final String id;
  final DateTime matchDate;
  final String status; // e.g., 'scheduled', 'ongoing', 'canceled', 'finished'
  final String location;

  Match({
    required this.id,
    required this.matchDate,
    required this.status,
    this.location = '',
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      status: json['status'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'match_date': matchDate.toIso8601String(),
    'status': status,
    'location': location,
  };

}