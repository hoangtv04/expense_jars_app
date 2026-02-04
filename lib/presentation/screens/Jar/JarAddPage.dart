import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../controllers/JarController.dart';
import '../../../models/Jar.dart';
import '../../../models/Reponse/AddJarRespone.dart';

class JarAddPage extends StatefulWidget {
  const JarAddPage({super.key});

  @override
  State<JarAddPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<JarAddPage> {
  final _controller = JarController();


  final _formKey = GlobalKey<FormState>();

  //khai bao bien
  final _money = TextEditingController();
  final _description = TextEditingController();
  DateTime today = DateTime.now();

  JarType? _selectedName;

  void _save() async {
    try {
      // bảng family đề phòng trường hợp gia đình tách riêng ra


      AddJarRespone addJarRespone = new AddJarRespone(
          user_id: 1,
          name: _selectedName!.name,
          balance: double.parse(_money.text),
          description: _description.text,
          is_deleted: 0,
          created_at: today);

      await _controller.addJar(addJarRespone);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: HeroMode(
          enabled: false,
          child: AppBar(
            title: const Text('Add Jar'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [


                  DropdownButtonFormField<JarType>(
                    initialValue: _selectedName,
                    items: JarType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedName = value;
                      });
                    },
                    validator: (value) => value == null ? 'Chọn loại hũ' : null,
                  ),

                  TextFormField(
                    controller: _money,
                    decoration: InputDecoration(labelText: 'Số tiền ban đầu'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'nhập số';
                      }

                      if (int.tryParse(value) == null) {
                        return 'Phải là số nguyên';
                      }
                    },
                  ),

                  TextFormField(
                    controller: _description,
                    decoration: InputDecoration(labelText: 'Ghi chú'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ccccc';
                      }
                      return null;
                    },
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Form hợp lệ → xử lý tiếp
                        _save();
                      }
                    },
                    child: Text("Lưu"),
                  )


                ],
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Lưu')),
          ],
        ),
      ),

    );
  }


}