import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'auth_repository.dart';

class LocalAuthService implements IAuthRepository {
  static Database? _db;
  final _authController = StreamController<String?>.broadcast();

  @override
  Stream<String?> get onAuthStateChanged => _authController.stream;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'auth.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('CREATE TABLE users (email TEXT PRIMARY KEY, password TEXT)');
    });
  }

  @override
  Future<bool> signUp(String email, String password) async {
    final db = await database;
    // Хешируем пароль
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);

    try {
      await db.insert('users', {'email': email, 'password': digest.toString()});
      _authController.add(email);
      return true;
    } catch (e) {
      return false; // Пользователь уже существует
    }
  }

  @override
  Future<bool> signIn(String email, String password) async {
    final db = await database;
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);

    List<Map> maps = await db.query('users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, digest.toString()]);

    if (maps.isNotEmpty) {
      _authController.add(email);
      return true;
    }
    return false;
  }

  @override
  Future<void> signOut() async {
    _authController.add(null);
  }
}