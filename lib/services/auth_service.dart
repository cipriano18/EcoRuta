import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecoruta/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  LOGIN
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  //  REGISTER
  Future<UserCredential> register({
    required String fullName,
    required String email,
    required String address,
    required String password,
    required int avatarId,
    required String favoriteActivity,
  }) async {
    final userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No se pudo crear el usuario',
      );
    }

    //  Guardar en Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email.trim(),
      'fullName': fullName.trim(),
      'address': address.trim(),
      'avatarId': avatarId,
      'favoriteActivity': favoriteActivity.trim(),
      'completed_routes': 0,
      'km_counter': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  //  Obtener usuario por UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  //  Obtener usuario actual 
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateAvatar(int avatarId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No hay un usuario autenticado',
      );
    }

    await _firestore.collection('users').doc(user.uid).update({
      'avatarId': avatarId,
    });
  }

  Future<void> updateProfile({
    required String fullName,
    required String address,
    required String favoriteActivity,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No hay un usuario autenticado',
      );
    }

    await _firestore.collection('users').doc(user.uid).update({
      'fullName': fullName.trim(),
      'address': address.trim(),
      'favoriteActivity': favoriteActivity.trim(),
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No hay un usuario autenticado',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword.trim(),
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword.trim());
  }

  Future<void> deleteCurrentAccount() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No hay un usuario autenticado',
      );
    }

    final uid = user.uid;

    await user.delete();
    await _firestore.collection('users').doc(uid).delete();
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
