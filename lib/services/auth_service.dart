import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Стрим для отслеживания состояния пользователя
  Stream<User?> get user => _auth.authStateChanges();

  // Вход
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      rethrow; // Пробрасываем ошибку дальше для обработки в UI
    }
  }

  // Регистрация
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Выход
  Future<void> signOut() async {
    await _auth.signOut();
  }
}