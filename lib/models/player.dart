class Player {
  final String? id;       // preenchido após vir do banco
  final String name;
  final String? nickname;
  final String position;
  final String preferredFoot;
  final DateTime? birthDate;
  final bool isAdmin;
  final bool isActive;
  final bool isGuest;
  final int level;
  final String avatarUrl;
  final int games;   // estatísticas
  final int goals;
  final int assists;

  const Player({
    this.id,
    required this.name,
    this.nickname = '',
    required this.position,
    required this.preferredFoot,
    this.birthDate,
    this.isAdmin = false,
    this.isActive = false,
    this.isGuest = false,
    this.level = 3,
    this.avatarUrl = '',
    this.games = 0,
    this.goals = 0,
    this.assists = 0,
  });


  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String?,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      position: json['position'] as String,
      preferredFoot: json['preferred_foot'] as String,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      isAdmin: json['is_admin'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
      isGuest: json['is_guest'] as bool? ?? false,
      level: json['level'] as int? ?? 3,
      avatarUrl: json['avatar_url'] as String? ?? '',
      games: json['games'] as int? ?? 0,
      goals: json['goals'] as int? ?? 0,
      assists: json['assists'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    if (nickname != null) 'nickname': nickname,
    'position': position,
    'preferred_foot': preferredFoot,
    'birth_date': birthDate?.toIso8601String(),
    'is_admin': isAdmin,
    'is_active': isActive,
    'is_guest': isGuest,
    'level': level,
    'avatar_url': avatarUrl,
    'games': games,
    'goals': goals,
    'assists': assists,
  };

  Player copyWith({
    String? id,
    String? name,
    String? nickname,
    String? position,
    String? preferredFoot,
    DateTime? birthDate,
    bool? isAdmin,
    bool? isActive,
    bool? isGuest,
    int? level,
    String? avatarUrl,
    int? games,
    int? goals,
    int? assists,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      position: position ?? this.position,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      birthDate: birthDate ?? this.birthDate,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      isGuest: isGuest ?? this.isGuest,
      level: level ?? this.level,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      games: games ?? this.games,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
    );
  }

  int get age {
    if(birthDate == null){
      return 0;
    }
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month || (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}