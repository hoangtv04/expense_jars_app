
import 'package:flutter_application_expense/db/app_database.dart';

import '../models/Jar.dart';

class JarRepository {

  Future<int> insertJar(Jar jar) async{
    final db = await AppDatabase.instance.database;
    return await db.insert("jars", jar.toMap());
  }



  Future<List<Jar>> getAll() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('jars');
    return maps.map((e) => Jar.fromMap(e)).toList();
  }

}