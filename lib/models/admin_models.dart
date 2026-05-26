class AdminStats {
  final int users;
  final int rooms;
  final int messagesToday;
  final int pending;
  final int reports;

  AdminStats({
    required this.users,
    required this.rooms,
    required this.messagesToday,
    required this.pending,
    required this.reports,
  });
}

class UserRow {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final bool isBanned;
  final DateTime createdAt;
  final List<String> roles;

  UserRow({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.isBanned,
    required this.createdAt,
    required this.roles,
  });

  factory UserRow.fromJson(Map<String, dynamic> json) {
    return UserRow(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      isBanned: json['is_banned']?? false,
      createdAt: DateTime.parse(json['created_at']),
      roles: List<String>.from(json['roles']?? []),
    );
  }
}

class Room {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String status; // pending, approved, rejected
  final bool isClosed;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.status,
    required this.isClosed,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['owner_id'],
      status: json['status'],
      isClosed: json['is_closed']?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class UserReport {
  final String id;
  final String reporterId;
  final String reportedId;
  final String reason;
  final String? details;
  final String status;
  final DateTime createdAt;
  final String? adminNote;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final UserRow? reporter;
  final UserRow? reported;

  UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    this.details,
    required this.status,
    required this.createdAt,
    this.adminNote,
    this.resolvedAt,
    this.resolvedBy,
    this.reporter,
    this.reported,
  });
}

const Map<String, Map<String, dynamic>> reportReasons = {
  'harassment': {'label': 'تحرش أو تنمر', 'icon': 'UserX'},
  'hate_speech': {'label': 'خطاب كراهية', 'icon': 'MessageSquareWarning'},
  'spam': {'label': 'سبام أو احتيال', 'icon': 'Shield'},
  'inappropriate': {'label': 'محتوى غير لائق', 'icon': 'ImageOff'},
  'impersonation': {'label': 'انتحال شخصية', 'icon': 'UserMinus'},
  'other': {'label': 'سبب آخر', 'icon': 'HelpCircle'},
};
