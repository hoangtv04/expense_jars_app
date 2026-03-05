import 'package:flutter_application_jars/models/Saving.dart';

import '../db/app_database.dart';
import '../models/Jar.dart';

class SavingRepository {


  Future<int> insertSaving(Saving saving) async{
    final db = await AppDatabase.instance.database;


    return await db.insert("savings", saving.toMap());
  }

  Future<List<Saving>> getAll() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'savings',

    );

    return maps.map((e) => Saving.fromMap(e)).toList();
  }
}