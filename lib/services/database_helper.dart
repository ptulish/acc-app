import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Делаем класс синглтоном, чтобы база открывалась только один раз
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aac_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Получаем путь к системной папке документов на устройстве
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Открываем базу, если её нет — создаем (версия 1)
    return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB
    );
  }

  // Создаем таблицы
  Future _createDB(Database db, int version) async {
    // В SQLite нет типа Boolean, поэтому используем INTEGER (0 - false, 1 - true)

    // 1. Таблица Категорий
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        label TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_custom INTEGER NOT NULL,
        user_id TEXT 
      )
    ''');

    // 2. Таблица Карточек
    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        label TEXT NOT NULL,
        category_id TEXT NOT NULL,
        image_path TEXT NOT NULL,
        is_custom INTEGER NOT NULL,
        usage_count INTEGER NOT NULL,
        user_id TEXT 
      )
    ''');
  }

  // ==========================================
  // МЕТОДЫ ДЛЯ КАТЕГОРИЙ
  // ==========================================

  // Сохранить новую категорию
  Future<void> insertCategory(Map<String, dynamic> categoryMap) async {
    final db = await instance.database;
    await db.insert('categories', categoryMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Получить только те категории, которые создал конкретный пользователь
  Future<List<Map<String, dynamic>>> getUserCategories(String userId) async {
    final db = await instance.database;
    return await db.query(
      'categories',
      where: 'user_id = ? AND is_custom = 1',
      whereArgs: [userId],
    );
  }

  // ==========================================
  // МЕТОДЫ ДЛЯ КАРТОЧЕК
  // ==========================================

  // Сохранить новую карточку
  Future<void> insertCard(Map<String, dynamic> cardMap) async {
    final db = await instance.database;
    await db.insert('cards', cardMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Получить только те карточки, которые создал конкретный пользователь
  Future<List<Map<String, dynamic>>> getUserCards(String userId) async {
    final db = await instance.database;
    return await db.query(
      'cards',
      where: 'user_id = ? AND is_custom = 1',
      whereArgs: [userId],
    );
  }
}