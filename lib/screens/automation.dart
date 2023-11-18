import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juta_app/screens/blast.dart';


class AutomationScreen extends StatefulWidget {
  @override
  _AutomationScreenState createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  List<String> automationNames = []; // List to store automation names
  String companyId = "";
  String email = "";
  User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> automation = [];
  List<dynamic> opp = [];
  @override
  void initState() {
    super.initState();
    email = user!.email!;
    getUser();
  }

  Future<void> getUser() async {
    await FirebaseFirestore.instance
        .collection("user")
        .doc(email)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          companyId = snapshot.get("companyId");
        });
       
        getAutomations(); // Call getAutomations here
      } else {
        print("Snapshot not found");
      }
    });
  }

  void getAutomations() async {
    QuerySnapshot? querySnapshot;
    try {
      querySnapshot = await FirebaseFirestore.instance
          .collection("companies")
          .doc(companyId)
          .collection("automations")
          .get();
    } catch (error) {
      print("Error fetching automations: $error");
      return;
    }

    List<Map<String, dynamic>> automationsData = [];
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((doc) {
        var automationData = doc.data() as Map<String, dynamic>;
        print(automationData);

        if (automationData.containsKey('name') &&
            automationData.containsKey('webhook')&&
            automationData.containsKey('body')
            ) {
          String name = automationData['name'];
          String webhook = automationData['webhook'];
 String body = automationData['body'];
 String image = automationData['image']??"";
          automationsData.add({
            'name': name,
            'webhook': webhook,
             'body': body,
              'image': image,
          });
        }
      });
    } else {
      print("No automations found");
    }

    setState(() {
      automation = automationsData;
    });
  }



  Future<void> callAutomation(Map<String, dynamic> automationName) async {
    await FirebaseFirestore.instance
        .collection("companies")
        .doc(companyId)
        .collection("contacts")
        .get()
        .then((querySnapshot) {
      if (!querySnapshot.docs.isEmpty) {
        opp = querySnapshot.docs.map((doc) {
        return {
          ...doc.data(), // Keep existing data
          'selected': false, // Add 'selected' property
        };
      }).toList();
      print("Contacts loaded successfully: $opp");
       Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return BlastScreen(opp: opp,auto:automationName);
                          }));
      } else {
        print("Contacts not found");
      }
    }).catchError((error) {
      print("Error loading contacts: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Blasting",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 20,
                                           fontFamily: 'SF',
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Flexible(
          
              child: ListView.builder(shrinkWrap: true,
                itemCount: automation.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical:8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            automation[index]['name'],
                            style: TextStyle(color: Colors.white,fontSize: 14,
                                           fontFamily: 'SF',fontWeight: FontWeight.bold),
                          ),
                          subtitle:Column(
                            children: [
                              if(automation[index]['image'] != "")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius:BorderRadius.circular(8),
                                  child: Image.network(automation[index]['image'])),
                              ),
                              Text(automation[index]['body'],
                                                style: TextStyle(
                                                  color: Color(0xFFB3B3B3),
                                           fontFamily: 'SF',
                                                  fontWeight: FontWeight.w400,
                                                ),),
                            ],
                          ),
                          onTap: () {
                            
                            callAutomation(automation[index]);
                          },
                        ),
                        Divider(color:Color.fromARGB(255, 19, 19, 19),height: 2 ,)
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
