import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:juta_app/screens/add_appointment.dart';
import 'package:juta_app/screens/appointment_detail.dart';
import 'package:juta_app/screens/lead_appointment.dart';
import 'package:juta_app/utils/progress_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class Appointment extends StatefulWidget {
   final Function() openDrawerCallback;
  const Appointment({super.key,
      required this.openDrawerCallback});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  List<dynamic> appointments = [];
    int _current = 0;
  String botId = '';
  String accessToken = '';
  String workspaceId = '';
  String integrationId = '';
  User? user = FirebaseAuth.instance.currentUser;
  late PageController _pageController2;
  String email = '';
  String firstName = '';
  String company = '';
  String companyId = '';
  String calendarId = '';
  String pipelineId = '';
  String apiKey = ''; // Replace with your actual token
    List<dynamic> opp = [];
    String ghlToken = '';
    String? contactId ;
       final GlobalKey progressDialogKey = GlobalKey<State>();
    List<dynamic> pipelines = [];
    DateTime  _selectedDay  = DateTime.now();
 List<dynamic> orders = [];
 List<dynamic>materials = [];
 final ScrollController _scrollController = ScrollController();
int apple_small =0;
int apple_regular = 0;
int apple_large = 0;
int pecan_small =0;
int pecan_regular = 0;
int pecan_large = 0;
int bb_small =0;
int bb_regular = 0;
int bblarge = 0;
int pine_small =0;
int pine_regular = 0;
int pine_large = 0;
int apple_mat = 0;
double apple_cinnamon = 0;
double apple_sauce = 0;
double pecan_mat = 0;
double pecan_spice = 0;
double pecan_almond = 0;
double pecan_caramel = 0;
double bb_mat = 0;
double bb_co = 0;
double bb_sauce = 0;
String bb_crust = "";
double pine_mat = 0;
double pine_sauce = 0;
int total = 0;
DateTime _rangeStart = DateTime.now();
DateTime _rangeEnd = DateTime.now().add(Duration(days: 7));
bool pickDate = false;
  final String baseUrl = "https://api.botpress.cloud";
  Future<void> fetchConfigurations() async {
    email = user!.email!;
    await FirebaseFirestore.instance
        .collection("user")
        .doc(email)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          firstName = snapshot.get("name");
          company = snapshot.get("company");
          companyId = snapshot.get("companyId");
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
            calendarId = snapshot.get("calendarId");
            pipelineId = snapshot.get("pipelineId");
            apiKey = snapshot.get("apiKey");
            ghlToken =snapshot.get("ghlToken");
          });
          
        } else {
          print("Snapshot not found");
        }
      });
    }).then((value) => {
   FirebaseFirestore.instance
          .collection("companies")
          .doc(companyId).collection("orders")
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
orders = snapshot.docs;
          });
          for(int i = 0 ; i < orders.length;i++){
            if(orders[i]['pie'] == 'Classic Apple Pie'){
              if(orders[i]['size'].contains('Regular')){
                setState(() {
                       apple_regular= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Small')){
                setState(() {
                       apple_small= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       apple_large= orders[i]['quantity'];
                });
           
              }
            }else if(orders[i]['pie'] == 'Johnny Blueberry'){
              if(orders[i]['size'].contains('Medium')){
                setState(() {
                       bb_regular= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Small')){
                setState(() {
                       bb_small= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       bblarge= orders[i]['quantity'];
                });
           
              }
            }else if(orders[i]['pie'] == 'Lady Pineapple'){
              if(orders[i]['size'].contains('Medium')){
                setState(() {
                       pine_regular= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Small')){
                setState(() {
                       pine_small= orders[i]['quanitity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       pine_large= orders[i]['quantity'];
                });
           
              }
            }else if(orders[i]['pie'] == "Caramel 'O' Pecan"){
              if(orders[i]['size'].contains('Medium')){
                setState(() {
                       pecan_regular = orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Small')){
                setState(() {
                       pecan_small= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       pecan_large= orders[i]['quantity'];
                });
           
              }
              setState(() {
 
              });
             
            }
            total = apple_small+apple_regular+apple_large+bb_small+bb_regular+bblarge+pine_small+pine_regular+pine_large+pecan_small+pecan_regular+pecan_large;
          }
        } else {
          print("Snapshot not found");
        }
      })
    }).then((value) => {
 FirebaseFirestore.instance
          .collection("companies")
          .doc(companyId).collection("materials")
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
materials = snapshot.docs;
          });
       for(int i = 0 ; i < materials.length;i++){
       if(i == 0 ){
   
          setState(() {
            pine_mat = (pine_small * double.parse(materials[0]['pineapple']['small'].toString()))+(pine_regular * double.parse(materials[0]['pineapple']['regular'].toString())) + (pine_large * double.parse(materials[0]['pineapple']['large'].toString()));
            pine_sauce = (pine_small * double.parse(materials[0]['sauce']['small'].toString()))+(pine_regular * double.parse(materials[0]['sauce']['regular'].toString())) + (pine_large * double.parse(materials[0]['sauce']['large'].toString()));
          });
          
        }else if(i == 1){
   
          setState(() {
           bb_mat = (bb_small * double.parse(materials[1]['blueberry']['small'].toString()))+(bb_regular  * double.parse(materials[1]['blueberry']['regular'].toString())) + (bblarge * double.parse(materials[1]['blueberry']['large'].toString()));
            bb_sauce = (bb_small * double.parse(materials[1]['sauce']['small'].toString()))+(bb_regular * double.parse(materials[1]['sauce']['regular'].toString())) + (bblarge * double.parse(materials[1]['sauce']['large'].toString()));
             bb_co = (bb_small * double.parse(materials[1]['co']['small'].toString()))+(bb_regular * double.parse(materials[1]['co']['regular'].toString())) + (bblarge * double.parse(materials[1]['co']['large'].toString()));
      
          });
          
        } else if(i == 2 ){
   
          setState(() {
            apple_mat = (apple_small * int.parse(materials[2]['apple']['small'].toString()))+(apple_regular * int.parse(materials[2]['apple']['regular'].toString())) + (apple_large * int.parse(materials[2]['apple']['large'].toString()));
            apple_cinnamon = (apple_small * double.parse(materials[2]['cinnamon']['small'].toString()))+(apple_regular * double.parse(materials[2]['cinnamon']['regular'].toString())) + (apple_large * double.parse(materials[2]['cinnamon']['large'].toString()));
            apple_sauce = (apple_small * double.parse(materials[2]['sauce'].toString()))+(apple_regular * double.parse(materials[2]['sauce'].toString())) + (apple_large * double.parse(materials[2]['sauce'].toString()));
          });
          
        }else if(i == 3 ){
   
          setState(() {
            pecan_mat = (pecan_small * double.parse(materials[3]['pecan']['small'].toString()))+(pecan_regular * double.parse(materials[3]['pecan']['regular'].toString())) + (pecan_large * double.parse(materials[3]['pecan']['large'].toString()));
            pecan_spice = (pecan_small * double.parse(materials[3]['spice']['small'].toString()))+(pecan_regular * double.parse(materials[3]['spice']['regular'].toString())) + (pecan_large * double.parse(materials[3]['spice']['large'].toString()));
             pecan_almond = (pecan_small * double.parse(materials[3]['almond']['small'].toString()))+(pecan_regular * double.parse(materials[3]['almond']['regular'].toString())) + (pecan_large * double.parse(materials[3]['almond']['large'].toString()));
            pecan_caramel = (pecan_small * double.parse(materials[3]['caramel']['small'].toString()))+(pecan_regular * double.parse(materials[3]['caramel']['regular'].toString())) + (pecan_large * double.parse(materials[3]['caramel']['large'].toString()));
          });
          
        }
       }
        } else {
          print("Snapshot not found");
        }
      })
    });
  }

  @override
  void initState() {
    super.initState();
     _pageController2 = PageController();
fetchConfigurations() ;

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
    // Optionally, filter your data based on the new date range here
   
  });
   await  fetchAndFilterOrders();
}
}

