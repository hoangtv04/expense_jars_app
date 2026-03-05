import 'package:flutter/material.dart';
import 'package:flutter_application_jars/controllers/SavingController.dart';
import 'package:flutter_application_jars/models/Reponse/SavingRespone.dart';

class SavingAddPage extends StatefulWidget {
  const SavingAddPage({super.key});

  @override
  State<SavingAddPage> createState() => _SavingAddPageState();
}

class _SavingAddPageState extends State<SavingAddPage> {
  final _formKey = GlobalKey<FormState>();

  final _money = TextEditingController();
  final _name = TextEditingController();
  final _interest = TextEditingController();
  final _note = TextEditingController();

  final _controller = SavingController();
  DateTime today = DateTime.now();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  void _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {

      print("Name: ${_name.text}");
      print("Money: ${_money.text}");
      print("Interest: ${_interest.text}");
      print("Start: $_startDate");
      print("End: $_endDate");
      print("Note: ${_note.text}");

      SavingRespone savingRespone = SavingRespone(
       userId: 1,
        name: _name.text,
        principal: double.parse(_money.text),
        startDate: _startDate.toString().split(" ")[0],
        endDate: _endDate.toString().split(" ")[0],
        createdAt: _startDate.toString().split(" ")[0]
      );


      _controller.addSaving(savingRespone);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm sổ tiết kiệm thành công")),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
          "Thêm sổ tiết kiệm",
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

              /// ===== TIỀN GỬI =====
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [

                    const Text(
                      "Số tiền gửi",
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
                        color: Colors.orange,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0 đ",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nhập số tiền";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== THÔNG TIN SỔ =====
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  children: [

                    /// TÊN SỔ
                    ListTile(
                      leading: const Icon(Icons.savings, color: Colors.orange),
                      title: TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          hintText: "Tên sổ tiết kiệm",
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nhập tên sổ";
                          }
                          return null;
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    /// LÃI SUẤT
                    ListTile(
                      leading: const Icon(Icons.percent, color: Colors.green),
                      title: TextFormField(
                        controller: _interest,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Lãi suất (%/năm)",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const Divider(height: 1),

                    /// NGÀY BẮT ĐẦU
                    ListTile(
                      leading: const Icon(Icons.calendar_today,
                          color: Colors.blue),
                      title: const Text("Ngày bắt đầu"),
                      trailing: Text(_formatDate(_startDate)),
                      onTap: _pickStartDate,
                    ),

                    const Divider(height: 1),

                    /// NGÀY ĐÁO HẠN
                    ListTile(
                      leading: const Icon(Icons.event, color: Colors.red),
                      title: const Text("Ngày đáo hạn"),
                      trailing: Text(
                        _endDate == null
                            ? "Chọn ngày"
                            : _formatDate(_endDate!),
                      ),
                      onTap: _pickEndDate,
                    ),

                    const Divider(height: 1),

                    /// NOTE
                    ListTile(
                      leading: const Icon(Icons.notes, color: Colors.grey),
                      title: TextFormField(
                        controller: _note,
                        decoration: const InputDecoration(
                          hintText: "Ghi chú",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: _save,

                  child: const Text(
                    "Lưu lại",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}