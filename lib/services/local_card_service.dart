import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/aac_card.dart';

class LocalCardService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    // Создаем отдельный файл БД для карточек
    String path = join(await getDatabasesPath(), 'aac_cards.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cards (
          id TEXT PRIMARY KEY,
          title TEXT,
          emoji TEXT,
          userEmail TEXT
        )
      ''');
    });
  }

  // Добавить карточку
  Future<void> addCard(AacCard card) async {
    final db = await database;
    await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Если id совпадет, перезапишем
    );
  }

  // Получить все карточки конкретного пользователя
  Future<List<AacCard>> getUserCards(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'userEmail = ?',
      whereArgs: [email],
    );

    // Превращаем List<Map> в List<AacCard>
    return List.generate(maps.length, (i) => AacCard.fromMap(maps[i]));
  }
}