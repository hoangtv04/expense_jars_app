import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_application_expense/models/user.dart';

class DatabaseHelper {
  static Database? _database;
  final databaseName = "app_database.db";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON');

        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
        )
        ''');

        // ===== JARS (CHÈN THÊM)
        await db.execute('''
        CREATE TABLE jars (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          balance REAL DEFAULT 0,
          description TEXT,
          is_deleted INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE
        )
      ''');

        // ===== CATEGORIES (CHÈN THÊM)
        await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          type TEXT NOT NULL
            CHECK (type IN ('income', 'expense')),
          limit_amount REAL,
          description TEXT,
          is_deleted INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE
        )
      ''');

        // ===== TRANSACTIONS (CHÈN THÊM)
        await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          jar_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          date TEXT NOT NULL,
          status TEXT DEFAULT 'completed'
            CHECK (status IN ('completed', 'pending', 'canceled')),
          is_deleted INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE,
          FOREIGN KEY (jar_id)
            REFERENCES jars(id)
            ON DELETE CASCADE,
          FOREIGN KEY (category_id)
            REFERENCES categories(id)
            ON DELETE CASCADE
        )
      ''');

        // ===== JAR LOGS (CHÈN THÊM)
        await db.execute('''
        CREATE TABLE jar_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          jar_id INTEGER NOT NULL,
          transaction_id INTEGER,
          change_amount REAL NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (jar_id)
            REFERENCES jars(id)
            ON DELETE CASCADE,
          FOREIGN KEY (transaction_id)
            REFERENCES transactions(id)
            ON DELETE SET NULL
        )
      ''');
      },
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<int> signup(Users user) async {
    final db = await database;
    return db.insert(
      "users",
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Users?> login(String email, String password) async {
    final db = await database;
    final res = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  Future<void> debugUsers() async {
    final db = await database;
    final result = await db.query("users");
    print("===== USERS TABLE =====");
    for (var row in result) {
      print(row);
    }
  }

  // Future<void> debugUsers() async {
  //   final db = await initDB();
  //   final result = await db.rawQuery('SELECT * FROM users');

  //   print('===== USERS TABLE =====');
  //   for (var row in result) {
  //     print(row);
  //   }
  //   print('===== END =====');
  // }

  // Future<void> clearUsers() async {
  //   final db = await initDB();
  //   await db.delete('users');
  //   print('===== USERS CLEARED =====');
  // }

  // Future<void> clearUsersAndResetId() async {
  //   final db = await initDB();

  //   // 1️⃣ Xóa toàn bộ user
  //   await db.delete('users');

  //   // 2️⃣ Reset bộ đếm AUTOINCREMENT
  //   await db.rawQuery("DELETE FROM sqlite_sequence WHERE name = 'users'");

  //   print('USERS CLEARED + ID RESET');
  // }
}
