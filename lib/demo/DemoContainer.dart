import 'package:flutter/material.dart';

class DemoContainer extends StatelessWidget {
  const DemoContainer({super.key});

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
    


    body: Center(child: Container(
      width: 250, height: 250,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green, blurRadius: 30)]
      ),
    child: Text("Hello"),

    )),






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