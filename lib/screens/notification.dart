

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:juta_app/utils/toast.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen2 extends StatefulWidget {
final Function(int) updateNotificationCount;
  NotificationScreen2({super.key, required this.updateNotificationCount, });

  @override
  State<NotificationScreen2> createState() => _NotificationScreen2State();
}

class _NotificationScreen2State extends State<NotificationScreen2> {
   List<dynamic> notifications = [];
  User? user = FirebaseAuth.instance.currentUser;
   TextEditingController nameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();
     TextEditingController locationController = TextEditingController();
      TextEditingController ukuranController = TextEditingController();
       TextEditingController cadanganController = TextEditingController();
        TextEditingController jenisController = TextEditingController();
        TextEditingController rateController = TextEditingController();
    String email = '';
      String companyId= '';
        String date = "";
  String time = "";
  String notificationId ='';
  List<dynamic> unread = [];
    @override
    void initState() {
      super.initState();
       email = user!.email!;
       getUser();
    }
Future<void> getUser() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection("user").doc(email).get();
      if (snapshot.exists) {
        companyId = snapshot.get("companyId");
      } else {
        print("Snapshot not found");
      }

      var userSnapshot = await FirebaseFirestore.instance
          .collection("user")
          .doc(email)
          .collection("Notifications")
          .orderBy("created_on", descending: true)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        notifications = userSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id; // Add document ID to data map
          return data;
        }).toList();

        setState(() {});
      } else {
        print("No documents found in Notifications subcollection");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
Future<void> markAllAsRead() async {
  try {
    // Fetch all notification documents
    QuerySnapshot notificationSnapshot = await FirebaseFirestore.instance
        .collection("user")
        .doc(email)
        .collection("Notifications")
        .get();

    // Loop through each document and update the 5th item in the notifications array
    for (var doc in notificationSnapshot.docs) {
      DocumentReference docRef = doc.reference;
      
      // Explicitly cast the data to Map<String, dynamic> to ensure the '[]' operator can be used
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      
      // Check if the 'notifications' field exists and is a list
      if (data != null && data['notifications'] is List) {
        List<dynamic> currentNotifications = data['notifications'] as List<dynamic>;
        if (currentNotifications.length > 5) {
          currentNotifications[5] = true; // Update the read status
          // Write the updated array back to the document
          await docRef.update({'notifications': currentNotifications});
        }
      }
    }

    // Update local state and UI
    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        // Check if the notification item exists and has at least 6 elements
        if (notifications[i] is List && notifications[i].length > 5) {
          notifications[i][5] = true; // Mark as read
   
        }
      }
      unread.clear();
      if (widget.updateNotificationCount != null) {
        widget.updateNotificationCount(0);
        _refresh();
      }
    });
  } catch (e) {
    print("Error updating notifications: $e");
  }
}




 @override
  Widget build(BuildContext context) {
   
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top+10,
        left: 20,

      ),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                
                    Text(
                      'Notifications',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF',
                        color: Color(0xFF2D3748),
                      ),
                    ),
                     GestureDetector(
                           onTap: markAllAsRead,
                             child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon((unread.isNotEmpty)?Icons.mark_chat_read_outlined:Icons.mark_chat_read,size: 30,color: Color(0xFF2D3748),),
                                  ),
                           ),
                  ],
                ),
              ],
            ),
          ),
        
          const SizedBox(height: 10),
          Flexible(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: notifications.isEmpty ? 1 : notifications.length,
            
                itemBuilder: (context, index) {
                  // Check if the list is empty and display a message
      if (notifications.isEmpty) {
      
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 150,),
            Icon(Icons.refresh, color: Color(0xFF2D3748),),
            Center(child: Text('No notifications available\nPull to Refresh',
            textAlign: TextAlign.center,
                                style: const TextStyle(
                                   color: Color(0xFF2D3748),
                                  fontFamily: 'SF',
                                  fontSize: 18,
                                ),)),
          ],
        );
      }
                 notifications.sort((a, b) {
  if (a['timestamp'] == null || b['timestamp'] == null) {
    return 0; // or handle accordingly
  }
  return b['timestamp'].toDate().compareTo(a['timestamp'].toDate());
});

            
                  final notification = notifications[index];
           
  final dateFormat = DateFormat('h:mm a d/M/yyyy');

  DateTime dateTime;
  if (notification['timestamp'] != null) {
    dateTime = notification['timestamp'].toDate();
  } else {
    // Handle case where sentTime is null
    // For example, set to current time or a placeholder
    dateTime = DateTime.now(); // or a placeholder date
  }
            
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      
                          Container(
                            width: 200, // Adjust width as needed
                            child: Text(
                              notification['title'] ?? "Webchat",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                       
                           Padding(
                             padding: const EdgeInsets.only(right:5.0),
                             child: Row(
                               children: [
                                         if( notification['isRead'] == false)
                        Card(
                                    color: Color(0xFF2D3748),
                                    child: Container(height: 10,width: 10,),
                                  ),
                                 Text(
                                   dateFormat.format(dateTime ) ?? "",
                                  style: const TextStyle(
                                                           color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontSize: 11,
                                  ),
                                                           ),
                                                           
                               ],
                             ),
                           ),
                              
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Name: "+notification['name'] ?? "",
                        style: const TextStyle(
                                        color: Color(0xFF2D3748),
                          fontFamily: 'SF',
                          fontWeight: FontWeight.w400,
                          fontSize: 14
                        ),
                      ),
                          Text(
                        (notification.containsKey("phone")) ?"Phone: "+notification['phone'] ?? "":(notification.containsKey("order")) ?"Order: "+notification['order'] ?? "":"",
                        style: const TextStyle(
                                        color: Color(0xFF2D3748),
                          fontFamily: 'SF',
                          fontWeight: FontWeight.w400,
                          fontSize: 14
                        ),
                      ),
                                              Divider(),
                                          
                              /*     GestureDetector(
                            onTap: (){
                       
            _launchURL("https://api.leadconnectorhq.com/widget/bookings/hanif-zainal");
                            },
                            child: Container(
                              width: double.infinity,
                              child: const Card(
                                                             color: Color(0xFF2D3748),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text("Reschedule",
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      Divider(),

                         if( notification['name'].toString().contains('Follow') && notification['deposit'] == false)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                            nameController.text = notification['lead_name'];
                            phoneNumberController.text = notification['lead_phone'];
                          });
            _submitDeposit(context,notification['id']);
                            },
                            child: Container(
                              width: double.infinity,
                              child: const Card(
                                                             color: Color(0xFF2D3748),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text("DEPOSITED",
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                        if( notification['name'].toString().contains('Follow') && notification['deposit'] == true)
                 
                       Column(
                         children: [
                               GestureDetector(
                        onTap: () async {
              _launchURL("https://sunzbuilding.ezpos.com.my/admin/projects/project");
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                                                            color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("ADD PROJECT",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                           GestureDetector(
                            onTap: () async {
                                 setState(() {
                            nameController.text = notification['lead_name'];
                            phoneNumberController.text = notification['lead_phone'];
                          });
            sendToWebhookDeposit("https://hook.us1.make.com/k2eu2js8d952qtw9a1siscerclvb1ljp");
                    await FirebaseFirestore.instance.collection('user').doc(email).collection("Notifications").doc(notificationId).delete();
                  notifications.clear();
                getUser();
                            },
                            child: Container(
                              width: double.infinity,
                              child: const Card(
                                                 color: Color(0xFF019F7D),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text("PAYED",
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),),
                                  ),
                                ),
                              ),
                            ),
                      ),
                         ],
                       ),
                       if( notification['name'].toString().contains('Site Visit'))
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            nameController.text = notification['lead_name'];
                            phoneNumberController.text = notification['lead_phone'];
                          });
                           _showSiteVisitForm();
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                                                            color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("Fill Form",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ),
                            if( notification['name'].toString().contains('Quatation')|| notification['name'].toString().contains('Quotation'))
               GestureDetector(
                        onTap: () async {
                          setState(() {
                            print(notification);
                            nameController.text = notification['lead_name'];
                            phoneNumberController.text = notification['lead_phone'];
                          });
                          _showSendQuotation();
                         
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                                                     color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("Send Quotation",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ), if( notification['name'].toString().contains('Deposit') )
               GestureDetector(
                        onTap: () async {
                          setState(() {
                            print(notification);
                            nameController.text = notification['lead_name'];
                            phoneNumberController.text = notification['lead_phone'];
                          });
                         _showSendInvoice2();
                         
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                                                     color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("Send Deposit Invoice",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                         if( notification['name'].toString().contains('Completed') )
               GestureDetector(
                        onTap: () async {
                          setState(() {
                            print(notification);
                            nameController.text = notification['lead_name'];
                            phoneNumberController.text = notification['lead_phone'];
                          });
                          _showSendInvoice();
                         
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                                                     color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("Send Complete Invoice",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ),
                       const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        color: Color.fromARGB(255, 63, 63, 63),
                        thickness: 1,
                      ),*/
                      const SizedBox(height: 10),
                     
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
     Future<void> _submitDeposit(BuildContext context,String notificationId) async {
    List<String> errors = [];

    if (errors.isEmpty) {
  await FirebaseFirestore.instance.collection('user').doc(email).collection("Notifications").doc(notificationId).update({
      'deposit':true,
    });

   sendToWebhookDeposit("https://hook.us1.make.com/jal22am9au7wzyr7t0ixjw28aid9afxv");
     
   
    }

    if (errors.isNotEmpty) {
      Toast.show(context, 'danger', errors[0]);
    }
  } Future<void> _refresh() async {
getUser();

    setState(() {
     
    });
  }
        _showSendQuotation() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
      
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
             Card(
              child: Container(
                
                  height: 600,
                  width: double.infinity,
                  child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                           Text(
                              "Company Name",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        Container(
                           decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                            child: TextField(
                                                  controller: nameController,
                                                  decoration: InputDecoration(
                              hintText: 'Company Name',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                             
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                              color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                          ),
                        ),
                        SizedBox(height: 15,),
                        Divider(),
                           Text(
                              "Phone Number (60)",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          Container(
                              decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                              child: Column(
                                children: [
                                
                                  Container(
                                   
                                    child: TextField(
                                                        controller: phoneNumberController,
                                                        decoration: InputDecoration(
                                    hintText: 'Phone Number',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.w400,
                                    ),
                                                             
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                        width: 0,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                        width: 0,
                                      ),
                                    ),
                                                        ),
                                                        style: TextStyle(
                                              color: Color(0xFF2D3748),
                                    fontSize: 16,
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                                   SizedBox(height: 15,),
                      Divider(),
                         Text(
                              "Total Price",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          Container(
                           decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                                  controller: rateController,
                                                  decoration: InputDecoration(
                              hintText: 'Total Price',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                                                      
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                                color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                            ),
                          ),
                                   
                                    SizedBox(height: 35,),
                                            GestureDetector(
                        onTap: () async {
                            sendToWebhookDeposit2("https://hook.us1.make.com/typoee9cil82oltyriudu4z5mfdmlym4");
                               await FirebaseFirestore.instance.collection('user').doc(email).collection("Notifications").doc(notificationId).delete();
                  notifications.clear();
                getUser();
                Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                               color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("Send Quotation",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  )),
            ),
          ],
        );
      },
    );
  }
      _showSendInvoice2() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
      
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
             Card(
              child: Container(
                
                  height: 600,
                  width: double.infinity,
                  child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                           Text(
                              "Company Name",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        Container(
                           decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                            child: TextField(
                                                  controller: nameController,
                                                  decoration: InputDecoration(
                              hintText: 'Company Name',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                             
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                              color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                          ),
                        ),
                        SizedBox(height: 15,),
                          Divider(),
                           Text(
                              "Phone Number (60)",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          Container(
                              decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                              child: TextField(
                                                  controller: phoneNumberController,
                                                  decoration: InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                                                       
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                                        color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                            ),
                          ),
                                   SizedBox(height: 15,),
                       Divider(),
                         Text(
                              "Total Price",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          Container(
                           decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                                  controller: rateController,
                                                  decoration: InputDecoration(
                              hintText: 'Total Price',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                                                       
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                                color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                            ),
                          ),
                                   
                                    SizedBox(height: 35,),
                                            GestureDetector(
                        onTap: () async {
                            sendToWebhookDeposit2("https://hook.eu2.make.com/opxyp55532fkcu1obp8vbv74cs771y65");
                                await FirebaseFirestore.instance.collection('user').doc(email).collection("Notifications").doc(notificationId).delete();
                  notifications.clear();
                getUser();
                Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                               color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("Send Deposit Invoice",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  )),
            ),
          ],
        );
      },
    );
  }
      _showSendInvoice() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
      
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
             Card(
              child: Container(
                
                  height: 600,
                  width: double.infinity,
                  child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          Text(
                              "Company Name",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        Container(
                           decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                            child: TextField(
                                                  controller: nameController,
                                                  decoration: InputDecoration(
                              hintText: 'Company Name',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                             
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                              color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                          ),
                        ),
                        SizedBox(height: 15,),
                         Divider(),
                         Text(
                              "Phone Number",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          Container(
                              decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                              child: TextField(
                                                  controller: phoneNumberController,
                                                  decoration: InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                                                       
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                                        color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                            ),
                          ),
                                   SizedBox(height: 15,),
                       Divider(),
                         Text(
                              "Total Price",
                              maxLines: 3,
                              style: const TextStyle(
                                color: Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          Container(
                           decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                                  controller: rateController,
                                                  decoration: InputDecoration(
                              hintText: 'Total Price',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 16,
                                fontFamily: 'SF',
                                fontWeight: FontWeight.w400,
                              ),
                                                       
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                  width: 0,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                  width: 0,
                                ),
                              ),
                                                  ),
                                                  style: TextStyle(
                                color: Color(0xFF2D3748),
                              fontSize: 16,
                              fontFamily: 'SF',
                              fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                            ),
                          ),
                                   
                                    SizedBox(height: 35,),
                                            GestureDetector(
                        onTap: () async {
                            sendToWebhookDeposit2("https://hook.us1.make.com/4ofl8n5n7uackd66zfvkdhfvgjpnk71c");
                                await FirebaseFirestore.instance.collection('user').doc(email).collection("Notifications").doc(notificationId).delete();
                  notifications.clear();
                getUser();
                Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          child: const Card(
                               color: Color(0xFF2D3748),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text("Send Invoice",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  )),
            ),
          ],
        );
      },
    );
  }
    _showSiteVisitForm() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
      
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
         
             Card(
          
               child: Container(
               
                   
                   height: 600,
                   width: double.infinity,
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                           child: Padding(
                             padding: const EdgeInsets.only(left:8.0),
                             child: TextField(
                                                   controller: nameController,
                                                   decoration: InputDecoration(
                               hintText: 'Name',
                               hintStyle: TextStyle(
                                 color: Colors.white,
                                 fontSize: 16,
                                 fontFamily: 'SF',
                                 fontWeight: FontWeight.w400,
                               ),
                              
                               enabledBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                   width: 0,
                                 ),
                               ),
                               focusedBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                   width: 0,
                                 ),
                               ),
                                                   ),
                                                   style: TextStyle(
                                 color: Color(0xFF2D3748),
                               fontSize: 16,
                               fontFamily: 'SF',
                               fontWeight: FontWeight.w400,
                                                   ),
                                                 ),
                           ),
                         ),
                                SizedBox(height: 15,), 
                           Container(
                                decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                             child: Padding(
                                   padding: const EdgeInsets.only(left:8.0),
                               child: TextField(
                                                   controller: phoneNumberController,
                                                   decoration: InputDecoration(
                               hintText: 'Phone Number',
                               hintStyle: TextStyle(
                               color: Colors.white,
                                 fontSize: 16,
                                 fontFamily: 'SF',
                                 fontWeight: FontWeight.w400,
                               ),
                                                         
                               enabledBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                   width: 0,
                                 ),
                               ),
                               focusedBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                   width: 0,
                                 ),
                               ),
                                                   ),
                                                   style: TextStyle(
                                 color: Color(0xFF2D3748),
                               fontSize: 16,
                               fontFamily: 'SF',
                               fontWeight: FontWeight.w400,
                                                   ),
                                                 ),
                             ),
                           ),
                            SizedBox(height: 15,), 
                           Container(
                                 decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                             child: Padding(
                                   padding: const EdgeInsets.only(left:8.0),
                               child: TextField(
                                                   controller: ukuranController,
                                                   decoration: InputDecoration(
                               hintText: 'Ukuran (sqft)',
                               hintStyle: TextStyle(
                                color: Colors.white,
                                 fontSize: 16,
                                 fontFamily: 'SF',
                                 fontWeight: FontWeight.w400,
                               ),
                                                         
                               enabledBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                   width: 0,
                                 ),
                               ),
                               focusedBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                   width: 0,
                                 ),
                               ),
                                                   ),
                                                   style: TextStyle(
                              color: Color(0xFF2D3748),
                               fontSize: 16,
                               fontFamily: 'SF',
                               fontWeight: FontWeight.w400,
                                                   ),
                                                 ),
                             ),
                           ),
                                 SizedBox(height: 15,),   
                           Container(
                                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                             child: Padding(
                                   padding: const EdgeInsets.only(left:8.0),
                               child: TextField(
                                                   controller: cadanganController,
                                                   decoration: InputDecoration(
                               hintText: 'Cadangan',
                               hintStyle: TextStyle(
                              color: Colors.white,
                                 fontSize: 16,
                                 fontFamily: 'SF',
                                 fontWeight: FontWeight.w400,
                               ),
                                                         
                               enabledBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                   width: 0,
                                 ),
                               ),
                               focusedBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                   width: 0,
                                 ),
                               ),
                                                   ),
                                                   style: TextStyle(
                               color: Color(0xFF2D3748),
                               fontSize: 16,
                               fontFamily: 'SF',
                               fontWeight: FontWeight.w400,
                                                   ),
                                                 ),
                             ),
                           ),
                             SizedBox(height: 15,), 
                           Container(
                                            decoration: BoxDecoration(
                            color: Color.fromARGB(255, 182, 183, 187),
                            borderRadius: BorderRadius.circular(8)
                          ),
                             child: Padding(
                                   padding: const EdgeInsets.only(left:8.0),
                               child: TextField(
                                                   controller: jenisController,
                                                   decoration: InputDecoration(
                               hintText: 'Jenis bangunan',
                               hintStyle: TextStyle(
                                      color: Colors.white,
                                 fontSize: 16,
                                 fontFamily: 'SF',
                                 fontWeight: FontWeight.w400,
                               ),
                                                         
                               enabledBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 122, 122, 122), // Remove border color
                                   width: 0,
                                 ),
                               ),
                               focusedBorder: UnderlineInputBorder(
                                 borderSide: BorderSide(
                                   color: const Color.fromARGB(0, 78, 78, 78), // Remove border color
                                   width: 0,
                                 ),
                               ),
                                                   ),
                                                   style: TextStyle(
                                    color: Color(0xFF2D3748),
                               fontSize: 16,
                               fontFamily: 'SF',
                               fontWeight: FontWeight.w400,
                                                   ),
                                                 ),
                             ),
                           ),
                                            SizedBox(height: 35,),
                                             GestureDetector(
                         onTap: () async {
                            sendToWebhook("https://hook.us1.make.com/atav5u3q9uac7abyvm4yepghr1v8wfnw");
                              await FirebaseFirestore.instance.collection('user').doc(email).collection("Notifications").doc(notificationId).delete();
      notifications.clear();
                         },
                         child: Container(
                           width: double.infinity,
                           child: const Card(
                              color: Color(0xFF2D3748),
                             child: Padding(
                               padding: EdgeInsets.all(8.0),
                               child: Center(
                                 child: Text("Submit Form",
                                     maxLines: 1,
                                     style: TextStyle(
                                       color: Colors.white,
                                       fontFamily: 'SF',
                                       fontWeight: FontWeight.bold,
                                       fontSize: 16,
                                     ),),
                               ),
                             ),
                           ),
                         ),
                       ),
                       ],
                     ),
                   )),
             ),
          ],
        );
      },
    );
  }
  //site visit
