import 'package:flutter_application_expense/models/Member.dart';

import '../db/app_database.dart';




class MemberRepository {


  Future<int> insert(Member member) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('member', member.toMap());
  }

  Future<List<Member>> getAll() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('member');
    return maps.map((e) => Member.fromMap(e)).toList();
  }
}