class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String address;
  final int avatarId;
  final String? favoriteActivity;
  final int? _completedRoutes;
  final num? _kmCounter;
  final DateTime? _streakStartedAt;
  final DateTime? _streakDeadlineAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.address,
    required this.avatarId,
    this.favoriteActivity,
    int? completedRoutes,
    num? kmCounter,
    DateTime? streakStartedAt,
    DateTime? streakDeadlineAt,
  }) : _completedRoutes = completedRoutes,
       _kmCounter = kmCounter,
       _streakStartedAt = streakStartedAt,
       _streakDeadlineAt = streakDeadlineAt;

  int get completedRoutes => _completedRoutes ?? 0;
  num get kmCounter => _kmCounter ?? 0;
  DateTime? get streakStartedAt => _streakStartedAt;
  DateTime? get streakDeadlineAt => _streakDeadlineAt;
  int get streakWeeks {
    final startedAt = _streakStartedAt;
    final deadlineAt = _streakDeadlineAt;
    if (startedAt == null || deadlineAt == null) return 0;

    final now = DateTime.now();
    if (deadlineAt.isBefore(now)) return 0;

    return (now.difference(startedAt).inDays ~/ 7) + 1;
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    final rawAvatarId = data['avatarId'];
    final rawCompletedRoutes = data['completed_routes'];
    final rawKmCounter = data['km_counter'];
    final rawStreakStartedAt = data['streak_started_at'];
    final rawStreakDeadlineAt = data['streak_deadline_at'];

    return UserModel(
      uid: (data['uid'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      fullName: (data['fullName'] ?? 'Usuario').toString(),
      address: (data['address'] ?? '').toString(),
      avatarId: rawAvatarId is num ? rawAvatarId.toInt() : 0,
      favoriteActivity: data['favoriteActivity']?.toString(),
      completedRoutes: rawCompletedRoutes is num
          ? rawCompletedRoutes.toInt()
          : 0,
      kmCounter: rawKmCounter is num ? rawKmCounter : 0,
      streakStartedAt: _parseDate(rawStreakStartedAt),
      streakDeadlineAt: _parseDate(rawStreakDeadlineAt),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? address,
    int? avatarId,
    String? favoriteActivity,
    int? completedRoutes,
    num? kmCounter,
    DateTime? streakStartedAt,
    DateTime? streakDeadlineAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      avatarId: avatarId ?? this.avatarId,
      favoriteActivity: favoriteActivity ?? this.favoriteActivity,
      completedRoutes: completedRoutes ?? _completedRoutes,
      kmCounter: kmCounter ?? _kmCounter,
      streakStartedAt: streakStartedAt ?? _streakStartedAt,
      streakDeadlineAt: streakDeadlineAt ?? _streakDeadlineAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value.runtimeType.toString() == 'Timestamp') {
      try {
        return value.toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
