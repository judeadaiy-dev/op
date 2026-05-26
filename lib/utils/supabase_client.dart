import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = "https://jmsmrojtlstppnpwmkkk.supabase.co";
  static const String anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imptc21yb2p0bHN0cHBucHdta2trIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4MTg2NDAsImV4cCI6MjA4ODM5NDY0MH0.j7gxr5CvrfvbJJzK_pMwVHiCE2AqpXUTThpeLEBmsos";
}

final supabase = Supabase.instance.client;

// ====================================================================
// Types
// ====================================================================

typedef AppRole = String; // "admin" | "moderator" | "user"
typedef RoomStatus = String; // "pending" | "approved" | "rejected"
typedef FriendshipStatus = String; // "pending" | "accepted" | "blocked"
typedef MessageType = String; // "text" | "image" | "voice"
typedef NotifType = String; // "message" | "friend_request" | "friend_accept" | "room_approved" | "room_rejected" | "system"

class Profile {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isBanned;
  final String lastSeenAt;
  final String createdAt;
  final String updatedAt;

  Profile({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.isBanned,
    required this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      isBanned: json['is_banned'] ?? false,
      lastSeenAt: json['last_seen_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_banned': isBanned,
      'last_seen_at': lastSeenAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Room {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? link;
  final String ownerId;
  final bool isActive;
  final bool isClosed;
  final RoomStatus status;
  final String createdAt;
  final bool? isDm;
  final String? dmKey;

  Room({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.link,
    required this.ownerId,
    required this.isActive,
    required this.isClosed,
    required this.status,
    required this.createdAt,
    this.isDm,
    this.dmKey,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coverUrl: json['cover_url'],
      link: json['link'],
      ownerId: json['owner_id'],
      isActive: json['is_active'] ?? true,
      isClosed: json['is_closed'] ?? false,
      status: json['status'],
      createdAt: json['created_at'],
      isDm: json['is_dm'],
      dmKey: json['dm_key'],
    );
  }
}

class Message {
  final String id;
  final String roomId;
  final String userId;
  final String content;
  final MessageType messageType;
  final String? mediaUrl;
  final int? mediaDuration;
  final String createdAt;
  final String? editedAt;
  final Profile? profile;
  final bool? authorIsAdmin;

  Message({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.content,
    required this.messageType,
    this.mediaUrl,
    this.mediaDuration,
    required this.createdAt,
    this.editedAt,
    this.profile,
    this.authorIsAdmin,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      content: json['content'],
      messageType: json['message_type'],
      mediaUrl: json['media_url'],
      mediaDuration: json['media_duration'],
      createdAt: json['created_at'],
      editedAt: json['edited_at'],
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      authorIsAdmin: json['authorIsAdmin'],
    );
  }
}

class RoomBan {
  final String id;
  final String roomId;
  final String userId;
  final String bannedBy;
  final String? reason;
  final String? expiresAt;
  final String createdAt;

  RoomBan({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.bannedBy,
    this.reason,
    this.expiresAt,
    required this.createdAt,
  });

  factory RoomBan.fromJson(Map<String, dynamic> json) {
    return RoomBan(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      bannedBy: json['banned_by'],
      reason: json['reason'],
      expiresAt: json['expires_at'],
      createdAt: json['created_at'],
    );
  }
}

class RoomModerator {
  final String id;
  final String roomId;
  final String userId;
  final String createdAt;

  RoomModerator({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.createdAt,
  });

  factory RoomModerator.fromJson(Map<String, dynamic> json) {
    return RoomModerator(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
    );
  }
}

class Friendship {
  final String id;
  final String requesterId;
  final String addresseeId;
  final FriendshipStatus status;
  final String createdAt;
  final String updatedAt;

  Friendship({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'],
      requesterId: json['requester_id'],
      addresseeId: json['addressee_id'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AppNotification {
  final String id;
  final String userId;
  final NotifType type;
  final String title;
  final String? body;
  final String? link;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.link,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      link: json['link'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'link': link,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}

class ThemePreset {
  final String id;
  final String name;
  final String primaryHue;
  final String primarySat;
  final String primaryLight;
  final bool isActive;
  final bool isBuiltin;
  final String? createdBy;
  final String createdAt;

  ThemePreset({
    required this.id,
    required this.name,
    required this.primaryHue,
    required this.primarySat,
    required this.primaryLight,
    required this.isActive,
    required this.isBuiltin,
    this.createdBy,
    required this.createdAt,
  });

  factory ThemePreset.fromJson(Map<String, dynamic> json) {
    return ThemePreset(
      id: json['id'],
      name: json['name'],
      primaryHue: json['primary_hue'],
      primarySat: json['primary_sat'],
      primaryLight: json['primary_light'],
      isActive: json['is_active'] ?? false,
      isBuiltin: json['is_builtin'] ?? false,
      createdBy: json['created_by'],
      createdAt: json['created_at'],
    );
  }
}