void resetPieCounts() {
  setState(() {
    apple_small = apple_regular = apple_large = 0;
    bb_small = bb_regular = bblarge = 0;
    pine_small = pine_regular = pine_large = 0;
    pecan_small = pecan_regular = pecan_large = 0;
    // Reset any other counts as needed
    total = 0;
  });
}
Future<void> fetchAndFilterOrders() async {
  resetPieCounts(); // Reset counts before fetching new data

  FirebaseFirestore.instance
      .collection("companies")
      .doc(companyId)
      .collection("orders")
      .get()
      .then((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      List<QueryDocumentSnapshot> filteredOrders = snapshot.docs.where((doc) {
        // Assuming 'date' is stored as a String in Firestore
        String dateString = doc.get('date');
        DateTime orderDate = DateTime.parse(dateString);
        // Adjusting the comparison to consider the whole day range
        DateTime startOfDay = DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
        DateTime endOfDay = DateTime(_rangeEnd.year, _rangeEnd.month, _rangeEnd.day, 23, 59, 59);
        return orderDate.isAfter(startOfDay) && orderDate.isBefore(endOfDay);
      }).toList();

      setState(() {
        orders = filteredOrders;
      });

      calculatePieCounts(); // Recalculate counts based on filtered orders
    }
  }).catchError((error) {
    print("Error fetching orders: $error");
  });
}



