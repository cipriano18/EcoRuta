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

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}