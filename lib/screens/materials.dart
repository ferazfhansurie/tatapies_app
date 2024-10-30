import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juta_app/screens/material_table.dart';

class Materials extends StatefulWidget {
  const Materials({super.key});

  @override
  State<Materials> createState() => _MaterialsState();
}

class _MaterialsState extends State<Materials> {
  List<String> pie = ['Classic Apple Pie',"Caramel 'O' Pecan",'Johnny Blueberry','Lady Pineapple'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(leading: GestureDetector(
        onTap: (){
          Navigator.pop(context);
        },
        child: Icon(Icons.chevron_left,color:Colors.black)),middle:Text("Select Pie")),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context,index){
        return GestureDetector(
          onTap: (){
           
                         Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return  MaterialTable(
                             pie:pie[index]
                              );
                            }));
          },
          child: Column(
            children: [
              ListTile(title: Text(pie[index]),),
              Divider()
            ],
          ),
        );
      }),
    );
  }
}