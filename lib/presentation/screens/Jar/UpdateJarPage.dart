import 'package:flutter/material.dart';
import '../../../controllers/JarController.dart';
import '../../../models/Jar.dart';
import '../../../models/Reponse/UpdateJarSetting.dart';

class UpdateJarPage extends StatefulWidget {
  final Jar jar;


  const UpdateJarPage({super.key,required this.jar,});
  @override
  State<UpdateJarPage> createState() => _UpdateJarPage();
}

class _UpdateJarPage extends State<UpdateJarPage> {
  final _controller = JarController();
  final _formKey = GlobalKey<FormState>();

  final _money = TextEditingController();
  final _description = TextEditingController();

  final _nameJar = TextEditingController();
    JarType? _selectedName;

    late final int _idJar;
  @override
  void initState() {
    super.initState();
    _idJar = widget.jar.id!;
    _nameJar.text = widget.jar.nameJar;
    _money.text = widget.jar.balance.toString();
    _description.text = widget.jar.description;
  }

  @override
  void dispose() {
    _money.dispose();
    _description.dispose();
    _nameJar.dispose();
    super.dispose();
  }







  void _save() async {
    try {
      UpdateJarSetting updateJarSetting = UpdateJarSetting(
        id: _idJar,
        name: _selectedName!.name,
        nameJar: _nameJar.text,
        balance: double.parse(_money.text),
        description: _description.text,
      ) ;

      await _controller.updateJarSetting(updateJarSetting);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('update thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF3F6),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thêm tài khoản",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// ===== SỐ DƯ BAN ĐẦU =====
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Số dư ban đầu",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _money,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0 đ",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập số tiền';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Phải là số';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== THÔNG TIN TÀI KHOẢN =====
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [

                    /// TÊN TÀI KHOẢN
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet,
                          color: Colors.blue),
                      title: TextFormField(
                        controller: _nameJar,
                        decoration: const InputDecoration(
                          hintText: "Tên tài khoản",
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập ghi chú';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    /// LOẠI HŨ
                    ListTile(
                      leading: const Icon(Icons.category, color: Colors.blue),
                      title: DropdownButtonFormField<JarType>(
                        value: _selectedName,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Chọn loại hũ",
                        ),
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
                        validator: (value) =>
                        value == null ? 'Chọn loại hũ' : null,
                      ),
                    ),
                    const Divider(height: 1),

                    /// MÔ TẢ
                    ListTile(
                      leading: const Icon(Icons.notes, color: Colors.grey),
                      title: TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                          hintText: "Diễn giải",
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập ghi chú';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ===== BUTTON =====
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _save();
                    }
                  },
                  child: const Text(
                    "Lưu lại",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}