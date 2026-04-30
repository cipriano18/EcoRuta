class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String address;
  final int avatarId;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.address,
    required this.avatarId,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      fullName: data['fullName'],
      address: data['address'],
      avatarId: data['avatarId'],
    );
  }
}