import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DeliveriesScreen extends StatefulWidget {
  @override
  _DeliveriesScreenState createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  List<dynamic> deliveries = [];
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';
  String companyId = '';
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
DateTime _rangeStart = DateTime.now();
DateTime _rangeEnd = DateTime.now().add(Duration(days: 7));
bool pickDate = false;
  @override
  void initState() {
    super.initState();
    email = user!.email!;
    fetchConfigurations();
  }

  Future<void> fetchConfigurations() async {
    email = user!.email!;
    await FirebaseFirestore.instance.collection("user").doc(email).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          companyId = snapshot.get("companyId");
        });
        fetchDeliveries();
      } else {
        print("Snapshot not found");
      }
    });
  }

Future<void> fetchDeliveries() async {
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("companies")
        .doc(companyId)
        .collection("deliveries")
        .orderBy("dateDelivery")
        .get();

    // Filter deliveries based on the selected date range after fetching
    var filteredDeliveries = querySnapshot.docs.where((doc) {
      DateTime deliveryDate = DateFormat('yyyy-MM-dd').parse(doc.get('dateDelivery'));
      return deliveryDate.isAfter(_rangeStart.subtract(Duration(days: 1))) && deliveryDate.isBefore(_rangeEnd.add(Duration(days: 1)));
    }).toList();

    setState(() {
      deliveries = filteredDeliveries;
    });
  } catch (e) {
    print("Error fetching deliveries: $e");
  }
}

  Future<void> markDeliveryAsSent(String deliveryId) async {
    await FirebaseFirestore.instance
        .collection("companies")
        .doc(companyId)
        .collection("deliveries")
        .doc(deliveryId)
        .update({"sent": true}).then((_) {
      print("Delivery marked as sent.");
    }).catchError((error) {
      print("Failed to mark delivery as sent: $error");
    });
  }

  Future<void> deleteDelivery(String deliveryId) async {
    await FirebaseFirestore.instance
        .collection("companies")
        .doc(companyId)
        .collection("deliveries")
        .doc(deliveryId)
        .delete().then((_) {
      print("Delivery deleted.");
    }).catchError((error) {
      print("Failed to delete delivery: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: Container(
          height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  
                      Text(
                        'Deliveries',
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
                     SizedBox(height: 10),
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
                     Container(
                                    child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  padding: EdgeInsets.zero,
                  itemCount: deliveries.length,
              
                  itemBuilder: (context, index) {
                    // Check if the list is empty and display a message
                    final notification = deliveries[index];
                    return GestureDetector(
                      onTap: (){
                                    
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
                                notification['dateDelivery'] ,
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
                                 'Delivery Time: ',
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
                                notification['timeDelivery'],
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
                                 notification['recipientName'] ?? "Webchat",
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
                                 'Drop Off Point: ',
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
                                notification['dropOffAddress'] ,
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
                                 'Driver: ',
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
                               notification['deliveryPerson'].toString() ,
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
                               "RM " +notification['cost'].toString() ,
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
          ],
        ),
      ),
    );
  }
  Future<void> _refresh() async {
fetchConfigurations();

    setState(() {
     
    });
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
}
