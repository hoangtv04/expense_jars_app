


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


    await _repo.insertJar(jar);
  }



  Future<List<Jar>> getJar() async {
    return _repo.getAll();
  }


}
