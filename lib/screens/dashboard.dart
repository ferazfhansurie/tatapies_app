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
import 'package:juta_app/screens/automation.dart';
import 'package:juta_app/screens/blast.dart';
import 'package:juta_app/screens/contact.dart';
import 'package:juta_app/adapters/pipeline.dart';
import 'package:juta_app/screens/contact_detail.dart';
import 'package:juta_app/screens/conversations.dart';
import 'package:juta_app/screens/orders.dart';
import 'package:juta_app/screens/tags.dart';
import 'package:juta_app/utils/progress_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../utils/toast.dart';

class Dashboard extends StatefulWidget {
  final Function() openDrawerCallback;
  final Function() conversation;
  final Function(int) updateNotificationCount;
  Dashboard(
      {super.key,
      required this.openDrawerCallback,
      required this.conversation, required this.updateNotificationCount,});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> records = [];
  List<dynamic> pipelines = [];
  List<dynamic> allUsers = [];
  List<FlSpot> dataPoints = [];
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
   bool _isLoadingData = true; 
   ScrollController _scrollController = ScrollController();
    String nextTokenConversation = '';
  String nextTokenUser = '';
  String filter = "";
   List<dynamic> opportunities = [];
   int unclosed =0;
   double closingRate=0;
   int answered = 0;
String pipelineId ="";
List<String> employees = [];
List<dynamic> filteredOpportunities = []; 
int selectFilter = 0;
String stageId="";
bool hide = false;
bool select = false;
Set<int> selectedIndices = Set<int>();
 List<Map<String, dynamic>> automation = [];
 List <String> selectedId =[];
List opp = [];
bool isDoneLoading = false;
String messageToken = "";
  @override
  void initState() {
    super.initState();
    email = user!.email!;
    init();
  }
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

String onSearchQueryChanged(String query) {
  setState(() {
    searchQuery = query;
    showSearch = query.isNotEmpty;

    // Filter opportunities based on the search query for both name and phone
    filteredOpportunities = opportunities.where((opportunity) {
      // Convert the query to lowercase for case-insensitive comparison
      String lowerQuery = query.toLowerCase();

      // Access name from the opportunity and convert to lowercase
      String name = opportunity['name'].toLowerCase();

      // Access phone from the nested contact field and convert to lowercase
      String phone = (opportunity['contact']?['phone'] ?? "").toLowerCase();

      // Check if either name or phone contains the query
      return name.contains(lowerQuery) || phone.contains(lowerQuery);
    }).toList();
  });
  return searchQuery;
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
    _showAutomations(automation);
  }
  _showAutomations(List<Map<String, dynamic>> automation) {
    showCupertinoModalPopup(
      context: context,
      
      builder: (BuildContext context) {
        return Container(
          child:  Material(
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
                              style: TextStyle(fontSize: 18,
                                             fontFamily: 'SF',
                            fontWeight: FontWeight.bold,
                             color: Color(0xFF2D3748)),
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
                                Card(
                                  color: Color(0xFF0D85FF),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(automation[index]['body'],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Color.fromARGB(255, 255, 255, 255),
                                                 fontFamily: 'SF',
                                                        fontWeight: FontWeight.w400,
                                                      ),),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                             Navigator.pop(context);
                        var yes =    await   Navigator.of(context)
                                .push(CupertinoPageRoute(builder: (context) {
                              return BlastScreen(opp: opp,auto:automation[index],from:0);
                            }));
                            if(yes = true){
 
 setState(() {
   opp.clear();
 selectedIndices.clear();
 });
                            }
                            
                            },
                          ),
                          Divider(color:Color.fromARGB(255, 19, 19, 19),height: 2 ,)
                        ],
                      ),
                    );
                  },
                ),
          ),
        );
      },
    );
  }
  Future<void> init() async {
await getUser();
 await listenNotification();
var statusStorage = await Permission.storage.request();
  var permissionStorageStatus = await Permission.storage.status;
  print(permissionStorageStatus);
  }
  
 Future<String?> getFirebaseMessagingToken() async {

 
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    return await firebaseMessaging.getToken();
  }
  Future<void> refresh() async {
   await  listenNotification();

   
  }
Future<void> listenNotification() async {
  int count = 0;
     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
     count++;
      widget.updateNotificationCount(count);
      });
}
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();
 
