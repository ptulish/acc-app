import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Стрим для отслеживания состояния пользователя (войден или нет)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Регистрация
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Ошибка регистрации: ${e.code}');
      rethrow; // Пробрасываем ошибку дальше для UI
    }
  }

  // Вход
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Ошибка входа: ${e.code}');
      rethrow;
    }
  }

  // Выход
  Future<void> signOut() async {
    await _auth.signOut();
  }
}