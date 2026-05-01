class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String address;
  final int avatarId;
  final String? favoriteActivity;
  final int? _completedRoutes;
  final num? _kmCounter;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.address,
    required this.avatarId,
    this.favoriteActivity,
    int? completedRoutes,
    num? kmCounter,
  }) : _completedRoutes = completedRoutes,
       _kmCounter = kmCounter;

  int get completedRoutes => _completedRoutes ?? 0;
  num get kmCounter => _kmCounter ?? 0;

  factory UserModel.fromMap(Map<String, dynamic> data) {
    final rawAvatarId = data['avatarId'];
    final rawCompletedRoutes = data['completed_routes'];
    final rawKmCounter = data['km_counter'];

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
    );
  }
}
