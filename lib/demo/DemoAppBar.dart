import 'package:flutter/material.dart';

class DemoAppBar extends StatelessWidget {
  const DemoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold( // 1 Scaffold ~ widget lớn, cung cấp nơi chứa các thành phânf giao diện
    appBar: AppBar(
      title: Text("My first app"),
      backgroundColor: Colors.amber,
      actions: [
        IconButton(onPressed: (){print("click ic1");}, icon: Icon(Icons.search)),
        IconButton(onPressed: (){print("click ic2");}, icon: Icon(Icons.menu)),
        IconButton(onPressed: (){print("click ic3");}, icon: Icon(Icons.shop)),
      ],
      elevation: 15,
    ),








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