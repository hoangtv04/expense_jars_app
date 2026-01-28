import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_application_expense/models/user.dart';

class DatabaseHelper {
  final databaseName = "app_database.db";

  String usersTable =
      "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(usersTable);
      },
    );
  }

  Future<int> signup(Users user) async {
    final db = await initDB();
    return db.insert(
      "users",
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Users?> login(String email, String password) async {
    final db = await initDB();
    final res = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );

    if (res.isNotEmpty) {
      return Users.fromMap(res.first);
    }
    return null;
  }

  // Future<void> debugUsers() async {
  //   final db = await initDB();
  //   final result = await db.rawQuery('SELECT * FROM users');
  //   print('===== USERS TABLE =====');
  //   print(result);
  // }

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
}
