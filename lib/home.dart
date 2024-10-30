// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juta_app/screens/adduser.dart';
import 'package:juta_app/screens/dashboard.dart';
import 'package:juta_app/screens/appointment.dart';
import 'package:juta_app/screens/automation.dart';
import 'package:juta_app/screens/materials.dart';
import 'package:juta_app/screens/notification.dart';
import 'package:juta_app/screens/orders.dart';
import 'package:juta_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/conversations.dart';

class CustomTabBar extends StatefulWidget {
  final int currentIndex;
  int notificationCount;
  final Function(int) onTap;
  final Function(int) updateNotificationCount; // Add this callback

  CustomTabBar({
    required this.currentIndex,
    required this.notificationCount,
    required this.onTap,
    required this.updateNotificationCount, // Pass the callback
  });

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  List<dynamic> notifications = [];
     String email = '';
      String notificationId ='';
      User? user = FirebaseAuth.instance.currentUser;
  
  @override
  void initState() {
    super.initState();
      email = user!.email!;
    getUser();
    
  }
Future<void> getUser() async {
  try {
    final userSnapshot = await FirebaseFirestore.instance
        .collection("user")
        .doc(email)
        .collection("Notifications")
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      notifications.clear();
      int unreadCount = 0;

      for (final doc in userSnapshot.docs) {
        final notificationId = doc.id;
        final data = doc.data();
   

        if (data.containsKey("notifications")) {
          final rawNotificationList = data["notifications"];

          // Assuming each notification has 6 elements as per your data structure
          for (int i = 0; i < rawNotificationList.length; i += 6) {
            var notification = {
              'id': notificationId,
              'title': rawNotificationList[i],
              'timestamp': rawNotificationList[i + 1], // Handle timestamp conversion if needed
              'details': rawNotificationList[i + 2],
              'name': rawNotificationList[i + 3],
              'phone': rawNotificationList[i + 4],
              'isRead': rawNotificationList[i + 5]
            };
  
            if (!notification['isRead']) {
              unreadCount++;
            }

            notifications.add(notification);
          }
        }
      }

      setState(() {
        widget.notificationCount = unreadCount;
        widget.updateNotificationCount(widget.notificationCount);
      });
    } else {
      print("No documents found in Notifications subcollection");
    }
  } catch (e) {
    print("Error: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric( ),
      child: Container(height: MediaQuery.of(context).size.height *10/100,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTabItem(Icons.home_filled, 0),
                   buildTabItem(Icons.chat , 1),
                  buildTabItem(Icons.shopping_basket , 2),
                  buildTabItemNoti(Icons.delivery_dining , 3),
                   buildTabItemNoti(Icons.notifications , 4), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 Widget buildTabItemNoti(IconData icon, int index) {
  bool isSelected = index == widget.currentIndex;

  return Stack(
    children: [
      InkWell(
        onTap: () => widget.onTap(index),
        splashColor: Colors.transparent,
        child: Container(
          child: Icon(
            icon,
            size: 35,
            color: isSelected ? Colors.white : Color(0xFFB3B3B3),
          ),
        ),
      ),
      if(widget.notificationCount != 0)
      Positioned(
        right: 0,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(100),
          ),
          constraints: BoxConstraints(
            minWidth: 15,
            minHeight: 15,
          ),
          child: Text(
            '${widget.notificationCount}', // Use the notification count from the parameter
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}
  Widget buildTabItem(IconData icon, int index) {
    bool isSelected = index == widget.currentIndex;

    return InkWell(
      onTap: () => widget.onTap(index),
      splashColor: Colors.transparent,
      child: Container(
        child: Icon(
          icon,
          size: 30,
          color: isSelected ? Colors.white : Color(0xFFB3B3B3),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  int notificationCount = 0; // Add a variable to track the notification count
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';
  String firstName = '';
  String company = '';
    String accessToken = ""; // Replace with your access token
  String botId = ""; // Replace with your bot ID
  String integrationId = ""; // Replace with your integration ID
  String workspaceId = '';
  String apiKey = ''; // Replace with your actual token
    String ghlToken = '';
    String companyId = '';
    String locationId = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = user!.email!;
      
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> openDrawer() async {
    // Use a GlobalKey to access the Scaffold and open the drawer
    FirebaseFirestore.instance
        .collection("user")
        .doc(email)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          firstName = snapshot.get("name");
          company = snapshot.get("company");
             companyId = snapshot.get("companyId");
          print(firstName);
        });
      } else {
        print("Snapshot not found");
      }
    }).then((value) {
      FirebaseFirestore.instance
          .collection("companies")
          .doc(companyId)
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          setState(() {
            accessToken = snapshot.get("accessToken");
            botId = snapshot.get("botId");
            integrationId = snapshot.get("integrationId");
            workspaceId = snapshot.get("workspaceId");
            apiKey = snapshot.get("apiKey");
            ghlToken = snapshot.get("ghlToken");
            locationId = snapshot.get("locationId");
          });
          Map<String, dynamic>? data = snapshot.data();
          //Blocked

     

          await FirebaseFirestore.instance
              .collection("companies")
              .doc(companyId)
              .collection("contacts")
              .get()
              .then((querySnapshot) {
            if (!querySnapshot.docs.isEmpty) {
            } else {
              print("Contacts not found");
            }
          }).catchError((error) {
            print("Error loading contacts: $error");
          });

    final companySnapshot = await FirebaseFirestore.instance
        .collection("companies")
        .doc(companyId)
        .collection("employee")
        .get();

         
        } else {
          print("Snapshot not found");
        }
      });
    });
    _scaffoldKey.currentState?.openDrawer();
  }
 Future<void> conversationPage() async {
    // Use a GlobalKey to access the Scaffold and open the drawer
   setState(() {
      currentIndex = 1;
    });
  }

  Future<void> fetchUserData(String email) async {
    String apiKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2NhdGlvbl9pZCI6Ikxja1g3eG1yT1VCdzhqOUcyblVyIiwiY29tcGFueV9pZCI6IjUzSGdWeXh4b05VYzV0Smd3OGZLIiwidmVyc2lvbiI6MSwiaWF0IjoxNjkzOTI4ODczNTc2LCJzdWIiOiJ1c2VyX2lkIn0.U1Uxi9q5WvQZ7L4QGnmqGUGUw11Sc5VXB8FlQW_RrYE'; // Replace with your actual token
    String apiUrl = "https://rest.gohighlevel.com/v1/users/lookup?email=$email";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        // Parse the response JSON
        var userData = json.decode(response.body);
        // Now you have the user data, you can use it to populate your Drawer
        print(userData);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      drawer:(kIsWeb )? null : Drawer(
        width: 350,
        child: Container(
       
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 75,
                            width: 75,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                               color: Color(0xFF2D3748),
                            ),
  child: Center(child: Text(firstName.isNotEmpty ? firstName.substring(0, 1) : '',style: TextStyle(color: Colors.white,fontSize: 20),)),
),
                          Text(
                            firstName,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            "View Profile",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  
                     Divider( color: Color(0xFF2D3748),),
                    ListTile(
                      leading: Icon(Icons.person_add),
                      title: Text('Add Users',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                             color: Color(0xFF2D3748),
                          )),
                      onTap: () {
                        // Add your functionality for this sidebar item
  Navigator.pop(context);
                       Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return AddUser(
                                companyId:companyId,
                                apiKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55X2lkIjoiNTNIZ1Z5eHhvTlVjNXRKZ3c4ZksiLCJ2ZXJzaW9uIjoxLCJpYXQiOjE3MDkyNzYzODgxMDAsInN1YiI6IkNTdHdJdktoZlFwQWxsdEV3VUd6In0.NeN-P57GQ3Kz62wcCVlXrKjsI7g70lawxMBnbh7M2u8",
                                email: email,
                                locationId: locationId,
                                company: company,
                              );
                            }));
                      },
                    ),
                    Divider( color: Color(0xFF2D3748),),
                    ListTile(
                      leading: Icon(Icons.edit_note),
                      title: Text('Edit Materials',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                             color: Color(0xFF2D3748),
                          )),
                      onTap: () {
                        // Add your functionality for this sidebar item
  Navigator.pop(context);
                       Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return Materials(
                              
                              );
                            }));
                      },
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await AuthenticationService(auth).signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF111B21),
                        borderRadius: BorderRadius.circular(8)),
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        Text(
                          "Log Out",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF0F5540),
      body:IndexedStack(
        index: currentIndex,
        children: [
           Appointment(openDrawerCallback: openDrawer,), 
          Conversations(),
             NotificationScreen(
            updateNotificationCount:updateNotificationCount
          ),
          DeliveriesScreen(),
            NotificationScreen2(
            updateNotificationCount:updateNotificationCount
          ),
        
        ],
      ),
      bottomNavigationBar: (kIsWeb )? null :CustomTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        updateNotificationCount: updateNotificationCount,
        notificationCount:notificationCount
      ),
    );
  }
    void updateNotificationCount(int count) {
    setState(() {
      // Update the notification count
      notificationCount = count;
    });
  }
}
