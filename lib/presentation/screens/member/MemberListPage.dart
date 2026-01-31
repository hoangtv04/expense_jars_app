import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../controllers/MemberController.dart';
import '../../../models/Member.dart';

class Memberlistpage extends StatefulWidget {
  const Memberlistpage({super.key});

  @override
  State<Memberlistpage> createState() => _MemberlistpageState();
}

class _MemberlistpageState extends State<Memberlistpage> {
  final _controller = MemberController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách Member'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<Member>>(
            future: _controller.getMember(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              final members = snapshot.data!;
              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(members[index].name),
                    subtitle: Text(members[index].role),
                  );
                },
              );
            },
          ),
        ),
    );
  }
}