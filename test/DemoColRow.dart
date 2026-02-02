import 'package:flutter/material.dart';

class DemoColRow extends StatelessWidget {
  const DemoColRow({super.key});

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
    


    body: Center(child: Column(
      children: [Row(children: [
        SizedBox(width: 40,),
        Icon(Icons.abc),
        Icon(Icons.icecream),
      ],spacing: 30,),
      SizedBox(height: 60,),
      Row(children: [
        Text("Text 1 lakjfa;lkw"),
        Text("Text 2"),
      ],)
      ]
    ),),






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