// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:juta_app/screens/contact.dart';
import 'package:juta_app/adapters/pipeline.dart';
import 'package:juta_app/screens/conversations.dart';
import 'package:juta_app/screens/notification.dart';
import 'package:juta_app/utils/progress_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../utils/toast.dart';

class Dashboard extends StatefulWidget {
  final Function() openDrawerCallback;
  final Function() conversation;
  Dashboard(
      {super.key,
      required this.openDrawerCallback,
      required this.conversation});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> records = [];
  List<dynamic> pipelines = [];

  List<FlSpot> dataPoints = [];
  List<dynamic> appointments = [];
  final String baseUrl = "https://api.botpress.cloud";
  String accessToken = ""; // Replace with your access token
  String botId = ""; // Replace with your bot ID
  String integrationId = ""; // Replace with your integration ID
  String workspaceId = '';
  String apiKey = ''; // Replace with your actual token
  int finalTotalUsers = 0;
  int finalNewUsers = 0;
  int finalReturningUsers = 0;
  int finalSessions = 0;
  int finalMessages = 0;
  List<Map<String, dynamic>> conversations = [];
  final GlobalKey progressDialogKey = GlobalKey<State>();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> users = []; // Add this line
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';
  String firstName = '';
  String company = '';
  String companyId = '';
  String ghlToken = '';
  String? nextToken = "";
  bool scrolling = false;
  List<dynamic> contacts = [];
  String searchQuery = '';
  bool showSearch = false;
  List<dynamic> notifications = [];
  @override
  void initState() {
    super.initState();
    email = user!.email!;
    init();
  }

