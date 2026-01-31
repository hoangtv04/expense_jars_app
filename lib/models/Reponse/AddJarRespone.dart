import 'package:flutter_application_expense/models/Jar.dart';

class AddJarRespone {

  final int user_id;
  final String name;
  final double balance;
  final String description;
  final int is_deleted;
  final DateTime created_at;
  // bảng family đề phòng trường hợp gia đình tách riêng ra


  AddJarRespone({
    required this.user_id,
    required this.name,
    required this.balance,
    this.description ='',
    this.is_deleted = 0,
    required this.created_at
  });
}