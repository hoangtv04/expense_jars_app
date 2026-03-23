


import 'package:flutter_application_jars/models/Reponse/JarOption.dart';
import 'package:flutter_application_jars/models/Reponse/UpdateJarSetting.dart';
import 'package:uuid/uuid.dart';

import '../db/app_state.dart';
import '../models/Jar.dart';
import '../models/Reponse/AddJarRespone.dart';
import '../repositories/JarRepository.dart';
import '../services/session_services.dart';

class  JarController{
  final JarRepository _repo = JarRepository();
  final _uuid = const Uuid();

  JarType jarTypeFromString(String value) {
    return JarType.values.firstWhere(
          (e) => e.name == value,
    );
  }


  Future<void> addJar(AddJarRespone res) async {
    final JarType jarName = jarTypeFromString(res.name);

    String? userId = await SessionService.getUserId();

    if (userId == null) {

      return;
    }
    final jar = Jar(
        id: _uuid.v4(),
      user_id: userId,
      name: jarName,
      nameJar: res.nameJar,
      balance: res.balance,
      description: res.description,
      is_deleted: res.is_deleted,
      created_at: res.created_at
    );

    print("insert");
    await _repo.insertJar(jar);

    AppState.jarChanged.value++;

  }
  Future<void> updateJarSetting(UpdateJarSetting res) async {


    print("Update Full setting jar");
    await _repo.updateJarSetting(res);
    AppState.jarChanged.value++;

  }




  Future<void> deleteJar(String id) async {

    await  _repo.deleteJar(id);

    AppState.jarChanged.value++;

    print("Đã xóa thành công");

  }

  Future<List<Jar>> getJar() async {
    final list = await _repo.getAll();

    for (var jar in list) {
      print('ID: ${jar.id} | Tên: ${jar.nameJar} | Số dư: ${jar.balance}');
    }
    print('Jar count: ${list.length}');
    return list;
  }
  Future<Jar?> getJarById(String id) async {
    final jar = await _repo.getJarById(id);

    return jar;
  }
  double calTotalMoney(List<Jar> jars) {
    return jars.fold(0, (sum, jar) => sum + jar.balance);
  }

  Future<double> calTotalMoney2() async {
    final jars = await _repo.getAll();
    return jars.fold<double>(0, (sum, jar) => sum + jar.balance);
  }
  Future<double> getJarBalance(String id) async {
    return  await _repo.getJarBalanceById(id);
  }

  Future<void> settingJar(String id, double amount) async {
    final jar = await _repo.getJarById(id);

    if (jar == null) {
      throw Exception('Jar not found');
    }

    double updatedJar = jar.balance + amount;

    await _repo.updateJar(id,updatedJar);
  }

  Future<void> updateJarAmount(String id, double amount) async {
    final jar = await _repo.getJarById(id);

    if (jar == null) {
      throw Exception('Jar not found');
    }

    double updatedJar = jar.balance + amount;

    await _repo.updateJar(id,updatedJar);
  }

  Future<List<JarOption>> getListJarIdAndName() async{


    final jars = await _repo.getAll();

    List<JarOption> jarList = [];
    for(int i=0 ;i<jars.length;i++){
      JarOption option = new JarOption(id: jars[i].id!, name: jars[i].nameJar!);
      jarList.add(option);
    }


    return  jarList;
  }






}
