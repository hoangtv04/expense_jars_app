

import 'package:flutter_application_jars/models/Reponse/SavingRespone.dart';
import 'package:flutter_application_jars/repositories/SavingRepository.dart';

import '../db/app_state.dart';
import '../models/Saving.dart';

class SavingController {

   final SavingRepository _repo = SavingRepository();



Future<void> addSaving(SavingRespone res) async {

    final saving = Saving(
        userId: 1 ,
        jarId: res.jarId,
        interestRate: res.interestRate,
        name: res.name,
        principal: res.principal,
        createdAt: res.createdAt,
        startDate: res.startDate,
      endDate:  res.endDate,
      status: res.status,
      note: res.note,


    );

    print("insert");
    int check = await _repo.insertSaving(saving);
  print(check);

    AppState.jarChanged.value++;

  }



   Future<List<Saving>> getSaving() async {
     final list = await _repo.getAll();

     print('Jar count: ${list.length}');
     return list;
   }
}