import 'package:flutter/cupertino.dart';
import 'package:flutter_application_expense/models/Member.dart';
import 'package:flutter_application_expense/repositories/MemberRepository.dart';

class MemberController {
  final MemberRepository _repo = MemberRepository();

  Future<void> addMember(String name, String role) async {
    final member = Member(
      name: name.trim(),
      role: role.trim(),
      created_at: DateTime.now().toIso8601String(),
    );


    await _repo.insert(member);
  }



  Future<List<Member>> getMember() async {
    return _repo.getAll();
  }


}