void calculatePieCounts() {
  // Reset counts
  resetPieCounts();
print(orders.length);
   for(int i = 0 ; i < orders.length;i++){
    print(orders[i]['pie'] );
     print(orders[i]['size'] );
            if(orders[i]['pie'] == 'Classic Apple Pie'){
              if(orders[i]['size'].contains('Medium')){
                setState(() {
                       apple_regular= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Regular')){
                setState(() {
                       apple_small= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       apple_large= orders[i]['quantity'];
                });
           
              }
            }else if(orders[i]['pie'] == 'Johnny Blueberry'){
              if(orders[i]['size'].contains('Medium')){
                setState(() {
                       bb_regular= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Regular')){
                setState(() {
                       bb_small= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       bblarge= orders[i]['quantity'];
                });
           
              }
            }else if(orders[i]['pie'] == 'Lady Pineapple'){
              if(orders[i]['size'].contains('Medium')){
                setState(() {
                       pine_regular= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Regular')){
                setState(() {
                       pine_small= orders[i]['quanitity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       pine_large= orders[i]['quantity'];
                });
           
              }
            }else if(orders[i]['pie'] == "Caramel 'O' Pecan"){
              if(orders[i]['size'].contains('Medium')){
                setState(() {
                       pecan_regular = orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Regular')){
                setState(() {
                       pecan_small= orders[i]['quantity'];
                });
           
              }else if(orders[i]['size'].contains('Large')){
                setState(() {
                       pecan_large= orders[i]['quantity'];
                });
           
              }
              setState(() {
 
              });
             
            }
            total = apple_small+apple_regular+apple_large+bb_small+bb_regular+bblarge+pine_small+pine_regular+pine_large+pecan_small+pecan_regular+pecan_large;
          }
            for(int i = 0 ; i < materials.length;i++){
       if(i == 0 ){
   
          setState(() {
            pine_mat = (pine_small * double.parse(materials[0]['pineapple']['small'].toString()))+(pine_regular * double.parse(materials[0]['pineapple']['regular'].toString())) + (pine_large * double.parse(materials[0]['pineapple']['large'].toString()));
            pine_sauce = (pine_small * double.parse(materials[0]['sauce']['small'].toString()))+(pine_regular * double.parse(materials[0]['sauce']['regular'].toString())) + (pine_large * double.parse(materials[0]['sauce']['large'].toString()));
          });
          
        }else if(i == 1){
   
          setState(() {
           bb_mat = (bb_small * double.parse(materials[1]['blueberry']['small'].toString()))+(bb_regular  * double.parse(materials[1]['blueberry']['regular'].toString())) + (bblarge * double.parse(materials[1]['blueberry']['large'].toString()));
            bb_sauce = (bb_small * double.parse(materials[1]['sauce']['small'].toString()))+(bb_regular * double.parse(materials[1]['sauce']['regular'].toString())) + (bblarge * double.parse(materials[1]['sauce']['large'].toString()));
             bb_co = (bb_small * double.parse(materials[1]['co']['small'].toString()))+(bb_regular * double.parse(materials[1]['co']['regular'].toString())) + (bblarge * double.parse(materials[1]['co']['large'].toString()));
      
          });
          
        } else if(i == 2 ){
   
          setState(() {
            apple_mat = (apple_small * int.parse(materials[2]['apple']['small'].toString()))+(apple_regular * int.parse(materials[2]['apple']['regular'].toString())) + (apple_large * int.parse(materials[2]['apple']['large'].toString()));
            apple_cinnamon = (apple_small * double.parse(materials[2]['cinnamon']['small'].toString()))+(apple_regular * double.parse(materials[2]['cinnamon']['regular'].toString())) + (apple_large * double.parse(materials[2]['cinnamon']['large'].toString()));
            apple_sauce = (apple_small * double.parse(materials[2]['sauce'].toString()))+(apple_regular * double.parse(materials[2]['sauce'].toString())) + (apple_large * double.parse(materials[2]['sauce'].toString()));
          });
          
        }else if(i == 3 ){
   
          setState(() {
            pecan_mat = (pecan_small * double.parse(materials[3]['pecan']['small'].toString()))+(pecan_regular * double.parse(materials[3]['pecan']['regular'].toString())) + (pecan_large * double.parse(materials[3]['pecan']['large'].toString()));
            pecan_spice = (pecan_small * double.parse(materials[3]['spice']['small'].toString()))+(pecan_regular * double.parse(materials[3]['spice']['regular'].toString())) + (pecan_large * double.parse(materials[3]['spice']['large'].toString()));
             pecan_almond = (pecan_small * double.parse(materials[3]['almond']['small'].toString()))+(pecan_regular * double.parse(materials[3]['almond']['regular'].toString())) + (pecan_large * double.parse(materials[3]['almond']['large'].toString()));
            pecan_caramel = (pecan_small * double.parse(materials[3]['caramel']['small'].toString()))+(pecan_regular * double.parse(materials[3]['caramel']['regular'].toString())) + (pecan_large * double.parse(materials[3]['caramel']['large'].toString()));
          });
          
        }
       }

  // Finally, update the UI with the new counts
  setState(() {});
}




 


Future<List<dynamic>> fetchPipelines() async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String endpoint = '/v1/pipelines/';

  Uri uri = Uri.parse(baseUrl + endpoint);
  String token = ghlToken; // Your GoHighLevel API token

  try {
    http.Response response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
     pipelines = responseBody['pipelines'] as List<dynamic>;


      return pipelines; // Return the list of pipelines
    } else {
      print('Failed to fetch pipelines: ${response.statusCode}');
      return []; // Return an empty list in case of failure
    }
  } catch (error) {
    print('Error fetching pipelines: $error');
    return []; // Return an empty list in case of error
  }
}
Future<void> _refreshAppointments() async {
  // Fetch new appointments and update the state

   appointments.clear();

  // You can also handle exceptions and errors here
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
        child: Container(

            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, left: 10, right: 10),
        color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
        
                children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       GestureDetector(
                                  onTap: () {
                                  
                                  },
                                  child: Icon(
                                    CupertinoIcons.settings,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                        Container(
                                 height: 75,
                                 width: 75,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('assets/images/logo2.png',
                             
                                    fit: BoxFit.contain,),
                              ),
                            ),
                              GestureDetector(
                                  onTap: () {
                                  widget.openDrawerCallback();
                                  },
                                  child: Icon(
                                    CupertinoIcons.settings,
                                    color: Color(0xFF2D3748),
                                    size: 35,
                                  ),
                                ),
                      ],
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                                              'Hello, $firstName!!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'SF',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromARGB(
                                                      255, 109, 109, 109)),
                                            ),
                                             Text(
                                              'Heres the Report View.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'SF',
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromARGB(
                                                      255, 109, 109, 109)),
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

                                           
                                                Card(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.pie_chart,color:Color(0xFF0F5540)),
                                                      Text(
                                                      'Total Pies: $total',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'SF',
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color.fromARGB(
                                                              255, 109, 109, 109)),
                                                                                                  ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            Divider(),
                                              SizedBox(
                                         height: 210,
                                                child: PageView.builder(
                                                  itemCount: 4,
                                                  controller: _pageController2,
                                                  onPageChanged: (index) {
                                                    setState(() {
                                                      _current = index;
                                                    });
                                                  },
                                                  itemBuilder: ((context, index) {
                                                    return Column(
                                                      children: [
                                                        (index == 0)
                                                            ?    GestureDetector(
                                                              onTap: (){
                                                                  Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return AppointmentDetail(
                             pie:"Classic Apple Pie",
                             small:apple_small,
                             regular: apple_regular,
                             large: apple_large,
                              );
                            }));
                                                              },
                                                              child: Card(
                                                                                                            color:Color(0xFF0F5540),
                                                                                                            child: Container(
                                                                                                              height: 160,width: 300,
                                                                                                             child: Column(
                                                                                                               children: [
                                                                                                                 Center(
                                                                                                                   child: Text("Classic Apple Pie",
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                 ),
                                                                                                                 Divider(),
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Text("Small\n$apple_small",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Regular\n$apple_regular",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Large\n$apple_large",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                        Divider(),
                                                                                                               
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Text("Apple\n$apple_mat",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Cinnamon\n$apple_cinnamon",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Sauce\n$apple_sauce",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                     
                                                                                                               ],
                                                                                                             ),
                                                                                                              ),
                                                                                                          ),
                                                            )
                                                            : (index == 1)?    GestureDetector(
                                                              onTap: (){
                                                                              Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return AppointmentDetail(
                             pie:"Caramel 'O' Pecan",
                             small:pecan_small,
                             regular: pecan_regular,
                             large: pecan_large,
                              );
                            }));
                                                              },
                                                              child: Card(
                                                                                                            color:Color.fromARGB(255, 85, 64, 15),
                                                                                                            child: Container(
                                                                                                              height: 160,width: 300,
                                                                                                             child: Column(
                                                                                                               children: [
                                                                                                                 Center(
                                                                                                                   child: Text("Caramel 'O' Pecan",
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                 ),
                                                                                                                 Divider(),
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Text("Small\n$pecan_small",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Regular\n$pecan_regular",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Large\n$pecan_large",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                  
                                                                                                               
                                                                                                                        Divider(),
                                                                                                               
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                     Text("Spice\n$pecan_spice",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                    Text("Pecan\n$pecan_mat",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Almond\n$pecan_almond",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Caramel\n$pecan_caramel",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                 
                                                                                                               ],
                                                                                                             ),
                                                                                                              ),
                                                                                                          ),
                                                            ):(index == 2)?  GestureDetector(
                                                              onTap: (){
                                                                  Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return AppointmentDetail(
                             pie:"Johnny Blueberry",
                             small:bb_small,
                             regular: bb_regular,
                             large: bblarge,
                              );
                            }));
                                                              },
                                                              child: Card(
                                                                                                            color:Color.fromARGB(255, 15, 44, 85),
                                                                                                            child: Container(
                                                                                                              height: 160,width: 300,
                                                                                                             child: Column(
                                                                                                               children: [
                                                                                                                 Center(
                                                                                                                   child: Text("Johnny Blueberry",
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                 ),
                                                                                                                 Divider(),
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Text("Small\n$bb_small",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Medium\n$bb_regular",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Large\n$bblarge",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                  
                                                                                                               
                                                                                                                        Divider(),
                                                                                                               
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Text("Blueberry\n$bb_mat",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Sauce\n$bb_sauce",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Co\n$bb_co",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                 
                                                                                                               ],
                                                                                                             ),
                                                                                                              ),
                                                                                                          ),
                                                            ): GestureDetector(
                                                              onTap: (){
                                                                  Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return AppointmentDetail(
                             pie:"Lady Pineapple",
                             small:pine_small,
                             regular: pine_regular,
                             large: pine_large,
                              );
                            }));
                                                              },
                                                              child: Card(
                                                                                                            color:Color.fromARGB(255, 214, 209, 80),
                                                                                                            child: Container(
                                                                                                              height: 160,width: 300,
                                                                                                             child: Column(
                                                                                                               children: [
                                                                                                                 Center(
                                                                                                                   child: Text("Lady Pineapple",
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                 ),
                                                                                                                       Divider(color: Colors.white,),
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Text("Small\n$pine_small",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Medium\n$pine_regular",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Large\n$pine_large",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 16,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                  
                                                                                                               
                                                                                                                        Divider(color: Colors.white,),
                                                                                                               
                                                                                                                 Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                  children: [
                                                                                                                    Text("Pineapple\n$pine_mat",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),Text("Sauce\n$pine_sauce",
                                                                                                                    textAlign: TextAlign.center,
                                                                                                     style: TextStyle(
                                                                                                                    fontFamily: 'SF',
                                                                                                                    fontSize: 14,
                                                                                                                    fontWeight: FontWeight.w600,
                                                                                                                    color: Color.fromARGB(255, 255, 255, 255)),),
                                                                                                                  ],
                                                                                                                 ),
                                                                                                                 
                                                                                                               ],
                                                                                                             ),
                                                                                                              ),
                                                                                                          ),
                                                            ),
                                             
                                             Container(
                                                alignment: Alignment.bottomCenter,
                                                height: 20,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemCount: 4,
                                                    itemBuilder: (context, index) {
                                                      return Padding(
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 4),
                                                        child: Container(
                                                            width: 8.0,
                                                            height: 8.0,
                                                            decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape.circle,
                                                                color: (_current !=
                                                                        index
                                                                    ? const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        233,
                                                                        233,
                                                                        233)
                                                                    : const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        80,
                                                                        80,
                                                                        80)))),
                                                      );
                                                    }),
                                              ),
                                                Text("Tap to edit priorities",
                                                      textAlign: TextAlign.center,
                                                                                                   style: TextStyle(
                                                      fontFamily: 'SF',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color.fromARGB(255, 42, 42, 42)),),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ),
                                            if(orders.isNotEmpty)
                                            PieSalesTable(orders: orders,),
                                            
                        ],
                      ),
                    ),
                  )
                ])),
      ),
    );
  }
    Future<void> _scrollToList(DateTime selectedDate) async {
    // Filter appointments based on the selected date
    List<dynamic> filteredAppointments = appointments.where((appointment) {
      var startTime = DateTime.parse(appointment['startTime']).toLocal();
      return startTime.year == selectedDate.year &&
          startTime.month == selectedDate.month &&
          startTime.day == selectedDate.day;
    }).toList();

    // Scroll the ListView to the filtered appointments
    if (filteredAppointments.isNotEmpty) {
      int index = appointments.indexOf(filteredAppointments.first);
      await _scrollController.animateTo(index * 70,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }
}
class PieSalesTable extends StatefulWidget {
  List<dynamic> orders;
   PieSalesTable({super.key,
      required this.orders});

  @override
  _PieSalesTableState createState() => _PieSalesTableState();
}

class _PieSalesTableState extends State<PieSalesTable> {
  late String companyId;
     // Initialize a map to store quantities of each pie type for each day of the week
        Map<String, Map<String, int>> pieQuantitiesByDay = {
          'Mon': {'Classic Apple Pie': 0, 'Lady Pineapple': 0, "Caramel 'O' Pecan": 0, 'Johnny Blueberry': 0},
          'Tue': {'Classic Apple Pie': 0, 'Lady Pineapple': 0, "Caramel 'O' Pecan": 0, 'Johnny Blueberry': 0},
          'Wed': {'Classic Apple Pie': 0, 'Lady Pineapple': 0, "Caramel 'O' Pecan": 0, 'Johnny Blueberry': 0},
          'Thu': {'Classic Apple Pie': 0, 'Lady Pineapple': 0, "Caramel 'O' Pecan": 0, 'Johnny Blueberry': 0},
          'Fri': {'Classic Apple Pie': 0, 'Lady Pineapple': 0, "Caramel 'O' Pecan": 0, 'Johnny Blueberry': 0},
          'Sat': {'Classic Apple Pie': 0, 'Lady Pineapple': 0, "Caramel 'O' Pecan": 0, 'Johnny Blueberry': 0},
          'Sun': {'Classic Apple Pie': 0, 'Lady Pineapple': 0, "Caramel 'O' Pecan": 0, 'Johnny Blueberry': 0},
        };
  @override
  void initState() {
    super.initState();
    companyId = '010'; // Replace 'your_company_id' with your actual company ID
    fetchConfigurations();
  }

  Future<void> fetchConfigurations() async {
    // Your existing code to fetch user data
  
     // Process orders and update quantities for each day of the week and pie type
        for (int i = 0; i < widget.orders.length; i++) {
          print("orders"+widget.orders.toString());
          String dateString = widget.orders[i].get("date");
          DateTime orderDate = DateTime.parse(dateString);
          String day = DateFormat('E').format(orderDate);
          String pieType = widget.orders[i]['pie'];

          // Update quantity for the specific pie type and day of the week
          pieQuantitiesByDay[day]![pieType] = (pieQuantitiesByDay[day]![pieType] ?? 0) + int.parse(widget.orders[i]['quantity'].toString());
        }

        // Now you have the quantities for each pie type for each day of the week
        print(pieQuantitiesByDay);

    // Your existing code to fetch materials
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10.0,
        columns: [
          DataColumn(label: Text('Day')),
          DataColumn(label: Text('Apple')),
          DataColumn(label: Text('Pineapple')),
          DataColumn(label: Text('Pecan')),
          DataColumn(label: Text('Blueberry')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Mon')),
            DataCell(Text(pieQuantitiesByDay['Mon']!['Classic Apple Pie'].toString())),
             DataCell(Text(pieQuantitiesByDay['Mon']!['Lady Pineapple'].toString())),
           DataCell(Text(pieQuantitiesByDay['Mon']!["Caramel 'O' Pecan"].toString())),
            DataCell(Text(pieQuantitiesByDay['Mon']!['Johnny Blueberry'].toString())),
          ]),
            DataRow(cells: [
            DataCell(Text('Tue')),
            DataCell(Text(pieQuantitiesByDay['Tue']!['Classic Apple Pie'].toString())),
             DataCell(Text(pieQuantitiesByDay['Tue']!['Lady Pineapple'].toString())),
           DataCell(Text(pieQuantitiesByDay['Tue']!["Caramel 'O' Pecan"].toString())),
            DataCell(Text(pieQuantitiesByDay['Tue']!['Johnny Blueberry'].toString())),
          ]),
            DataRow(cells: [
            DataCell(Text('Wed')),
            DataCell(Text(pieQuantitiesByDay['Wed']!['Classic Apple Pie'].toString())),
             DataCell(Text(pieQuantitiesByDay['Wed']!['Lady Pineapple'].toString())),
           DataCell(Text(pieQuantitiesByDay['Wed']!["Caramel 'O' Pecan"].toString())),
            DataCell(Text(pieQuantitiesByDay['Wed']!['Johnny Blueberry'].toString())),
          ]),
           DataRow(cells: [
            DataCell(Text('Thu')),
            DataCell(Text(pieQuantitiesByDay['Thu']!['Classic Apple Pie'].toString())),
             DataCell(Text(pieQuantitiesByDay['Thu']!['Lady Pineapple'].toString())),
           DataCell(Text(pieQuantitiesByDay['Thu']!["Caramel 'O' Pecan"].toString())),
            DataCell(Text(pieQuantitiesByDay['Thu']!['Johnny Blueberry'].toString())),
          ]),
           DataRow(cells: [
            DataCell(Text('Fri')),
            DataCell(Text(pieQuantitiesByDay['Fri']!['Classic Apple Pie'].toString())),
             DataCell(Text(pieQuantitiesByDay['Fri']!['Lady Pineapple'].toString())),
           DataCell(Text(pieQuantitiesByDay['Fri']!["Caramel 'O' Pecan"].toString())),
            DataCell(Text(pieQuantitiesByDay['Fri']!['Johnny Blueberry'].toString())),
          ]),
           DataRow(cells: [
            DataCell(Text('Sat')),
            DataCell(Text(pieQuantitiesByDay['Sat']!['Classic Apple Pie'].toString())),
             DataCell(Text(pieQuantitiesByDay['Sat']!['Lady Pineapple'].toString())),
           DataCell(Text(pieQuantitiesByDay['Sat']!["Caramel 'O' Pecan"].toString())),
            DataCell(Text(pieQuantitiesByDay['Sat']!['Johnny Blueberry'].toString())),
          ]),
           DataRow(cells: [
            DataCell(Text('Sun')),
            DataCell(Text(pieQuantitiesByDay['Sun']!['Classic Apple Pie'].toString())),
             DataCell(Text(pieQuantitiesByDay['Sun']!['Lady Pineapple'].toString())),
           DataCell(Text(pieQuantitiesByDay['Sun']!["Caramel 'O' Pecan"].toString())),
            DataCell(Text(pieQuantitiesByDay['Sun']!['Johnny Blueberry'].toString())),
          ]),
          // Add more rows for other days
        ],
      ),
    );
  }
}