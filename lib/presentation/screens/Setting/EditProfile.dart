import 'package:flutter/material.dart';
import 'package:flutter_application_jars/services/session_services.dart';
import 'package:flutter_application_jars/repositories/user_repository.dart';
import 'package:flutter_application_jars/models/user.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthController = TextEditingController();

  String? gender;

  @override
  void initState() {
    super.initState();
    loadUser();

    nameController.addListener(() {
      setState(() {});
    });
  }

  Future<void> loadUser() async {
    final userId = await SessionService.getUserId();
    if (userId == null) return;

    final user = await UserRepository().getUserById(userId);

    if (user != null && mounted) {
      setState(() {
        /// 🔥 TÊN: ưu tiên fullName → fallback email
        nameController.text =
            (user.fullName != null && user.fullName!.isNotEmpty)
            ? user.fullName!
            : _formatNameFromEmail(user.email);

        /// 🔥 CÁC FIELD KHÁC: để trống nếu chưa có
        phoneController.text = user.phone ?? '';
        birthController.text = user.birth ?? '';
        gender = user.gender; // có thì hiện, không thì null
      });
    }
  }

  /// 🔥 SAVE PROFILE (BƯỚC 6 FIX)
  Future<void> updateProfile() async {
    final userId = await SessionService.getUserId();
    if (userId == null) return;

    await UserRepository().updateProfile(
      userId,
      nameController.text.trim(),
      phoneController.text.trim(),
      gender ?? "Nam",
      birthController.text.trim(),
    );

    /// 🔥 QUAN TRỌNG: reload lại data trước khi thoát
    await loadUser();

    if (!mounted) return;

    Navigator.pop(context, true); // báo Profile reload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Avatar (🔥 update realtime)
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue,
                    child: Text(
                      nameController.text.isNotEmpty
                          ? nameController.text[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Tên hiển thị
            const Text("Tên hiển thị"),
            const SizedBox(height: 6),
            _buildInput(nameController, hint: "Nhập tên hiển thị của bạn"),

            const SizedBox(height: 16),

            /// Số điện thoại
            const Text("Số điện thoại"),
            const SizedBox(height: 6),
            _buildInput(phoneController, hint: "Nhập số điện thoại của bạn"),

            const SizedBox(height: 16),

            /// Ngày sinh
            const Text("Ngày sinh"),
            const SizedBox(height: 6),
            TextField(
              controller: birthController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Chọn ngày sinh của bạn",
                suffixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    birthController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            /// Giới tính
            const Text("Giới tính"),
            Row(
              children: [
                Radio(
                  value: "Nam",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() => gender = value!);
                  },
                ),
                const Text("Nam"),
                Radio(
                  value: "Nữ",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() => gender = value!);
                  },
                ),
                const Text("Nữ"),
                Radio(
                  value: "Khác",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() => gender = value!);
                  },
                ),
                const Text("Khác"),
              ],
            ),

            const SizedBox(height: 24),

            /// Nút cập nhật
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: updateProfile,
                child: const Text("Cập nhật", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Xóa tài khoản",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNameFromEmail(String email) {
    return email.split('@')[0];
  }

  Widget _buildInput(TextEditingController controller, {String? hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
