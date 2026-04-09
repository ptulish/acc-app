import 'package:firebase_auth/firebase_auth.dart'; // Оставим как тип для совместимости

abstract class IAuthRepository {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String email, String password);
  Future<void> signOut();
  Stream<String?> get onAuthStateChanged;
}