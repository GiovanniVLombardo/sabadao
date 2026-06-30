class Team {
  final int? id;
  final String name;
  final String acronym;
  final String color;
  final bool isActive;

  const Team({
    this.id,
    required this.name,
    required this.acronym,
    required this.color,
    required this.isActive,
  });

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as int,
      name: map['name'] as String,
      acronym: map['acronym'] as String,
      color: map['color'] as String,
      isActive: map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'acronym': acronym,
      'color': color,
      'is_active': isActive,
    };
  }
}
