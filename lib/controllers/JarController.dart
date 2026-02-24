


import 'package:flutter_application_jars/models/Reponse/JarOption.dart';
import 'package:flutter_application_jars/models/Reponse/UpdateJarSetting.dart';

import '../models/Jar.dart';
import '../models/Reponse/AddJarRespone.dart';
import '../repositories/JarRepository.dart';

class  JarController{
  final JarRepository _repo = JarRepository();


  JarType jarTypeFromString(String value) {
    return JarType.values.firstWhere(
          (e) => e.name == value,
    );
  }
  Future<void> addJar(AddJarRespone res) async {
    final JarType jarName = jarTypeFromString(res.name);

    final jar = Jar(
      user_id: 1,
      name: jarName,
      nameJar: res.nameJar,
      balance: res.balance,
      description: res.description,
      is_deleted: res.is_deleted,
      created_at: res.created_at
    );

    print("insert");
    await _repo.insertJar(jar);
  }
  Future<void> updateJarSetting(UpdateJarSetting res) async {


    print("Update Full setting jar");
    await _repo.updateJarSetting(res);
  }




  Future<void> deleteJar(int id) async {

    await  _repo.deleteJar(id);
    print("Đã xóa thành công");

  }

  Future<List<Jar>> getJar() async {
    final list = await _repo.getAll();

    print('Jar count: ${list.length}');
    return list;
  }

  double calTotalMoney(List<Jar> jars) {
    return jars.fold(0, (sum, jar) => sum + jar.balance);
  }

  Future<double> calTotalMoney2() async {
    final jars = await _repo.getAll();
    return jars.fold<double>(0, (sum, jar) => sum + jar.balance);
  }


  Future<void> settingJar(int id, double amount) async {
    final jar = await _repo.getJarById(id);

    if (jar == null) {
      throw Exception('Jar not found');
    }

    double updatedJar = jar.balance + amount;

    await _repo.updateJar(id,updatedJar);
  }
  Future<void> updateJarAmount(int id, double amount) async {
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
      JarOption option = new JarOption(id: jars[i].id!, name: jars[i].name.toString()!);
      jarList.add(option);
    }


    return  jarList;
  }






}
