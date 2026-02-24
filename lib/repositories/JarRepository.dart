

import '../db/app_database.dart';
import '../models/Jar.dart';

class JarRepository {

  Future<int> insertJar(Jar jar) async{
    final db = await AppDatabase.instance.database;
    return await db.insert("jars", jar.toMap());
  }

  Future<void> updateJar(int id,double amount) async{
    final db = await AppDatabase.instance.database;

    await db.update(
      'jars',
      {'balance': amount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Jar?> getJarById(int id) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'jars',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1, // đảm bảo chỉ lấy 1 record
    );

    if (result.isEmpty) return null;

    return Jar.fromMap(result.first);
  }

  Future<int> deleteJar(int id) async{
    final db = await AppDatabase.instance.database;
    return await db.update(
      'jars',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Future<List<Jar>> getAllActive() async {
  //   final db = await AppDatabase.instance.database;
  //   final maps = await db.query('jars',
  //     where: 'is_deleted = 0',
  //   );
  //
  //   return maps.map((e) => Jar.fromMap(e)).toList();
  // }
  Future<List<Jar>> getAll() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('jars');

    return maps.map((e) => Jar.fromMap(e)).toList();
  }




}