//https://hook.us1.make.com/atav5u3q9uac7abyvm4yepghr1v8wfnw

//deposit
//https://hook.us1.make.com/jal22am9au7wzyr7t0ixjw28aid9afxv
    void sendToWebhook(String webhookUrl,) async {
    try {
      Map<String, dynamic> leadData = 
      {
        'name': nameController.text,
        'phone':phoneNumberController.text,
        'ukuran':ukuranController.text,
        'cadangan':cadanganController.text,
        'jenis':jenisController.text,


      };
      var response = await http.post(
        Uri.parse(webhookUrl),
        body: leadData,
      );

   
      if (response.statusCode == 200) {

      await getUser();
      
      } else {

      }
    } catch (e) {
 
    }
  }
        void sendToWebhookDeposit2(String webhookUrl,) async {
    try {
       DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd-MM-yyyy').format(now);
      Map<String, dynamic> leadData = 
      {
        'name': nameController.text,
        'phone_number':phoneNumberController.text,
        'price':rateController.text,
        'date':formattedDate
      };
      var response = await http.post(
        Uri.parse(webhookUrl),
        body: leadData,
      );
      if (response.statusCode == 200) {
       notifications.clear();
    getUser();
      } else {

      }
    } catch (e) {
 print(e);
    }
  }
      void sendToWebhookDeposit(String webhookUrl,) async {
    try {
      Map<String, dynamic> leadData = 
      {
        'name': nameController.text,
        'phone_number':phoneNumberController.text,
      };
      var response = await http.post(
        Uri.parse(webhookUrl),
        body: leadData,
      );

   
      if (response.statusCode == 200) {
       notifications.clear();
    getUser();
      } else {

      }
    } catch (e) {
 
    }
  }
    _launchURL(String url) async {
    await launch(Uri.parse(url).toString());
  }
}