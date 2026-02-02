


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
      balance: res.balance,
      description: res.description,
      is_deleted: res.is_deleted,
      created_at: res.created_at
    );

    print("insert");
    await _repo.insertJar(jar);
  }

  Future<void> deleteJar(int id) async {




    // await _repo.;
  }

  Future<List<Jar>> getJar() async {
    final list = await _repo.getAll();
    print('Jar count: ${list.length}');
    return list;
  }

  double calTotalMoney(List<Jar> jars) {
    return jars.fold(0, (sum, jar) => sum + jar.balance);
  }



}