  String onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
      showSearch = query.isNotEmpty;
    });
    return searchQuery;
  }

  Future<void> init() async {
    await getUser();

  }
 Future<String?> getFirebaseMessagingToken() async {

 
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    return await firebaseMessaging.getToken();
  }

  Future<void> refresh() async {
    await getUser();

  }

  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();
  Future<void> fetchPipelines() async {
    final String apiUrl = 'https://rest.gohighlevel.com/v1/pipelines';
    String token = ghlToken;
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> pipelines = responseData['pipelines'];

        for (var pipeline in pipelines) {
          String pipelineId = pipeline['id'];
           await fetchContactsForPipeline(pipelineId);
        }
      } else {
        throw Exception('Failed to load pipelines');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchContactsForPipeline(String pipelineId) async {
    String startAfterId = 'UIaE1WjAwWKdlyD7osQI';
    String startAfter = '1603870249758';
    int limit = 20;

    final String apiUrl =
        'https://rest.gohighlevel.com/v1/pipelines/$pipelineId/opportunities';
    String token = ghlToken; // Replace with your actual token
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    final Uri urlWithParams = Uri.parse(apiUrl).replace();

    try {
      final response = await http.get(urlWithParams, headers: headers);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        contacts = responseData['opportunities'];
        print(contacts);
        // Now you have the list of contacts for this pipeline, you can process them as needed.
        // For example, you can update a list of contacts associated with this pipeline.
        // contactsList[pipelineId] = contacts; // Assuming contactsList is a Map<String, List<dynamic>>

        setState(() {
          // Update your UI with the contacts for this pipeline.
          // You can use a slider widget or any other widget to display them.
        });
      } else {
        throw Exception('Failed to load contacts for pipeline');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchBotAnalytics() async {
    final String apiUrl =
        'https://api.botpress.cloud/v1/admin/bots/$botId/analytics';

    final Map<String, String> headers = {
      'Authorization':
          'Bearer $accessToken', // Replace with your authentication token
      'x-workspace-id': workspaceId,
    };

    final DateTime now = DateTime.now();
    final DateTime endDate = now;

    // Calculate start date (7 days ago)
    final DateTime startDate = now.subtract(Duration(days: 7));

    final Uri urlWithParams = Uri.parse(apiUrl).replace(
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );

    try {
      final response = await http.get(urlWithParams, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> analyticsData = responseData['records'];

        num totalUsers = 0;
        num newUsers = 0;
        num returningUsers = 0;
        num sessions = 0;
        num messages = 0;
        dataPoints.clear();
        for (var record in analyticsData) {
          totalUsers += record['newUsers'] + record['returningUsers'];
          newUsers += record['newUsers'];
          returningUsers += record['returningUsers'];
          sessions += record['sessions'];
          messages += record['messages'];
          DateTime date = DateTime.parse(record['startDateTimeUtc']);
          double yValue = date.millisecondsSinceEpoch.toDouble();
          double xValue = double.parse(record['newUsers'].toString()) +
              double.parse(record['returningUsers'].toString());
          FlSpot spot = FlSpot(xValue, yValue);
          dataPoints.add(spot);
        }

        setState(() {
          records = List<Map<String, dynamic>>.from(analyticsData);
          finalTotalUsers = int.parse(totalUsers.toString());
          finalNewUsers = int.parse(newUsers.toString());
          finalReturningUsers = int.parse(returningUsers.toString());
          finalSessions = int.parse(sessions.toString());
          finalMessages = int.parse(messages.toString());
        });
         await fetchPipelines();
      } else {
        throw Exception('Failed to load bot analytics');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> getUser() async {
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
         if (kIsWeb) {
    print('Running on the web!');
    // Initialize for web
  } else {
    if (companyId == "001") {
          FirebaseMessaging.instance.subscribeToTopic("JutaSoftware");
        }
    // Initialize for mobile or desktop
  }
      
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
          });
          Map<String, dynamic>? data = snapshot.data();
          //Blocked

          if (data!.containsKey("notification")) {
            notifications.addAll(snapshot.get("notification"));
          } else {
            notifications = []; // or set it to some default value
          }

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

          await fetchBotAnalytics();
        } else {
          print("Snapshot not found");
        }
      });
    });
  }

  _showAddContact() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Spacer(),
                  SizedBox(
                    width: 45,
                  ),
                  Text(
                    'New ',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'SF',
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Spacer(),
                  CupertinoButton(
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color.fromARGB(255, 109, 109, 109)),
                        child: Icon(Icons.close)),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // closing showCupertinoModalPopup
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: 180,
                width: double.infinity,
                child: Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return Contact(
                              companyId: companyId,
                            );
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      CupertinoIcons.add,
                                      color: Colors.black,
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Add Contact",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          pickCSVFile();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.import_export,
                                      color: Colors.black,
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Import Contact",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }

  Future<void> pickCSVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        String csvPath = result.files.single.path!;

        // Read and process the CSV file (similar to the previous workaround)
        String csvString = await File(csvPath).readAsString();
        List<List<String>> csvTable =
            csvString.split('\n').map((String row) => row.split(',')).toList();

        for (List<String> row in csvTable) {
          if (row.length >= 2) {
            String phoneNumber = row[0];
            String name = row[1];

            Map<String, dynamic> userData = {
              'id': phoneNumber,
              'name': name,
            };

            await addUserToFirebase(userData, companyId);
          }
        }

        Toast.show(context, "success", "Contacts imported successfully");
      }
    } catch (e) {
      Toast.show(context, "danger", "Error importing contacts: $e");
    }
  }

  Future<void> addUserToFirebase(
      Map<String, dynamic> userData, String companyId) async {
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    try {
      await FirebaseFirestore.instance
          .collection("companies")
          .doc(companyId)
          .collection("contacts")
          .doc(userData['id'])
          .get()
          .then((snapshot) async {
        if (!snapshot.exists) {
          // User doesn't exist, add them to Firebase
          await FirebaseFirestore.instance
              .collection("companies")
              .doc(companyId)
              .collection("contacts")
              .doc(userData['id'])
              .set(userData);
          setState(() {});
        }
      });
    } catch (e) {
      print("Error adding user to Firebase: $e");
    }

    ProgressDialog.unshow(context, progressDialogKey);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'SF',
        // Other default text style properties...
      ),
      child: Center(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: (accessToken != '' || apiKey != '')
              ? Builder(builder: (context) {
                  return Container(
                    color: Color.fromARGB(255, 0, 0, 0), // Background color
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 20,
                      ),
                      child: (kIsWeb)?_webView():_appView(),
                    ),
                  );
                })
              : Container(),
        ),
      ),
    );
  }
  Widget _appView(){
    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    widget.openDrawerCallback();
                                  },
                                  child: Icon(
                                    CupertinoIcons.person_circle,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                             
                                /* GestureDetector(
                                  onTap: () {
                                    _showAddContact();
                                  },
                                  child: Icon(
                                    CupertinoIcons.add,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),*/
                            
                                Row(
                                  children: [
                                    showSearch // Show search input field if showSearch is true
                                        ? Container(
                                            width: (kIsWeb)?680:180,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextField(
                                                controller: searchController,
                                                onChanged: onSearchQueryChanged,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                decoration: InputDecoration(),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    showSearch // Show search input field if showSearch is true
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showSearch = false;
                                              });
                                            },
                                            child: Icon(
                                              CupertinoIcons.xmark,
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                searchController.clear();
                                                showSearch = true;
                                              });
                                            },
                                            child: Icon(
                                              CupertinoIcons.search,
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print(notifications);
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return NotificationScreen(
                                        noti: notifications,
                                      );
                                    }));
                                  },
                                  child: Icon(
                                    CupertinoIcons.bell,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                          if (scrolling == false)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                            255, 109, 109, 109)),
                                  ),
                                  Text(company + "!",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          if (scrolling == false)
                            Container(
                              height: 100,
                              width: double.infinity,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Card(
                                        color: (index == 0)
                                            ? Color(0xFF6CD8FF)
                                            : (index == 1)
                                                ? Color(0xFFAD9CFF)
                                                : (index == 2)
                                                    ? Color(0xFFD1FA63)
                                                    : Color(0xFF019F7D),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Container(
                                              width: 155,
                                              height: 65,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    (index == 0)
                                                        ? 'Total Users \n${finalTotalUsers}'
                                                        : (index == 1)
                                                            ? 'Messages \n${finalMessages}'
                                                            : (index == 2)
                                                                ? 'Returning Users \n${finalReturningUsers}'
                                                                : 'New Users \n${finalNewUsers}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily: 'SF',
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'In the past week',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'SF',
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Contacts',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'SF',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    GestureDetector(
                                      onTap: () {
                                        widget.conversation();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('See All',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontFamily: 'SF',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                                if (contacts.isNotEmpty || pipelines.isNotEmpty)
                                  OpportunityListWidget(
                                    opportunities: contacts,
                                    onLoadMore: refresh,
                                    searchQuery: searchQuery,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
  }
  Widget _webView(){
    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    widget.openDrawerCallback();
                                  },
                                  child: Icon(
                                    CupertinoIcons.person_circle,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                SizedBox(width: 20,),
                                GestureDetector(
                                  onTap: () {
                                     Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return Conversations(
                                      
                                      );
                                    }));
                                  },
                                  child: Icon(
                                    CupertinoIcons.bubble_left,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                Spacer(),
                                /* GestureDetector(
                                  onTap: () {
                                    _showAddContact();
                                  },
                                  child: Icon(
                                    CupertinoIcons.add,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),*/
                                showSearch // Show search input field if showSearch is true
                                    ? SizedBox(
                                        width: 10,
                                      )
                                    : Container(),
                                Row(
                                  children: [
                                    showSearch // Show search input field if showSearch is true
                                        ? Container(
                                            width: 180,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextField(
                                                controller: searchController,
                                                onChanged: onSearchQueryChanged,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                decoration: InputDecoration(),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    showSearch // Show search input field if showSearch is true
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showSearch = false;
                                              });
                                            },
                                            child: Icon(
                                              CupertinoIcons.xmark,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                searchController.clear();
                                                showSearch = true;
                                              });
                                            },
                                            child: Icon(
                                              CupertinoIcons.search,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print(notifications);
                                    Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return NotificationScreen(
                                        noti: notifications,
                                      );
                                    }));
                                  },
                                  child: Icon(
                                    CupertinoIcons.bell,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                          if (scrolling == false)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                            255, 109, 109, 109)),
                                  ),
                                  Text(company + "!",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontFamily: 'SF',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          if (scrolling == false)
                            Container(
                              height: 150,
                              width: double.infinity,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Card(
                                        color: (index == 0)
                                            ? Color(0xFF6CD8FF)
                                            : (index == 1)
                                                ? Color(0xFFAD9CFF)
                                                : (index == 2)
                                                    ? Color(0xFFD1FA63)
                                                    : Color(0xFF019F7D),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Container(
                                              width: 300,
                                              height: 65,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    (index == 0)
                                                        ? 'Total Users \n${finalTotalUsers}'
                                                        : (index == 1)
                                                            ? 'Messages \n${finalMessages}'
                                                            : (index == 2)
                                                                ? 'Returning Users \n${finalReturningUsers}'
                                                                : 'New Users \n${finalNewUsers}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily: 'SF',
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'In the past week',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'SF',
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Contacts',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'SF',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    GestureDetector(
                                      onTap: () {
                                        widget.conversation();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('See All',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontFamily: 'SF',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                                if (contacts.isNotEmpty || pipelines.isNotEmpty)
                                  OpportunityListWidget(
                                    opportunities: contacts,
                                    onLoadMore: refresh,
                                    searchQuery: searchQuery,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
  }
}
