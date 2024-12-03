import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';
import 'note.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes_database2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Таблиця акаунтів
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        login TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        password_hash TEXT NOT NULL
      )
    ''');

    // Таблиця нотаток
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        modified_at TEXT NOT NULL,
        account_id INTEGER NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Додавання акаунту
  Future<int> insertAccount(String name, String login, String password) async {
    final db = await instance.database;
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    return await db.insert('accounts', {
      'name': name,
      'login': login,
      'password_hash': passwordHash,
    });
  }

  /// Перевірка пароля
  Future<bool> validatePassword(String login, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'accounts',
      where: 'login = ?',
      whereArgs: [login],
    );

    if (result.isEmpty) return false;

    final passwordHash = result.first['password_hash'] as String;
    return BCrypt.checkpw(password, passwordHash);
  }

  /// Отримання всіх акаунтів
  Future<List<Map<String, dynamic>>> fetchAccounts() async {
    final db = await instance.database;
    return await db.query('accounts');
  }

  /// Додавання нотатки для акаунту
  Future<int> insertNote(Note note, int accountId) async {
    final db = await instance.database;
    return await db.insert('notes', {
      ...note.toMap(),
      'account_id': accountId,
    });
  }

  /// Отримання всіх нотаток для акаунту
  Future<List<Note>> fetchNotes(int accountId) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  /// Оновлення нотатки
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Видалення нотатки
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Видалення акаунта та всіх його нотаток
  Future<void> deleteAccount(int accountId) async {
    final db = await instance.database;
    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );
    // Нотатки видаляються автоматично через FOREIGN KEY ... ON DELETE CASCADE
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