Future<String> extractContactId(String phone) async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String lookupEndpoint = '/v1/contacts/lookup';
  String contact = "+$phone";
  String token = ghlToken; // Replace with your actual token
  String contactId = "";

  try {
    Uri uri = Uri.parse('$baseUrl$lookupEndpoint?phone=$contact');
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    http.Response response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      // Parse the response body and extract tags
      Map<String, dynamic> responseData = json.decode(response.body);

      // Check if the "contacts" key exists and extract tags
      if (responseData.containsKey('contacts')) {
        List<dynamic> contacts = responseData['contacts'];
        for (var contact in contacts) {
          if (contact.containsKey('id')) {
            contactId = contact['id'];
          }
        }
      } else {
        print('No contacts found in the response.');
      }
    } else {
      // Handle error response
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (error) {
    // Handle exceptions or errors during the request
    print('Error: $error');
  }

  return contactId;
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

  // Function to initiate the fetch of opportunities from the first pipeline
Future<void> fetchOpportunitiesFromFirstPipeline() async {
   opportunities.clear();
  pipelines = await fetchPipelines();
  
  if (pipelines.isNotEmpty) {
    String firstPipelineId = pipelines[0]['id'];
    setState(() {
  stageId = pipelines[0]['stages'][0]['id'].toString();
});
print("stageId" + stageId);
    opportunities = await fetchAllOpportunitiesFromPipeline(firstPipelineId, maxOpportunities: 20);
      
  setState(() {
      unclosed = opportunities.length - countWonOpportunities(opportunities);
      closingRate =  (countWonOpportunities(opportunities) / opportunities.length ) * 100;
        _isLoadingData = false;
        filteredOpportunities = List.from(opportunities);
         pipelineId = pipelines[0]['id']; 
      });

    // Fetch the rest of the opportunities in the background
    
     opportunities.addAll(await fetchAllOpportunitiesFromPipeline(firstPipelineId)) ;
     
    setState(() {
      unclosed = opportunities.length - countWonOpportunities(opportunities);
      closingRate =  (countWonOpportunities(opportunities) / opportunities.length ) * 100;
        _isLoadingData = false;
        filteredOpportunities = List.from(opportunities);
         pipelineId = pipelines[0]['id']; 
      });
  }
}
  int countWonOpportunities(List<dynamic> opportunities) {
  return opportunities.where((opportunity) => opportunity['status'] == 'won').length;
}
Future<List<dynamic>> fetchAllOpportunitiesFromPipeline(String pipelineId, {int? maxOpportunities}) async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String endpoint = '/v1/pipelines/$pipelineId/opportunities';
  String token = ghlToken; // Your GoHighLevel API token
  List<dynamic> allOpportunities = [];
  String? nextPageUrl;
  int fetchedOpportunities = 0;
 opportunities.clear();
  do {
    Uri uri = nextPageUrl == null ? Uri.parse(baseUrl + endpoint) : Uri.parse(nextPageUrl);

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
        List<dynamic> opportunities = responseBody['opportunities'] ?? [];
        nextPageUrl = responseBody['meta']['nextPageUrl'];

        allOpportunities.addAll(opportunities);
        fetchedOpportunities += opportunities.length;

        // Check if maximum number of opportunities has been reached
        if (maxOpportunities != null && fetchedOpportunities >= maxOpportunities) {
          break;
        }

        if (opportunities.isEmpty) {
          setState(() {
            isDoneLoading = true;
          });
          break;
        }
      } else {
        print('Failed to fetch opportunities: HTTP ${response.statusCode} - ${response.reasonPhrase}');
        break; // Exit the loop on failure
      }
    } catch (error) {
      print('Error fetching opportunities: $error');
      break; // Exit the loop on exception
    }
  } while (nextPageUrl != null);

  return allOpportunities;
}
Future<List<String>> extractTagsFromResponse(String phone) async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String lookupEndpoint = '/v1/contacts/lookup';
  String contact = "+$phone";
  String token = ghlToken; // Replace with your actual token
  List<String> tags = [];

  try {
    Uri uri = Uri.parse('$baseUrl$lookupEndpoint?phone=$contact');
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    http.Response response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      // Parse the response body and extract tags
      Map<String, dynamic> responseData = json.decode(response.body);

      // Check if the "contacts" key exists and extract tags
      if (responseData.containsKey('contacts')) {
        List<dynamic> contacts = responseData['contacts'];
        for (var contact in contacts) {
          if (contact.containsKey('tags')) {
            List<dynamic> contactTags = contact['tags'];
            tags.addAll(contactTags.map((tag) => tag.toString()));
          }
        }
      } else {
        print('No contacts found in the response.');
      }
    } else {
      // Handle error response
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (error) {
    // Handle exceptions or errors during the request
    print('Error: $error');
  }

  return tags;
}
  
 void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has reached the end of the list, load more conversations
      _loadMoreConversations();
    }
  }
    void _loadMoreConversations() async {
    if (_isLoadingData) return; // Prevent multiple simultaneous requests
    setState(() {
      _isLoadingData = true;
    });

    try {
      
       await  fetchOpportunitiesFromFirstPipeline();

    
    } catch (e) {
    } finally {
      
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
        if(email.contains('sales')){
  FirebaseMessaging.instance.subscribeToTopic(companyId+"-sales");
        }else if(email.contains('tech')){
FirebaseMessaging.instance.subscribeToTopic(companyId+"-tech"); 
        }else if(email.contains('admin')){
          FirebaseMessaging.instance.subscribeToTopic(companyId+"-admin");
        }
           FirebaseMessaging.instance.subscribeToTopic(companyId);

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

    if (companySnapshot.docs.isNotEmpty) {
      // Clear the notifications list before adding data from documents
      employees.clear();

      for (final doc in companySnapshot.docs) {
    
        final data = doc.data();
      employees.add(data['name']);
    
        setState(() {
          
        });
      }

    
    } else {
      print("No documents found in Employee subcollection");
    }
              await fetchConfigurations();
        } else {
          print("Snapshot not found");
        }
      });
    });
  }
  _showNotMessaged(  
    List<dynamic> labels ,
  String name,
  String phone,
  String contactId,
  String conversationId,
  Map<String,dynamic> opportunity
) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                Text("The user hasnt responded yet",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'SF',
                                      color: Color(0xFF020913))),
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
                height: 350,
                width: double.infinity,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50,),
                      GestureDetector(
                        onTap: () {
                          
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Color(0xFF2D3748)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      CupertinoIcons.person,
                                      color: Colors.white,
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text("View Contact",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      color: Color(0xFF020913))),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: () {
                         
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Color(0xFF2D3748)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Send Message",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      color: Color(0xFF020913))),
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
  _showAddContact() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                  color: Colors.white,
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
                        apiKey: ghlToken,
                        pipelineId: pipelineId,
                        stageId: stageId,
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
                                      color: Color(0xFF2D3748)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      CupertinoIcons.add,
                                      color: Colors.white,
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Add Contact",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      color: Color(0xFF020913))),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
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
                                      color: Color(0xFF2D3748)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.import_export,
                                      color: Colors.white,
                                    ),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Import Contact",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      color: Color(0xFF020913))),
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
      ),
      child: Center(
        child: Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: (){
  _showAddContact();
          },
          child: Card(
          color: Color(0xFF2D3748),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.add,color: Colors.white,size: 30,),
            )),
        ),
      ),
          body: (accessToken != '' || apiKey != '')
              ? Builder(builder: (context) {
                  return Container(
                
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 20,
                      ),
                      child: SingleChildScrollView(child: _appView()),
                    ),
                  );
                })
              : Container(),
        ),
      ),
    );
  }
  Future<Map<String, dynamic>?> getOrCreateConversation(String channel, Map<String, dynamic> tags) async {
  String url = 'https://api.botpress.cloud/v1/chat/conversations/get-or-create';

  try {
    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'x-bot-id': botId,
        'x-integration-id': integrationId,
      },
      body: json.encode({
        'channel': 'channel',
        'tags': tags,
      }),
    );
