

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:juta_app/screens/appointment_detail%20copy.dart';
import 'package:juta_app/screens/order_add.dart';
import 'package:juta_app/screens/order_edit.dart';
import 'package:juta_app/utils/toast.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
final Function(int) updateNotificationCount;
  NotificationScreen({super.key, required this.updateNotificationCount, });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
  DateTime _rangeStart = DateTime.now();
DateTime _rangeEnd = DateTime.now().add(Duration(days: 7));
bool pickDate = false;
    @override
    void initState() {
      super.initState();
     
     fetchConfigurations();
    }
 Future<void> fetchConfigurations() async {
    email = user!.email!;
    await FirebaseFirestore.instance
        .collection("user")
        .doc(email)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {

          companyId = snapshot.get("companyId");
        });
fetchOrders();
      } else {
        print("Snapshot not found");
      }
    });
  }
  Future<void> fetchOrders() async {
  try {
    // Fetch orders from Firestore
    var querySnapshot = await FirebaseFirestore.instance
        .collection("companies")
        .doc(companyId)
        .collection("orders")
        .orderBy("date") // Assuming 'date' is stored in a suitable format
        .get();

    // Filter orders based on the selected date range
    var filteredOrders = querySnapshot.docs.where((doc) {
      DateTime orderDate = DateFormat('yyyy-MM-dd').parse(doc.get('date')); // Adjust date format as needed
      return orderDate.isAfter(_rangeStart.subtract(Duration(days: 1)))
             && orderDate.isBefore(_rangeEnd.add(Duration(days: 1)));
    }).toList();

    setState(() {
      notifications = filteredOrders; // Assuming 'notifications' holds your orders
    });
  } catch (e) {
    print("Error fetching orders: $e");
  }
}

  Future<void> deleteOrder(String orderId) async {
  await FirebaseFirestore.instance
      .collection("companies")
      .doc(companyId)
      .collection("orders")
      .doc(orderId)
      .delete();
}
  Future<void> addPieToOrder(DocumentReference orderRef, String newPie) async {
  var order = await orderRef.get();
  if (!order.exists) return;

  var currentPie = order.get('pie');
  // Update the order with the new pie. This assumes pies are stored as a concatenated string or a list.
  // Adjust the logic based on how you actually want to store multiple pies in one order.
  await orderRef.update({
    'pie': currentPie + ", " + newPie // Example of concatenation. Consider using a list or another structure.
  });
}
  String createOrderHash(Map<String, dynamic> orderData, {List<String> exclude = const []}) {
  // Create a sorted list of keys, excluding the 'pie' field and any others specified
  var keys = orderData.keys.where((key) => !exclude.contains(key)).toList()..sort();

  // Concatenate the key-value pairs into a string
  return keys.map((key) => "$key:${orderData[key]}").join(",");
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
   
    return Scaffold(
          floatingActionButton:  Padding(
          padding: const EdgeInsets.all(4),
          child: GestureDetector(
            onTap: (){
 Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return OrderAdd(
                        companyId: companyId,
          
                            );
                          }));
            },
            child: Card(
            color: Color(0xFF2D3748),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.add,color: Colors.white,size: 25,),
              )),
          ),
                ),
      body: Container(
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
                        'Orders',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF',
                         color:Color(0xFF0F5540)
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
                        GestureDetector(
  onTap: () => _selectDateRange(context),
  child: Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, color: Color(0xFF0F5540)),
          SizedBox(width: 8), // Give some space between the icon and the text
          Text(
            (pickDate == true)?'${DateFormat('yyyy-MM-dd').format(_rangeStart)} to ${DateFormat('yyyy-MM-dd').format(_rangeEnd)}':'Select Date Range',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'SF',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 109, 109, 109)),
          ),
        ],
      ),
    ),
  ),
),
            const SizedBox(height: 10),
            Flexible(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  reverse: true,
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
              Center(child: Text('No orders available\nPull to Refresh',
              textAlign: TextAlign.center,
                                  style: const TextStyle(
                                     color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontSize: 18,
                                  ),)),
            ],
          );
        }
         
      
              
                    final notification = notifications[index];
      bool sent = notification.data().containsKey('sent') ? notification['sent'] : false;

                    return GestureDetector(
                      onTap: (){
                    
                                           Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return     OrderEdit(
                               companyId: companyId,
                               name:notification['name'] ,
                            address:notification['address'] ,
                            remarks:notification['remarks'] ,
                            delivery:notification['delivery_price'] .toString(),
                            total:notification['total'] .toString(),
                            pie:notification['pie'] ,
                            size: notification['size'],
                            quantity:notification['quantity'] ,
                            orderId: notification.id,
                                );
                              }));
                      },
                      child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                             Row(
                              
                            children: [
                          Container(
                            
                                child: Text(
                                 'No: ',
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                               (index+1) .toString(),
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ),
                          Row(
                              
                            children: [
                          Container(
                            
                                child: Text(
                                 'Delivery Date: ',
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                                notification['date'] ,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ),
                                       
                          Row(
                              
                            children: [
                          Container(
                            
                                child: Text(
                                 'Recipient: ',
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                                 notification['name'] ?? "Webchat",
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ),  Row(
                              
                            children: [
                          Container(
                            
                                child: Text(
                                 'Address: ',
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                                notification['address'] ,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ), 
                           Row(
                              
                            children: [
                          Container(
                            
                                child: Text(
                                 'Remarks: ',
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                               notification['remarks'].toString() ,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ),
                          Row(
                              
                            children: [
                          Container(
                            
                                child: Text(
                                 'Delivery Price: ',
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                               "RM " +notification['delivery_price'].toString() ,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ),
                             Row(
                              
                            children: [
                          Container(
                            
                                child: Text(
                                 'Total Price: ',
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                               "RM " +notification['total'].toString() ,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ),
                          Row(  
                              
                            children: [
                        
                              Container(
                          
                                child: Text(
                                '-'+notification['pie'] +" "+notification['size']+' X'+notification['quantity'].toString(),
                            
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'SF',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                           
                                  
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                        
                            children: [
                                       if(sent == false)
                              GestureDetector(
                                onTap: () async {
                         
showDeliveryDetailsDialog(context,notification);
_refresh();
  },
                                child: Card(
                                  color: Color(0xFF0F5540),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Send Delivery",style: TextStyle(color: Colors.white),),
                                  ),
                                ),
                              ),
SizedBox(width: 25,),
                              GestureDetector(
                                onTap: (){
                                         Navigator.of(context)
                                  .push(CupertinoPageRoute(builder: (context) {
                                return     OrderEdit(
                               companyId: companyId,
                               name:notification['name'] ,
                            address:notification['address'] ,
                            remarks:notification['remarks'] ,
                            delivery:notification['delivery_price'] .toString(),
                            total:notification['total'] .toString(),
                            pie:notification['pie'] ,
                            size: notification['size'],
                            quantity:notification['quantity'] ,
                            orderId: notification.id,
                                );
                              }));
                                },
                                child: Card(
                                  color: Color.fromARGB(255, 135, 135, 135),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Edit",style: TextStyle(color: Colors.white),),
                                  ),
                                ),
                              ),
                              SizedBox(width: 25,),
                               GestureDetector(
                               onTap: (){
                                 deleteOrder(notification.id);
                                 _refresh();
                               },
                                 child: Card(
                                  color: Colors.redAccent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Delete",style: TextStyle(color: Colors.white),),
                                  ),
                                                               ),
                               ),
                            ],
                          ) ,   
                          Divider(),
                      
                           
                         
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
fetchConfigurations();

    setState(() {
     
    });
  }
  Future<void> showDeliveryDetailsDialog(BuildContext context, DocumentSnapshot notification) async {
  // Form controllers
  final TextEditingController deliveryPersonController = TextEditingController();
  final TextEditingController timeDeliveryController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController dropOffAddressController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();

  // Assuming you have companyId and orderId available

  final String orderId = notification.id; // Assuming this is how you get the order ID

  // Example for prefilling recipient name and address from notification if applicable
  recipientNameController.text = notification['name']; 
  dropOffAddressController.text = notification['address']; 
costController.text = notification['delivery_price'].toString();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to close dialog
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Enter Delivery Details', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: deliveryPersonController,
                decoration: InputDecoration(
                  labelText: "Delivery Person Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: timeDeliveryController,
                decoration: InputDecoration(
                  labelText: "Time of Delivery",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Delivery Cost",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: dropOffAddressController,
                decoration: InputDecoration(
                  labelText: "Drop-off Address",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: recipientNameController,
                decoration: InputDecoration(
                  labelText: "Recipient Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Confirm', style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              // Preparing delivery data
              Map<String, dynamic> deliveryData = {
                'deliveryPerson': deliveryPersonController.text,
                'dateDelivery':notification['date'],
                'timeDelivery': timeDeliveryController.text,
                'pickupLocation': "TTDI",
                'cost': double.parse(costController.text),
                'dropOffAddress': dropOffAddressController.text,
                'recipientName': recipientNameController.text,
                'orderId': orderId, // Linking the delivery to its order
                'createdOn': FieldValue.serverTimestamp(), // Firestore server timestamp
              };

              // Add delivery data to Firestore
              await FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .collection('deliveries')
                  .add(deliveryData)
                  .then((docRef) async {
                    print("Delivery added with ID: ${docRef.id}");
                    
                    // Update the order to mark it as sent
                    await FirebaseFirestore.instance
                        .collection('companies')
                        .doc(companyId)
                        .collection('orders')
                        .doc(orderId)
                        .update({'sent': true})
                        .then((_) => print("Order marked as sent"))
                        .catchError((error) => print("Failed to update order: $error"));
                  })
                  .catchError((error) {
                    print("Failed to add delivery: $error");
                  });

              Navigator.of(dialogContext).pop(); // Close the dialog after submitting
            },
          ),
        ],
      );
    },
  );
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
                fetchConfigurations();
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
    Future<void> _selectDateRange(BuildContext context) async {
final DateTimeRange? picked = await showDialog(
  context: context,
  builder: (context) => Theme(
    data: ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: Color(0xFF0F5540), // This is the main color for the picker
        onPrimary: Colors.white, // This is the color of text and icons on the primary color
        surface: Colors.white, // Background color of the picker
        onSurface: Colors.black, // Text color on the background
      ),
      dialogBackgroundColor: Colors.white, // Background color of the dialog
    ),
    child: DateRangePickerDialog(
      initialDateRange: DateTimeRange(start: _rangeStart, end: _rangeEnd),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    ),
  ),
);

if (picked != null ) {
  setState(()  {
    _rangeStart = picked.start;
    _rangeEnd = picked.end;
    pickDate = true;
    // Optionally, filter your data based on the new date range here
   _refresh();
  });

}
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
                fetchConfigurations();
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
                fetchConfigurations();
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

      await fetchConfigurations();
      
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
    fetchConfigurations();
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
    fetchConfigurations();
      } else {

      }
    } catch (e) {
 
    }
  }
    _launchURL(String url) async {
    await launch(Uri.parse(url).toString());
  }
}