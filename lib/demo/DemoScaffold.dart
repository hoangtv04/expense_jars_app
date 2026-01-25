import 'package:flutter/material.dart';

class DemoScaffold extends StatelessWidget {
  const DemoScaffold({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold( // 1 Scaffold ~ widget lớn, cung cấp nơi chứa các thành phânf giao diện
    appBar: AppBar(title: Text("My first app")),
    backgroundColor: Colors.blue,
    body: Center(child: Text("I am body")),
    floatingActionButton: FloatingActionButton(onPressed: () {
      print ("You've click flbtn");
    }),
    bottomNavigationBar: BottomNavigationBar(items: [
      BottomNavigationBarItem(icon: Icon(Icons.group), label: "Group"), 
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "My home"),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),  
    ]),
  );
  }
}