print(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      return responseBody['conversation'] as Map<String, dynamic>?;
    } else {
      print('Failed to get or create conversation. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error in getOrCreateConversation: $e');
    return null;
  }
}

Future<List<Map<String, dynamic>>> fetchConversations(String matchingPhone) async {
  List<Map<String, dynamic>> allConversations = [];
bool found = false;
  String nextToken = "";
  try {
    do {
      String url = 'https://api.botpress.cloud/v1/chat/conversations';
      if (nextToken.isNotEmpty) {
        url += '?nextToken=$nextToken';
      }

      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'x-bot-id': botId,
          'x-integration-id': integrationId,
        },
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        List<dynamic> conversations = responseBody['conversations'];
        allConversations.addAll(conversations.whereType<Map<String, dynamic>>());
        
        // Assuming the API provides a 'nextToken' for pagination
        nextToken = responseBody['meta']['nextToken'] ?? "";
        print(nextToken);
        for(int i = 0 ; i <conversations.length;i++){
          if (conversations[i]['tags'] != null &&
          conversations[i]['tags']['whatsapp:userPhone'] == matchingPhone) {
      setState(() {
        found= true;
      });
        break; // Exit the loop when a match is found
      }
        }
        if(found == true){
           break; // Exit the loop when a match is found
        }
      } else {
        print('Failed to load conversations. Status code: ${response.statusCode}');
        throw Exception('Failed to load conversations');
      }
    } while (nextToken.isNotEmpty);

    return allConversations;
  } catch (e) {
    print('Error fetching conversation details: $e');
    throw Exception('Error fetching conversation details: $e');
  }
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
                                    color: Color(0xFF2D3748),
                                    size: 35,
                                  ),
                                ),
                             
                               
                            Spacer(),
                      
                                Row(
                                  children: [
                                    showSearch // Show search input field if showSearch is true
                                        ? Container(
                                            width: MediaQuery.of(context).size.width *60/100,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xFF020913)),
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
                                                    color: Color(0xFF2D3748)),
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
                                                searchController.clear();
                                                onSearchQueryChanged("");
                                              });
                                            },
                                            child: Icon(
                                              CupertinoIcons.xmark,
                                              color: Color(0xFF2D3748),
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
                                              color: Color(0xFF2D3748),
                                              size: 35,
                                            ),
                                          ),
                                  ],
                                ),
                               SizedBox(
                                      width: 10,
                                    ),
                             
                              ],
                            ),
                          ),
                         
                            Padding(
                              padding: const EdgeInsets.only(top:8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontFamily: 'SF',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                            255, 109, 109, 109)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 275,
                                        child: Text(company + "!",
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: 'SF',
                                                
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2D3748))),
                                      ),
                                               Padding(
                                      padding: const EdgeInsets.only(right:8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                       
                                        setState(() {
                                           hide =!hide;
                                        });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text((hide == false)?'Hide':"Open",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontFamily: 'SF',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2D3748))),
                                        ),
                                      ),
                                    ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                       if(hide == false)
                            Container(
                              height: 105,
                              width: double.infinity,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Card(
                                        color: Color(0xFF2D3748),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Container(
                                              width: 155,
                                              height: 55,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    (index == 0)
                                                        ? 'Closed \n${countWonOpportunities(opportunities)}'
                                                        : (index == 1)
                                                            ? 'Unclosed \n${unclosed}'
                                                            : (index == 2)
                                                                ? 'Leads \n${opportunities.length}'
                                                                : 'Closing Rate \n${closingRate.toStringAsFixed(2)}%',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'SF',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                            fontSize: 22,
                                            fontFamily: 'SF',
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D3748))),
                                             Padding(
                                      padding: const EdgeInsets.only(right:8.0),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                          
                                            setState(() {
                                                select = !select;
                                                if(select == false){
                                              selectedIndices.clear();
                                              selectedId.clear();
                                              opp.clear();
                                            }
                                            });
                                            
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text((select == false)?'Select':"Cancel",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      decoration:
                                                          TextDecoration.underline,
                                                      fontFamily: 'SF',
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF2D3748))),
                                            ),
                                          ),
                                          if(select == true)
                                    GestureDetector(
                                      onTap: () {
                            Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return TagScreen(
                         contactId: selectedId,
                         accessToken: ghlToken,
                          label:[]
                            );
                          }));
                                     
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.new_label,color: Color(0xFF2D3748),size: 35,),)),
                                             if(select == true)
                                    GestureDetector(
                                      onTap: () {
                                   getAutomations();
                                     
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.send,color: Color(0xFF2D3748),size: 35,),
                                      ),
                                    ),
                                        ],
                                      ),
                                    ),
                                 
                                   
                                  ],
                                ),
                                if(isDoneLoading == true)
                                  Container(
                            height: 36,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: employees.length +1,
                              itemBuilder: ((context, tagIndex) {
                                return GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      selectFilter = tagIndex;
                                    });
                                    onEmployeeSelected(selectFilter);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2),
                                    child: Card(
                                      color:(selectFilter == tagIndex)? Color.fromARGB(255, 83, 93, 110):Colors.white,
                                      child: Container(
                                        width: 100,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            (tagIndex == 0)?"All":employees[tagIndex -1],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: (selectFilter == tagIndex)? Colors.white:Color.fromARGB(255, 83, 93, 110),
                                              fontFamily: 'SF',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          
                                    Container(
                                      height:
                                      (hide == true)?MediaQuery.of(context).size.height *55/100:(select == false)?
                                    MediaQuery.of(context).size.height *43/100:MediaQuery.of(context).size.height *42/100,
              child: RefreshIndicator(
                color: Colors.black,
                onRefresh: _handleRefresh,
                child: _isLoadingData
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2D3748),
                  ),
                )
              :ListView.builder(
  controller: _scrollController,
  padding: EdgeInsets.zero,
  itemCount: filteredOpportunities.length,
  physics: AlwaysScrollableScrollPhysics(),
  itemBuilder: (context, index) {
    var opportunity = filteredOpportunities[index];
    String userName = opportunity['contact']?['name'] ?? 'N/A';
    String number = opportunity['contact']?['phone'] ?? 'N/A';

    List<dynamic> tags = opportunity['contact']?['tags'] ?? [];
     bool isSelected = selectedIndices.contains(index);
    String phone = opportunity['contact']['phone'] ?? "N/A";
    phone = phone.replaceAll('+', ''); // Remove all '+' signs
  var contactId = opportunity['contact']['id'];
    return GestureDetector(
      onTap: () async {
        if(select == false){
ProgressDialog.show(context, progressDialogKey);
  // Fetch the conversation details based on the opportunity

  
  var conversations2 = await getOrCreateConversation("WhatsApp",{"whatsapp:userPhone":phone});

  // Check if conversations is null before proceeding
  if (conversations2 != null) {
    // Find the specific conversation
    Map<String, dynamic>? specificConversation; // Declare as nullable

    // Iterate through the conversations list to find a match based on phone
  specificConversation = conversations2;
print(specificConversation);
if (specificConversation != null) {
 String conversationId = specificConversation['id'];
  var messages = await listMessages(conversationId); // Fetch messages by conversation ID

  // Retrieve the existing conversation tags
  Map<String, dynamic> conversationTags = specificConversation['tags'] ?? {};

  // Add 'whatsapp:name' to the conversation tags with the value of 'username'
  var newEntry = MapEntry('whatsapp:name', userName);
  List<MapEntry<String, dynamic>> newEntries = [newEntry];

  // Add the new entries to the existing tags
   specificConversation.addEntries(newEntries);

  // Update the conversation with the new tags
  specificConversation['tags'] = conversationTags;
  ProgressDialog.hide(progressDialogKey);
  // Navigate to the message screen with all the details
  if(messages.isNotEmpty){
  navigateToMessageScreen(
     opportunity,
    messages,
    specificConversation,
    conversationId,
    tags,
    contactId,
   
  );
  }else{
      setState(() {
 
            opp.add(filteredOpportunities[index]);
    });
     Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return ContactDetail(
                            labels: tags,
                            name: userName,
                            phone: phone,
                            accessToken: ghlToken,
                            contactId: contactId,
                            integrationId: integrationId,
                            botId: botId,
                            conversation: "",
                             botToken: accessToken,
                            pipelineId: pipelineId,
                            opportunity: filteredOpportunities[index],
                            );
                          }));

      print("No matching conversation found for phone number: $phone");
  }

} else {
     ProgressDialog.hide(progressDialogKey);
    setState(() {
 
            opp.add(filteredOpportunities[index]);
    });
     Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return ContactDetail(
                            labels: tags,
                            name: userName,
                            phone: phone,
                            accessToken: ghlToken,
                            contactId: contactId,
                            integrationId: integrationId,
                            botId: botId,
                            conversation: "",
                             botToken: accessToken,
                            pipelineId: pipelineId,
                            opportunity: filteredOpportunities[index],
                            );
                          }));

      print("No matching conversation found for phone number: $phone");
    }
  } else {
       ProgressDialog.hide(progressDialogKey);
         setState(() {
 
            opp.add(filteredOpportunities[index]);
    });
     Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return ContactDetail(
                            labels: tags,
                            name: userName,
                            phone: phone,
                            accessToken: ghlToken,
                            contactId: contactId,
                            integrationId: integrationId,
                            botId: botId,
                            conversation: "",
                             botToken: accessToken,
                            pipelineId: pipelineId,
                            opportunity: filteredOpportunities[index],
                            );
                          }));
 
  }

        }else{
         if (isSelected) {
          // Item is already selected, so deselect it
          setState(() {
            selectedIndices.remove(index);
                  selectedId.remove(contactId);
            opp.remove(filteredOpportunities[index]);
          });
        } else {
          // Item is not selected, so select it
          setState(() {
            selectedIndices.add(index);
            selectedId.add(contactId);
            opp.add(filteredOpportunities[index]);
             print(opp);
          });
        }
        }

      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Color.fromARGB(255, 83, 93, 110) : Colors.transparent
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Color(0xFF2D3748),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName,
                              maxLines: 1,
                              style: TextStyle(
                                color: isSelected ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF2D3748),
                                fontFamily: 'SF',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: AlwaysScrollableScrollPhysics(),
                           
                              itemCount: tags.length,
                              itemBuilder: ((context, tagIndex) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Card(
                                    color: Color(0xFF2D3748),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        tags[tagIndex],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF',
                                      
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                      Text(
                        number ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:TextStyle(
                                                      color: isSelected ? Color.fromARGB(255, 255, 255, 255) : Color(0xFF2D3748),
                                                         fontFamily: 'SF',
                                                         fontSize: 15,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                      ),
                     
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
)
              ),
            ),
                              ],
                            ),
                          ),
                        ],
                      );
  }

    Future<void> _handleRefresh() async {
      setState(() {
        _isLoadingData = true;
      });
  opportunities.clear();
    await getUser();
   
  }void onEmployeeSelected(int selectedEmployeeIndex) {
  setState(() {
    selectFilter = selectedEmployeeIndex;
    if (selectedEmployeeIndex == 0) {
      // Show all opportunities if 'All' is selected
      filteredOpportunities = opportunities;
    } else {
      // Get the selected employee's name
      String selectedEmployeeName = employees[selectedEmployeeIndex - 1];

      // Filter opportunities that include the selected employee's name in their tags
      filteredOpportunities = opportunities.where((opportunity) {
        // Assuming each opportunity has a 'tags' field which is a list of strings
        List<dynamic> opportunityTags = opportunity['contact']['tags'] ?? [];
  
        return opportunityTags.contains(selectedEmployeeName);
      }).toList();
    }
  });
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
          firstName = snapshot.get("name");
          company = snapshot.get("company");
          companyId = snapshot.get("companyId");
        });
     
      } else {
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
          });
       
       await fetchOpportunitiesFromFirstPipeline();
         
        } else {
        }
           
      });
    });
   
  }
  
    _launchURL(String url) async {
    await launch(Uri.parse(url).toString());
  }
  
    Future<String> getLatestMessage(String conversationId) async {
    String url = '$baseUrl/v1/chat/messages?conversationId=$conversationId';

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'x-bot-id': botId,
        'x-integration-id': integrationId,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> messages = responseBody['messages'];

      if (messages.isNotEmpty) {
        String latestMessage = "";
        for (var i = messages.length - 1; i >= 0; i--) {
          latestMessage = messages[i]['payload']['text']??"";
        }

        return latestMessage;
      } else {
        return ""; // Return a default value if no messages found
      }
    } else {
      throw Exception('Failed to fetch messages');
    }
  }

  Future<DateTime> getLatestMessageTimestamp(String conversationId) async {
    String url = '$baseUrl/v1/chat/messages?conversationId=$conversationId';

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'x-bot-id': botId,
        'x-integration-id': integrationId,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> messages = responseBody['messages'];

      if (messages.isNotEmpty) {
        DateTime latestTimestamp = DateTime.parse(
            messages[0]['createdAt']); // Get the latest message timestamp

        return latestTimestamp;
      } else {
        return DateTime(0); // Return a default value if no messages found
      }
    } else {
      throw Exception('Failed to fetch messages');
    }
  }

   Future<List> listUsers() async {
    String url = '$baseUrl/v1/chat/users';

    // Initialize nextToken as null to start with the first page

    // Append nextToken to the URL if available
    String requestUrl = nextTokenUser != null ? '$url?nextToken=$nextTokenUser' : url;

    http.Response response = await http.get(
      Uri.parse(requestUrl),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'x-bot-id': botId,
        'x-integration-id': integrationId,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> userList = responseBody['users'];

      if (userList.isNotEmpty) {
        // Filter and add users with required tags
        List<dynamic> filteredUsers = userList
            .where((user) =>
                user is Map<String, dynamic> &&
                user.containsKey('tags') &&
                user['tags'] is Map<String, dynamic> &&
                user['tags'].containsKey('whatsapp:name') &&
                user['tags'].containsKey('whatsapp:userId'))
            .toList();
        // Add the fetched users to the list
        allUsers.addAll(filteredUsers);

        // Check if there's a next page

      } else {
        nextTokenUser = ""; // No more data available
      }
    } else {
      throw Exception('Failed to fetch users');
    }

    return allUsers;
  }

  List<Map<String, dynamic>> filteredConversations() {
    return conversations.where((conversation) {
      String userName = conversation['whatsapp:name'] ?? "";
      return userName.toLowerCase().contains(filter.toLowerCase());
    }).map((conversation) {
      Map<String, dynamic> latestData = conversations
          .firstWhere((element) => element['id'] == conversation['id']);

      String latestMessage = latestData['latestMessage'] ?? '';
      DateTime latestTimestamp = latestData['latestMessageTimestamp'] ??
          DateTime.parse(conversation['updatedAt']);

      return {
        ...conversation,
        'latestMessageTimestamp': latestTimestamp,
        'latestMessage': latestMessage,
      };
    }).toList();
  }

  void onSearchTextChanged(String text) {
    setState(() {
      filter = text;
    });
  }

  Future<List<Map<String, dynamic>>> listConversations() async {
    String url = 'https://api.botpress.cloud/v1/chat/conversations';
  String requestUrl = nextTokenConversation != "" ? '$url?nextToken=$nextTokenConversation' : url;
    http.Response response = await http.get(
      Uri.parse(requestUrl),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'x-bot-id': botId,
        'x-integration-id': integrationId,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> conversationList = responseBody['conversations'];
 
      
      // Filter out conversations that are not related to WhatsApp
      List whatsappConversations = conversationList
          .where((conversation) =>
              conversation['tags'] != null &&
              conversation['tags']['whatsapp:userPhone'] != null)
          .toList();

      return whatsappConversations.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load conversations');
    }
  }
  Future<List<Map<String, dynamic>>> listMessages(String conversationId) async {
  
    String url = 'https://api.botpress.cloud/v1/chat/messages';

    url = '$url?conversationId=$conversationId';

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'x-bot-id': botId,
        'x-integration-id': integrationId,
      },
    );
   
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> messages = responseBody['messages'];
      for (int i = 0; i < messages.length; i++) {
     
      }
       if(responseBody['meta']['nextToken'] !=null){
          setState(() {
              messageToken = responseBody['meta']['nextToken'];
       });
      }
      return messages.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  void navigateToMessageScreen(dynamic opp ,List<Map<String, dynamic>> messages,
      Map<String, dynamic> conversation, String id,List<dynamic> labels,String contactId) {

    Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return MessageScreen(
                              messages: messages,
          conversation: conversation,
          accessToken: ghlToken,
          botId: botId,
          integrationId: integrationId,
          workspaceId: workspaceId,
          id: id,
          userId: messages.first['userId'] ?? "",
          companyId: companyId,
          labels:labels,
          contactId:contactId,
          pipelineId: pipelineId,
          opportunity:opp ,
          botToken: accessToken,
         messageToken:messageToken

                            );
                          }));

   
  }
}
