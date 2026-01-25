import 'package:flutter/material.dart';

class DemoButton extends StatelessWidget {
  const DemoButton({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold( // 1 Scaffold ~ widget lớn, cung cấp nơi chứa các thành phânf giao diện
    appBar: AppBar(
      title: Text("My first appsss"),
      backgroundColor: Colors.amber,
      actions: [
        IconButton(onPressed: (){print("click ic1");}, icon: Icon(Icons.search)),
        IconButton(onPressed: (){print("click ic2");}, icon: Icon(Icons.menu)),
        IconButton(onPressed: (){print("click ic3");}, icon: Icon(Icons.shop)),
      ],
      elevation: 15,
    ),
    


    body: Center(
      child: Column(
        children: [
          SizedBox(height: 50),

          ElevatedButton(onPressed: () {print("click elevated button");}, 
          child: Text("Click me", style: TextStyle(fontSize: 28,)
          
          ),style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            elevation: 15,
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(5))
          ), 
        
        ),
        SizedBox(height: 50),
        TextButton(onPressed: () {print ("Click to text button");},
        child: Text("I'm text button")),

        OutlinedButton(onPressed: () {}, child: Text("I'm outline button "))

        ],
      ),
    ),






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