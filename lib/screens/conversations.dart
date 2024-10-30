// ignore_for_file: must_be_immutable, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart' as fluttertoast;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juta_app/models/conversations.dart';
import 'package:juta_app/screens/contact_detail.dart';
import 'package:juta_app/screens/dashboard.dart';
import 'package:juta_app/services/botpress.dart';
import 'package:juta_app/utils/progress_dialog.dart';
import 'package:juta_app/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:video_player/video_player.dart';

class Conversations extends StatefulWidget {
  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  int currentIndex = 0;
    int conversationCount = 0;
  TextEditingController searchController = TextEditingController();
  String filter = "";
  List<Map<String,dynamic>> conversations = [];
  List<Map<String,dynamic>> real_conversations = [];
  final GlobalKey progressDialogKey = GlobalKey<State>();
  TextEditingController messageController = TextEditingController();
String stageId ="";
  List<Map<String, dynamic>> users = [];
  String botId = '';
  String accessToken = '';
  String ghlToken = '';
  String nextTokenConversation = '';
  String prevTokenConversation = '';
  String nextTokenUser = '';
    String prevTokenUser = '';
  String workspaceId = '';
  String integrationId = '';
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';
  String firstName = '';
  String company = '';
  String companyId = '';
  final String baseUrl = "https://api.botpress.cloud";
  ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<dynamic> allUsers = [];
    List<dynamic> opportunities = [];
  List<dynamic> pipelines = [];
   int currentPage = 1;
  int totalPages = 10;
   String nextToken = '';
    String prevToken = '';
         String  messageToken ="";
       
  String? nextPageUrl;
  String? prevPageUrl;
  int fetchedOpportunities = 0;
  String whapiToken = "Botpress";
  Future<void> listenNotification() async {

     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if(message.data['convoId'] != null && message.data.containsKey('name')){
            setState(() {
                                          conversations.clear();
                                          _isLoading = true;
                             });

String conversationId = message.data['convoId'];
String phone = message.data['phone'];
String name = message.data['name'];
    // Initialize and call BotpressConversationService
    var botpressService = BotpressConversationService(
      companyId: companyId,
      botpressServerUrl: baseUrl,
      botId: botId,
      baseUrl: baseUrl,
      accessToken: accessToken,
      integrationId: integrationId
    );

  await botpressService.syncConversationWithFirestore(conversationId, phone,name);
     real_conversations = await fetchConversations();

     // Update the state with the sorted and processed conversations
setState(() {
      _isLoading = false;
// Update this line to replace the list instead of adding to it
});
      }


      });
     
     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print(message.notification!.body);
      });
}
Future<void> fetchConfigurations(bool refresh) async {
  email = user!.email!;
  print('Fetching configurations for email: $email');


  await FirebaseFirestore.instance
      .collection("user")
      .doc(email)
      .get()
      .then((snapshot) {
    if (snapshot.exists) {
      print('User snapshot found for email: $email');
      setState(() {
        firstName = snapshot.get("name") ?? "Default Name";
        company = snapshot.get("company") ?? "Default Company";
        companyId = snapshot.get("companyId") ?? "Default CompanyId";

        print('User details - Name: $firstName, Company: $company, Company ID: $companyId');
      });
    } else {
      print('User snapshot not found for email: $email');
    }
  }).then((value) {
    if (companyId != null && companyId.isNotEmpty) {
      print('Fetching company details for companyId: $companyId');
      FirebaseFirestore.instance
          .collection("companies")
          .doc(companyId)
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          print('Company snapshot found for companyId: $companyId');
          setState(() {
                 var automationData = snapshot.data() as Map<String, dynamic>;
            ghlToken = snapshot.get("ghlToken") ?? "Default AccessToken";
             if (automationData.containsKey('accessToken')){
      accessToken = snapshot.get("accessToken");
                }
       if (automationData.containsKey('botId')){
      botId = snapshot.get("botId");
                }
 if (automationData.containsKey('integrationId')){
      integrationId = snapshot.get("integrationId");
                }
        if (automationData.containsKey('workspaceId')){
      workspaceId = snapshot.get("workspaceId");
                }

               if(automationData.containsKey('whapiToken')) {
                 whapiToken= snapshot.get("whapiToken") ?? "Botpress";
               }else{
                 whapiToken="Botpress";
               }
            print('Company details - Access Token: $accessToken, Bot ID: $botId, Integration ID: $integrationId, Workspace ID: $workspaceId');
          });
          real_conversations = await fetchConversations();
          setState(() {
      _isLoading = false;

});
          print("Real" + real_conversations.toString());
   await fetchOpportunitiesAndConversations(botId, accessToken, integrationId);
   print("test");
          if (botId != null && accessToken != null && integrationId != null) {

         
          } else {
            print('One or more required fields (botId, accessToken, integrationId) are null');
          }
        } else {
          print('Company snapshot not found for companyId: $companyId');
        }
      });
    } else {
      print('companyId is null or empty');
    }
  });

  print('Configuration fetching complete.');
}

  Future<void> addUserToFirebase(
      Map<String, dynamic> userData, String companyId) async {
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
        }
      });
    } catch (e) {
    }
  }
Future<void> saveOrUpdateConversation(Conversation conversation) async {

  String phone = conversation.phone; // Assuming 'phone' is a property of the Conversation object

  // Reference to the Firestore document for the conversation, using the phone number as the document ID
  DocumentReference conversationRef = FirebaseFirestore.instance
      .collection('companies')
      .doc(companyId)
      .collection('conversations')
      .doc(phone); // Use phone number as document ID

  // Fetch messages for the current conversation
  List<Map<String, dynamic>> newMessages = await listMessages3(conversation.convoId);

  // Prepare the conversation document with the latest details
  Map<String, dynamic> conversationData = conversation.toFirestore();
  conversationData.addAll({
    'phone': phone, // This line might be redundant if phone number is already included by toFirestore() method
    // Include or update additional conversation details as needed
  });

  // Set (or update) the conversation document with new details
  // Using SetOptions(merge: true) to merge with existing data (if any), rather than overwriting
  await conversationRef.set(conversationData, SetOptions(merge: true));

  // Add new messages to the 'messages' sub-collection under the conversation document
  for (var message in newMessages) {
    // Assuming each message has a unique ID within the conversation
    // If messages don't have unique IDs, consider generating them or using add() to auto-generate document IDs
    String messageId = message['id'] ?? UniqueKey().toString(); // Fallback to generating an ID if none exists
    await conversationRef.collection('messages').doc(messageId).set(message, SetOptions(merge: true));
  }
}

Future<void> fetchOpportunitiesAndConversations(String botId, String accessToken, String integrationId) async {
  try {
    // Fetch pipelines and opportunities
    List<dynamic> pipelines = await fetchPipelines();
opportunities = [];
String firstPipelineId = "";
    if (pipelines.isNotEmpty) {
  firstPipelineId = pipelines[0]['id'];
      setState(() {
        stageId = pipelines[0]['stages'][0]['id'].toString();


       
      });

    opportunities = await fetchAllOpportunitiesFromPipeline(firstPipelineId);



    }

    // Fetch conversations
    if(whapiToken == "Botpress"){
 conversations = await listConversations();
    // Match opportunities to conversations based on phone numbers
    for (var opportunity in opportunities) {
      String? opportunityPhone = opportunity['contact']['phone']; // Adjust this path as per your data structure

      if (opportunityPhone != null) {
        opportunityPhone = opportunityPhone.replaceAll('+', '');


        for (var conversation in conversations) {
          String? conversationPhone = conversation['tags']['whatsapp:userPhone']; // Adjust this path as per your data structure

          if (conversationPhone != null && opportunityPhone == conversationPhone) {
            // Opportunity and conversation phone numbers match
            var newEntry = MapEntry('whatsapp:name', opportunity['name']);
            List<MapEntry<String, dynamic>> newEntries = [newEntry];
            conversation.addEntries(newEntries);
         
          }
        }
      }
    }

    // Process the conversations
    List<Future<DateTime>> latestTimestamps = [];
    List<Future<String>> latestMessages = [];
    List<Map<String, dynamic>> updatedConversations = [];

    for (var conversation in conversations) {
      latestTimestamps.add(getLatestMessageTimestamp(conversation['id']));
      latestMessages.add(getLatestMessage(conversation['id']));
    }

    List<DateTime> timestamps = await Future.wait(latestTimestamps);
    List<String> messages = await Future.wait(latestMessages);

   for (int i = 0; i < conversations.length; i++) {
  Map<String, dynamic> updatedConversation = Map.from(conversations[i]);
  updatedConversation['latestMessageTimestamp'] = timestamps[i];
  updatedConversation['latestMessage'] = messages[i];
  updatedConversations.add(updatedConversation);
}

// Sort the updated conversations by latestMessageTimestamp
updatedConversations.sort((a, b) {
  DateTime aTimestamp = a['latestMessageTimestamp'];
  DateTime bTimestamp = b['latestMessageTimestamp'];
  return bTimestamp.compareTo(aTimestamp); // Sort in descending order (newest first)
});

// Update the state with the sorted and processed conversations
setState(() {
  this.conversations = updatedConversations; // Update this line to replace the list instead of adding to it
});


    }else{
var result = await fetchChats(); // result is inferred as dynamic or var
conversations = result.cast<Map<String, dynamic>>();
setState(() {
  this.conversations = conversations; // Update this line to replace the list instead of adding to it
});
    }
// Save each fetched conversation to Firestore
    for (var conversationMap in conversations) {
      print(conversationMap.toString());
  // Ensure 'id' is not null and is a String before proceeding
  if (conversationMap['id'] != null && conversationMap['id'] is String && conversationMap['tags']['userPhone'] != null && conversationMap['latestMessageTimestamp'] != null) {
    // Since 'id' is confirmed to be non-null and a String, it's safe to pass it to fromMap
    String name = conversationMap['whatsapp:name']??conversationMap['tags']['userPhone'];
    Conversation conversation = Conversation.fromMap(conversationMap, conversationMap['id'],name);
    await saveOrUpdateConversation(conversation);
  } else {
    // Handle the case where 'id' is null or not a String
    print('Invalid or missing ID for conversationMap');
  }
}

  

  } catch (e) {
    // Handle exceptions
    print('Error in fetchOpportunitiesAndConversations: $e');
  }
}


Future<List<Map<String, dynamic>>> fetchConversations() async {

  List<Map<String, dynamic>> conversationsList = [];

  // Reference to your Firestore collection
  CollectionReference conversationsRef = FirebaseFirestore.instance
      .collection('companies')
      .doc(companyId)
      .collection('conversations');

  try {
    // Adjust the query based on the 'archived' parameter
    QuerySnapshot querySnapshot = await conversationsRef
        // Add any additional query parameters here
        .orderBy('latestMessageTimestamp', descending: true) // Example: order by timestamp
        .get();

    // Iterating over the documents returned by the query
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> conversation = doc.data() as Map<String, dynamic>;
      conversation['id'] = doc.id; // Optionally add the document ID to the map
      conversationsList.add(conversation);
    }

    return conversationsList;
  } catch (e) {
    print('Error fetching conversations: $e');
    return []; // Return an empty list in case of error
  }
}

Future<List> listUsers() async {
  String url = '$baseUrl/v1/chat/users';
  String requestUrl = nextTokenUser.isNotEmpty ? '$url?nextToken=$nextTokenUser' : url;

  http.Response response = await http.get(
    Uri.parse(requestUrl),
    headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'x-bot-id': botId,
      'x-integration-id': integrationId,
    },
  ); 
print(response.body);
  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = json.decode(response.body);
    List<dynamic> userList = responseBody['users'];

    // Update nextTokenUser for the next page, or clear it if there are no more pages
    nextTokenUser = responseBody['meta']?['nextToken'] ?? '';

    // Filter and add users with required tags
    List<dynamic> filteredUsers = userList
        .where((user) => user is Map<String, dynamic>)
        .toList();

    // Add the fetched users to the list
    allUsers.addAll(filteredUsers);
  } else {
    throw Exception('Failed to fetch users');
  }

  return allUsers;
}

List<dynamic> filteredConversations() {
  return conversations.where((conversation) {
    // Ensure userName is not null and matches the filter
    String userName = conversation['whatsapp:name'] ?? "";
    bool userNameMatchesFilter = userName.toLowerCase().contains(filter.toLowerCase());

    // Extract latestMessage and latestMessageTimestamp from the conversation
    Map<String, dynamic> latestData = conversations.firstWhere(
      (element) => element['id'] == conversation['id'],
      orElse: () => {}
    );

    String latestMessage = latestData['latestMessage'] ?? '';
    DateTime latestTimestamp = latestData['latestMessageTimestamp'] ?? DateTime.now();

    // Return true if the userName matches the filter and latestMessage is not empty
    return userNameMatchesFilter && latestMessage.isNotEmpty;
  }).map((conversation) {
    // Extract latestMessage and latestMessageTimestamp again for mapping
    Map<String, dynamic> latestData = conversations.firstWhere(
      (element) => element['id'] == conversation['id'],
      orElse: () => {}
    );

    String latestMessage = latestData['latestMessage'] ?? '';
    DateTime latestTimestamp = latestData['latestMessageTimestamp'] ?? DateTime.now();

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

Future<List<Map<String, dynamic>>>    listConversations() async {
  List<Map<String, dynamic>> allConversations = [];
  String url = '$baseUrl/v1/chat/conversations';
  bool hasErrorOccurred = false;

   
  do {
    try {
      // Use the nextToken if available
      
      String requestUrl = nextToken.isNotEmpty ? '$url?nextToken=${nextToken}' : url;

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

        // Filter out conversations
        List<Map<String, dynamic>> filteredConversations = conversationList
            .where((conversation) =>
                conversation['tags'] != null &&
                (conversation['tags']['whatsapp:userPhone'] != null ||
                 conversation['tags']['webchat:id'] != null))
            .toList()
            .cast<Map<String, dynamic>>();

        allConversations.addAll(filteredConversations);
        conversationCount += filteredConversations.length;
print("response"+responseBody['meta'].toString());
        // Update nextToken for next page, or clear it if there are no more pages
        if (responseBody.containsKey('meta') && responseBody['meta']['nextToken'] != null ) {
          if(!nextToken.contains(responseBody['meta']['nextToken'])){
         nextToken=responseBody['meta']['nextToken'];
          }

             print("nextTOken"+nextToken);
       
        } else {
          nextToken =''; // No more data available
        }

        // Break the loop after the initial batch or if no more data is available
        if ( nextToken=='') {
          break;
        }
      } else {
        hasErrorOccurred = true; // Error in fetching data
        break; // Break the loop on error
      }
    } catch (e) {
      print('Error fetching conversations: $e');
      hasErrorOccurred = true; // Error in fetching data
      break; // Break the loop on error
    }
  } while (!hasErrorOccurred);

  if (hasErrorOccurred) {
    // Handle the error case, e.g., showing an error message to the user
  }

  return allConversations;
}
Future<dynamic> fetchChats() async {
   List<dynamic> allConversations = [];
    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://gate.whapi.cloud/chats';
     String apiToken = whapiToken; // Replace with your actual WHAPI Token

    final queryParameters = {
      'count': '100', // Adjust based on how many chats you want to fetch
      // 'offset': '0', // Uncomment and adjust if you need pagination
    };

    final uri = Uri.parse(apiUrl).replace(queryParameters: queryParameters);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': apiToken,
          'Content-Type': 'application/json',
        },
      );
print(response.body);
      if (response.statusCode == 200) {
       final data = json.decode(response.body);
      // Assuming the chats are in a field named 'chats'. Adjust this according to the actual response structure.
      final List<dynamic> chatsList = data['chats'] ?? []; // Use the correct key based on the API response
      setState(() {
        allConversations = chatsList;
        _isLoading = false;
      });
      } else {
        print('Failed to fetch chats: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
      return allConversations;
    } catch (e) {
      print('Error fetching chats: $e');
      setState(() {
        _isLoading = false;
      });
        return allConversations;
    }
  }

  Future<List<Map<String, dynamic>>> listMessages3(String conversationId) async {
    String url = '$baseUrl/v1/chat/messages';

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
    print(responseBody);
     
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
     return [];
    }
  }

   void navigateToMessageScreen(dynamic opp ,List<Map<String, dynamic>> messages,
      Map<String, dynamic> conversation, String id,List<dynamic> labels,String contactId,String messageToken,String username) {

    Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return MessageScreen(
                              messages: messages,
          conversation: conversation,
          accessToken: ghlToken,
          botToken:accessToken,
          botId: botId,
          integrationId: integrationId,
          workspaceId: workspaceId,
          id: id,
          userId: messages[0]['userId'] ?? "",
          companyId: companyId,
          labels:labels,
          contactId:contactId,
          pipelineId:pipelines[0]['id'],
          opportunity:opp ,
          messageToken:messageToken,
          name:username
                            );
                          }));

   
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    setState(() {
    fetchedOpportunities = 0;
      conversations.clear();
      opportunities.clear();
    });
    await fetchConfigurations(true);
 
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

   dynamic matchConversationsWithOpportunities(Map<String, dynamic> conversation2
) {
    // Logic to match conversations with opportunities based on a common identifier
    // Modify this part according to your application's data structure

      var contactId = "+"+conversation2['phone']; // Assuming contactId is present

      var matchedOpportunity = opportunities.firstWhere(
        (opp) => opp['contact']['phone'] == contactId,
        orElse: () => null
      );
      return conversation2['matchedOpportunity'] = matchedOpportunity;

  }
Future<List<dynamic>> fetchAllOpportunitiesFromPipeline(String pipelineId, {int? maxOpportunities}) async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String endpoint = '/v1/pipelines/$pipelineId/opportunities';
  String token = ghlToken; // Your GoHighLevel API token
    List<dynamic> allOpportunities = [];

  do {
    Uri uri = nextPageUrl == null ? Uri.parse(baseUrl + endpoint) : Uri.parse(nextPageUrl!);

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
        setState(() {

        });
     
        // Check if maximum number of opportunities has been reached
        if (maxOpportunities != null && fetchedOpportunities >= maxOpportunities) {
          break;
        }

        if (opportunities.isEmpty) {
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
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
   listenNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    await fetchConfigurations(false);
  });
    
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has reached the end of the list, load more conversations

    
         
    }
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
     return ""; // Return a default value if no messages found
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
      return DateTime(0); // Return a default value if no messages found
    }
  }Future<void> conversationPage() async {
    // Use a GlobalKey to access the Scaffold and open the drawer
   setState(() {
      currentIndex = 1;
    });
  }
 Future<void> _handleRefresh2() async {
    setState(() {
      conversations.clear();
        nextToken= '';
                              nextTokenConversation ="";
                              nextTokenUser="";
                                    ProgressDialog.show(context, progressDialogKey);
    });
    await fetchConfigurations(true);
    
        ProgressDialog.unshow(context, progressDialogKey);
  }
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
   
      body: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 20,
        ),
    height:MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: EdgeInsets.all(8.0),
              child:   Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               Text("Conversations",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 22,
                                           fontFamily: 'SF',
                          fontWeight: FontWeight.bold,
                           color: Color(0xFF2D3748))),
                           GestureDetector(
                            onTap: () async {
                  
                             setState(() {
                                          conversations.clear();
                                          _isLoading = true;
                             });
                                   // Fetch conversations
                                   if(whapiToken == "Botpress"){
                                    conversations = await listConversations();
print(opportunities.length);
    // Match opportunities to conversations based on phone numbers
    for (var opportunity in opportunities) {
      String? opportunityPhone = opportunity['contact']['phone']; // Adjust this path as per your data structure

      if (opportunityPhone != null) {
        opportunityPhone = opportunityPhone.replaceAll('+', '');


        for (var conversation in conversations) {
          String? conversationPhone = conversation['tags']['whatsapp:userPhone']; // Adjust this path as per your data structure

          if (conversationPhone != null && opportunityPhone == conversationPhone) {
            // Opportunity and conversation phone numbers match
            var newEntry = MapEntry('whatsapp:name', opportunity['name']);
            List<MapEntry<String, dynamic>> newEntries = [newEntry];
            conversation.addEntries(newEntries);
         
          }
        }
      }
    }

    // Process the conversations
    List<Future<DateTime>> latestTimestamps = [];
    List<Future<String>> latestMessages = [];
    List<Map<String, dynamic>> updatedConversations = [];

    for (var conversation in conversations) {
      latestTimestamps.add(getLatestMessageTimestamp(conversation['id']));
      latestMessages.add(getLatestMessage(conversation['id']));
    }

    List<DateTime> timestamps = await Future.wait(latestTimestamps);
    List<String> messages = await Future.wait(latestMessages);

   for (int i = 0; i < conversations.length; i++) {
  Map<String, dynamic> updatedConversation = Map.from(conversations[i]);
  updatedConversation['latestMessageTimestamp'] = timestamps[i];
  updatedConversation['latestMessage'] = messages[i];
  updatedConversations.add(updatedConversation);
}

// Sort the updated conversations by latestMessageTimestamp
updatedConversations.sort((a, b) {
  DateTime aTimestamp = a['latestMessageTimestamp'];
  DateTime bTimestamp = b['latestMessageTimestamp'];
  return bTimestamp.compareTo(aTimestamp); // Sort in descending order (newest first)
});

// Update the state with the sorted and processed conversations
setState(() {
      _isLoading = false;
  this.conversations = updatedConversations; // Update this line to replace the list instead of adding to it
});
                                   }else{
                                    var result = await fetchChats(); // result is inferred as dynamic or var
conversations = result.cast<Map<String, dynamic>>();
print(conversations);
setState(() {
  this.conversations = conversations; // Update this line to replace the list instead of adding to it
});
    }
    print(conversations);


    setState(() {
      _isLoading = false;
    });
                         
  
                            },
                             child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.refresh,size: 30,color: Color(0xFF2D3748),),
                                  ),
                           )
                              ],
                            ),
            ),
            Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
             border: Border.all( color: Color(0xFF2D3748)),
                    borderRadius: BorderRadius.circular(15)),
              
                child: TextField(
                  style: const TextStyle( color: Color(0xFF2D3748),
                                           fontFamily: 'SF',),
                  cursorColor: Colors.white,
                  controller: searchController,
                  onChanged: onSearchTextChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusColor: Colors.white,
                    hoverColor: Colors.white,
                    hintText: 'Search',
                    hintStyle:
                        TextStyle( color: Color(0xFF2D3748),
                                           fontFamily: 'SF', fontSize: 15),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF2D3748)
                    ),
                  ),
                ),
              ),
            ),
            if(whapiToken != 'Botpress')
              Container(
              height: MediaQuery.of(context).size.height *68/100,
              child: RefreshIndicator(
           
                onRefresh: _handleRefresh2,
                child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                     color: Color(0xFF2D3748)
                  ),
                )
              : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        
                        final conversation = conversations[index];
                      
                
                        // /String phone = id.
                       String latestMessage = "";
                
                
                
                DateTime? lastMessageTime;
                
                if (conversation['last_message'] != null) {
                   var lastMessage = conversation['last_message'] as Map<String, dynamic>;
                
                  // Extract the timestamp and convert it to a DateTime object
                  if (lastMessage['timestamp'] != null) {
                    int timestamp = lastMessage['timestamp'];
                    lastMessageTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
                  }
                
                  // Continue with your existing logic to determine the number or title
                  if (lastMessage['type'] == 'text' && lastMessage['text'] != null) {
                    latestMessage = lastMessage['text']['body'].toString();
                  } else if (lastMessage['type'] == 'poll' && lastMessage['poll'] != null) {
                    latestMessage = lastMessage['poll']['title'].toString();
                  }
                } else {
                  print('Last message is null.');
                }
                
                // Print the extracted information
                print(latestMessage);
                // Function to format the date according to the specified rules
                String formatDate(DateTime? dateTime) {
                  if (dateTime == null) return 'Unknown';
                
                  DateTime now = DateTime.now();
                  DateTime today = DateTime(now.year, now.month, now.day);
                  DateTime yesterday = today.subtract(Duration(days: 1));
                  DateTime aWeekAgo = today.subtract(Duration(days: 7));
                
                  if (dateTime.compareTo(today) >= 0) {
                    return DateFormat('HH:mm').format(dateTime); // Today
                  } else if (dateTime.compareTo(yesterday) >= 0) {
                    return 'Yesterday'; // Yesterday
                  } else if (dateTime.compareTo(aWeekAgo) >= 0) {
                    return DateFormat('EEEE').format(dateTime); // Day of the week
                  } else {
                    return DateFormat('dd/MM/yyyy').format(dateTime); // Date in DD/MM/YYYY format
                  }
                }
                
                // Use the formatDate function to get the formatted date string
                String formattedDate = formatDate(lastMessageTime);
                
                print(formattedDate);
                print(latestMessage);
                
                       // Example chat_id from the conversation
                String chatId = conversation['id'];
                // Use regular expression to extract only digits
                RegExp numRegex = RegExp(r'\d+');
                String numberOnly = numRegex.firstMatch(chatId)?.group(0) ?? '';
                
                // Additional fields from the conversation
                
                
                              String userName = conversation['name'] ?? numberOnly ?? "Webchat"; 
                      
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                
             fetchMessagesForChat(chatId,conversation,userName);
                  
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                       height: 50,
                                width: 50,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2D3748),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Center(child: Text( userName.isNotEmpty ?  userName.substring(0, 1).toUpperCase() : '',style: TextStyle(color: Colors.white,fontSize: 14),)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                        
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: 165,
                                                child: Text(
                                                  userName ?? "Webchat",
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: Color(0xFF2D3748),
                                                   fontFamily: 'SF',
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                             
                                              Text(
                                               //updatedAtText,
                                               formattedDate,
                                                style: const TextStyle(
                                                  color: Color(0xFF2D3748),
                                                   fontFamily: 'SF',
                                                fontSize: 10
                                              
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 40,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 140,
                                                  child: Text(
                                                    latestMessage ?? "",
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xFF2D3748),
                                                         fontFamily: 'SF',
                                                         fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                                  Text(
                                                  "+"+numberOnly,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize:  9,
                                                    color: Color(0xFF2D3748),
                                                       fontFamily: 'SF',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                            const Divider(
                                            height: 1,
                                         color: Color(0xFF2D3748),
                                            thickness: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                           
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ),
            if(whapiToken == 'Botpress')
            Container(
              height: MediaQuery.of(context).size.height *66/100,
              child: RefreshIndicator(
           
                onRefresh: _handleRefresh2,
                child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                     color: Color(0xFF2D3748)
                  ),
                )
              :ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: real_conversations.length,
                  itemBuilder: (context, index) {
        
                    final conversation = real_conversations[index];
                  
                    final id = conversation['id'];
                    String userName = conversation['name']  ?? "Webchat";
                  
                    final number = conversation['latestMessage'];
              
                  // Assuming conversation['latestMessageTimestamp'] is of type Timestamp
DateTime latestMessageTimestamp = conversation['latestMessageTimestamp'].toDate();
DateTime today = DateTime.now();
Duration difference = today.difference(latestMessageTimestamp);

String updatedAtText = difference.inDays == 0
  ? '${latestMessageTimestamp.hour.toString().padLeft(2, '0')}:${latestMessageTimestamp.minute.toString().padLeft(2, '0')} ${latestMessageTimestamp.hour < 12 ? 'AM' : 'PM'} | Today'
  : '${latestMessageTimestamp.day.toString().padLeft(2, '0')}/${latestMessageTimestamp.month.toString().padLeft(2, '0')}/${latestMessageTimestamp.year}';
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {

        var conversation = real_conversations[index];
       var matchedOpportunity = matchConversationsWithOpportunities(conversation);
  
    var messages = await fetchMessagesForConversation(conversation['phone']);
    print(messages);
        if (matchedOpportunity != null) {
        
       
          navigateToMessageScreen(
            matchedOpportunity,
            messages,
            conversation,
            conversation['convoId'],
           matchedOpportunity['contact']['tags'],
            matchedOpportunity['contact']['id'],
            messageToken,
            userName
            // Additional parameters if needed
          );
        } else {
      
              var messages = await fetchMessagesForConversation(conversation['phone']);
          ProgressDialog.unshow(context, progressDialogKey);
          navigateToMessageScreen(
            matchedOpportunity,
            messages,
            conversation,
            conversation['convoId'],
          [],
            "",
            messageToken,
            userName
            // Additional parameters if needed
          );
        }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                   height: 50,
                            width: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2D3748),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(child: Text( userName.isNotEmpty ?  userName.substring(0, 1).toUpperCase() : '',style: TextStyle(color: Colors.white,fontSize: 14),)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 165,
                                            child: Text(
                                              userName ?? "Webchat",
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: Color(0xFF2D3748),
                                               fontFamily: 'SF',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                         
                                          Text(
                                           updatedAtText,
                                            style: const TextStyle(
                                              color: Color(0xFF2D3748),
                                               fontFamily: 'SF',
                                            fontSize: 10
                                          
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 40,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 190,
                                              child: Text(
                                                number ?? "",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF2D3748),
                                                     fontFamily: 'SF',
                                                     fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                              Text(
                                             (conversation['phone'] != null)? "+"+conversation['phone'] : "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize:  9,
                                                color: Color(0xFF2D3748),
                                                   fontFamily: 'SF',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                        const Divider(
                                        height: 1,
                                     color: Color(0xFF2D3748),
                                        thickness: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                       
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
    Future<void> fetchMessagesForChat(String chatId,dynamic chat,String name) async {
  try {
    String url = 'https://gate.whapi.cloud/messages/list/$chatId';
    // Optionally, include query parameters like count, offset, etc.

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $whapiToken', // Replace with your actual Whapi access token
      },
    );
print(response.body);
 if (response.statusCode == 200) {
  var data = json.decode(response.body);
  
  // Ensure messages is treated as a List<Map<String, dynamic>>.
  // We use .cast<Map<String, dynamic>>() to ensure the correct type.
  List<Map<String, dynamic>> messages = (data['messages'] is List)
      ? data['messages'].cast<Map<String, dynamic>>()
      : [];
print(messages);
print(chat['name']);
  // Now 'messages' is guaranteed to be a List<Map<String, dynamic>>,
  // which you can safely pass to another widget.

  Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return MessageScreen(
                             chatId: chatId,messages: messages,conversation: chat,whapi: whapiToken,name: name,
                            );
                          }));
} else {
      print('Failed to fetch messages: ${response.body}');
   
    }
  } catch (e) {
    print('Error fetching messages for chat: $e');
  
  }
}
Future<List<Map<String, dynamic>>> fetchMessagesForConversation(String conversationId) async {
print(conversationId);
  List<Map<String, dynamic>> messagesList = [];

  // Reference to the Firestore sub-collection where messages are stored for a conversation
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('companies')
      .doc(companyId)
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .get();

  // Iterate through each document in the snapshot and add it to the list
  for (var doc in querySnapshot.docs) {
    print(doc.data());
    Map<String, dynamic> message = doc.data() as Map<String, dynamic>;
    message['id'] = doc.id; // Optionally include the Firestore document ID
    messagesList.add(message);
  }

  return messagesList;
}
}

class MessageScreen extends StatefulWidget {
  List<Map<String, dynamic>> messages;
  final Map<String, dynamic> conversation;
  String? botId;
  String? accessToken;
  String? workspaceId;
  String? integrationId;
  String? id;
  String? userId;
  String? companyId;
  List<dynamic>? labels;
  String? contactId;
  String? pipelineId;
  String? messageToken;
  Map<String,dynamic>? opportunity;
  String? botToken;
  String? chatId;
  String? whapi;
  String? name;
  MessageScreen(
      {required this.messages,
      required this.conversation,
      this.botToken,
      this.botId,
      this.accessToken,
      this.workspaceId,
      this.integrationId,
      this.id,
      this.whapi,
      this.userId,
      this.companyId,
      this.contactId,
      this.opportunity,
      this.pipelineId,
this.messageToken,
this.chatId,
this.name,
      this.labels});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _messageController = TextEditingController();

  bool typing = false;
  bool expand = false;
  double height = 50;
  bool hasNewline = false;
  bool nowHasNewline = false;
  final String baseUrl = "https://api.botpress.cloud";
  bool stopBot = false;
    TextEditingController tagController = TextEditingController();
      int currentIndex = 0;
  TextEditingController searchController = TextEditingController();
  String filter = "";
  List<Map<String, dynamic>> conversations = [];
  final GlobalKey progressDialogKey = GlobalKey<State>();
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  String botId = '';
  String accessToken = '';
  String nextTokenConversation = '';
  String nextTokenUser = '';
  String workspaceId = '';
  String integrationId = '';
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';
  String firstName = '';
  String company = '';
  String companyId = '';
  List<dynamic> allUsers = [];
  String nextMessageToken = '';
String conversationId = "";
  UploadTask? uploadTask;
  final ScrollController _scrollController = ScrollController();
    final picker = ImagePicker();
    PlatformFile? pickedFile;
late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if(widget.chatId == null){
    _checkStop();
     nextMessageToken = widget.messageToken!;
    }

    listenNotification();
  
      _scrollController.addListener(_scrollListener);
    _messageController.addListener(() {
      String value = _messageController.text;
      List<String> lines = value.split('\n');
      int newHeight = 50 + (lines.length - 1) * 25;

      if (value.length > 29) {
        int additionalHeight = ((value.length - 1) ~/ 29) * 25;
        newHeight += additionalHeight;
      }

      setState(() {
        height = newHeight.clamp(60, 200).toDouble();
      });
    });
  }
  void _scrollListener() {
  if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
      !_scrollController.position.outOfRange) {
        showToast("Fetching more data...");
    loadMoreMessages();
  }
}
  Future<void> listenNotification() async {

     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      widget.messages.clear();
     List<Map<String, dynamic>> moreMessages = await listMessages(
        widget.botId!,
        widget.accessToken!,
        widget.integrationId!,
        widget.conversation['id'],
   nextMessageToken,
      );
  widget.messages.addAll(moreMessages); // Prepend new messages to the existing list
      });
     
 
}
void showToast(String message) {
  fluttertoast.Fluttertoast.showToast(
    msg: message,
    toastLength:  fluttertoast.Toast.LENGTH_SHORT,
    gravity:  fluttertoast.ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
    Future<void> loadMoreMessages() async {
    
    if (nextMessageToken.isNotEmpty) {
      List<Map<String, dynamic>> moreMessages = await listMessages(
        widget.botId!,
        widget.accessToken!,
        widget.integrationId!,
        widget.conversation['id'],
   nextMessageToken,
      );

      setState(() {
             widget.messages.addAll(moreMessages); // Prepend new messages to the existing list
      });
    }
  }
Future<void> _checkStop() async {
  setState(() {
    stopBot = (widget.labels!.contains('stop bot'));
  });
}
  Future<void> _handleImageMessage(Map<String, dynamic> message) async {
    final type = message['type'];
    if (type == 'image') {


      // Add your logic for handling image messages here
    }
  }

Future<List<Map<String, dynamic>>> listMessages(String botId, String accessToken, String integrationId, String conversationId, String nextToken) async {
  String url = '$baseUrl/v1/chat/messages';
  String requestUrl = nextToken.isNotEmpty ? '$url?conversationId=$conversationId&nextToken=$nextToken' : '$url?conversationId=$conversationId';
print(requestUrl);
  http.Response response = await http.get(
    Uri.parse(requestUrl),
    headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer ${widget.botToken}',
      'x-bot-id': botId,
      'x-integration-id': integrationId,
    },
  );
print(response.body);
  if (response.statusCode == 200) {

    Map<String, dynamic> responseBody = json.decode(response.body);
    List<dynamic> messages = responseBody['messages'];

    // Update nextMessageToken state if necessary
    if (responseBody.containsKey('meta') && responseBody['meta']['nextToken'] != null) {
      nextMessageToken = responseBody['meta']['nextToken'];
    } else {
      nextMessageToken = ''; // Reset nextMessageToken if it's not available
    }

    return messages.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load messages');
  }
}

  Future<Map<String, dynamic>?>  createMessage({
    required String payloadType,
    required String userId,
    required String conversationId,
    required String messageType,
    required Map<String, dynamic> tags,
    Map<String, dynamic>? schedule,
    required String text,
    String? urlDownload
  }) async {
    print("id"+conversationId);
    String url = '$baseUrl/v1/chat/messages';
    Map<String, dynamic> requestBody ={};
    if(urlDownload != null){
      requestBody = {
      'payload': {
        'type': payloadType,
        'text': text,
         'imageUrl':urlDownload
      }, // Include the text property
      'userId': userId,
      'conversationId': conversationId,
      'type': messageType,
      'tags': tags,
     
    };
    }else{
      requestBody = {
      'payload': {
        'type': payloadType,
        'text': text
      }, // Include the text property
      'userId': userId,
      'conversationId': conversationId,
      'type': messageType,
      'tags': tags,
     
    };
    }

    if (schedule != null) {
      requestBody['schedule'] = schedule;
    }

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer ${widget.botToken}',
        'x-bot-id': widget.botId!,
        'x-integration-id': widget.integrationId!,
      },
      body: json.encode(requestBody),
    );
    print(response!.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
  Future uploadFile2() async {
    final path = 'images/${widget.contactId}/${pickedFile!.path!}';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
      Map<String, dynamic> tags = {}; // Replace with your tags
 createMessage(
        payloadType: 'Image',
        userId: widget.userId!,
        conversationId: widget.id!,
        messageType: 'image',
        tags: tags,
        text: _messageController.text,
        urlDownload:urlDownload
      ).then((createdMessage) async {

        // Refresh the message list after sending a message
        await _refreshMessages();
      }).catchError((e) {
      });
  }
Future<void> sendMessage() async {

  try {

    String messageText = _messageController.text;
    Map<String, dynamic> tags = {}; // Replace with your tags
       setState(() {
                                _messageController.clear();
                                pickedFile = null;
                              });
                             
                              
    await createMessage(
      payloadType: 'Text',
      userId: widget.userId!,
      conversationId: (widget.conversation['convoId'] != null)?widget.conversation['convoId']!:widget.conversation['id'],
      messageType: 'text',
      tags: tags,
      text: messageText,
    );

    // Refresh the message list after sending a message
    await _refreshMessages();
  } catch (e) {
    // Handle error
    print('Error in sendMessage: $e');
  }
}


Future<void> _refreshMessages() async {
  try {
      List<Map<String, dynamic>> updatedMessages =[];
    
    if(widget.chatId == null){
          updatedMessages = await listMessages(
      widget.botId!,
      widget.accessToken!,
      widget.integrationId!,
     (widget.conversation['convoId'] != null)?widget.conversation['convoId']!:widget.conversation['id'],
      "",
    );
 
 
    }else{
   updatedMessages =    await fetchMessagesForChat(widget.chatId!,widget.conversation);
    }
  
    setState(() {
      widget.messages = updatedMessages;
    });
  } catch (e) {
    // Handle error
    print('Error in _refreshMessages: $e');
  }
}
    Future<List<Map<String, dynamic>>> fetchMessagesForChat(String chatId,dynamic chat) async {
        List<Map<String, dynamic>> messages =[];
  try {
    String url = 'https://gate.whapi.cloud/messages/list/$chatId';
    // Optionally, include query parameters like count, offset, etc.

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.whapi}', // Replace with your actual Whapi access token
      },
    );
print(response.body);
 if (response.statusCode == 200) {
  var data = json.decode(response.body);
  
  // Ensure messages is treated as a List<Map<String, dynamic>>.
  // We use .cast<Map<String, dynamic>>() to ensure the correct type.
  List<Map<String, dynamic>> messages = (data['messages'] is List)
      ? data['messages'].cast<Map<String, dynamic>>()
      : [];
print(messages);
print(chat['name']);
  // Now 'messages' is guaranteed to be a List<Map<String, dynamic>>,
  // which you can safely pass to another widget.
return messages;
} else {
      print('Failed to fetch messages: ${response.body}');
   return messages;
    }
  } catch (e) {
    print('Error fetching messages for chat: $e');
  return messages;
  }
}

   void _showImageDialog() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.media);
    setState(() {
      pickedFile = result?.files.first;
    });

    if (pickedFile != null && pickedFile!.name.contains(".mp4")) {
      _controller = VideoPlayerController.file(File(pickedFile!.path!));
      // Initialize the controller, you can also provide a network URL or an asset path here.
      _controller!.initialize().then((_) {
        // Ensure the first frame is shown
        setState(() {});
      });
    }
  }

  Future<void> _showDocumentDialog() async {

  final result = await FilePicker.platform.pickFiles(type: FileType.any);
    setState(() {
      pickedFile = result!.files.first;
    
    });
    print(result);
  }

 

     Future<void> addStopbottag() async {
  final String baseUrl = 'https://rest.gohighlevel.com/v1/contacts/${widget.contactId}/tags/';
  final String apiKey = widget.accessToken!; // Replace 'YOUR_API_KEY' with your actual API key

  // Create the request body
  Map<String, dynamic> requestBody = {
    "tags": ['stop bot'],
  };

  // Convert the request body to JSON
  String jsonBody = json.encode(requestBody);

  // Set up the headers
  Map<String, String> headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  try {
    // Send POST request to add tags to the contact
    http.Response response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonBody,
    );
    if (response.statusCode == 200) {
      await _handleRefresh();
      
    } else {
  
          Toast.show(context,'danger','Failed to delete tags');
   
 
    }
  } catch (error) {
    // Handle any potential exceptions
    print('Error adding tags: $error');
  }
} 
  Future<void> deleteStopbottag() async {
  final String baseUrl = 'https://rest.gohighlevel.com/v1/contacts/${widget.contactId}/tags/';
  final String apiKey = widget.accessToken!; // Replace 'YOUR_API_KEY' with your actual API key

  // Create the request body
  Map<String, dynamic> requestBody = {
    "tags": ['stop bot'],
  };

  // Convert the request body to JSON
  String jsonBody = json.encode(requestBody);

  // Set up the headers
  Map<String, String> headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  try {
    // Send POST request to add tags to the contact
    http.Response response = await http.delete(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonBody,
    );
    if (response.statusCode == 200) {
      await _handleRefresh();
      
    } else {
  
          Toast.show(context,'danger','Failed to delete tags');
   
 
    }
  } catch (error) {
    // Handle any potential exceptions
    print('Error adding tags: $error');
  }
}

  Future<List<String>> getTags() async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String tagsEndpoint = '/v1/tags';
  List<String> tagsList = [];

  try {
    Uri uri = Uri.parse('$baseUrl$tagsEndpoint');
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
    };

    http.Response response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      // Parse the response body and extract tags
      Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('tags')) {
        List<dynamic> tags = responseData['tags'];
        tagsList = tags.map((tag) => tag['name'].toString()).toList();
      } else {
        print('No tags found in the response.');
      }
    } else {
      // Handle error response
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (error) {
    // Handle exceptions or errors during the request
    print('Error: $error');
  }

  return tagsList;
}
Future<void> deleteConversation(String conversationId) async {
  String url = '$baseUrl/v1/chat/conversations/$conversationId';

  http.Response response = await http.delete(
    Uri.parse(url),
    headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer ${widget.accessToken}',
      'x-bot-id': widget.botId!,
      'x-integration-id': widget.integrationId!,
    },
  );
  if (response.statusCode == 200) {
    Navigator.pop(context);
     Navigator.pop(context);
    // Optionally, navigate away or update the UI
  } else {
    // Handle error
  }
}

  @override
  Widget build(BuildContext context) {
    return (widget.chatId != null)?Scaffold(
   
      appBar: AppBar(
        backgroundColor:Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
        title: Row(
    
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.chevron_back,size: 40,
                    color: Color(0xFF2D3748),)),
        
            const SizedBox(
              width: 5,
            ),
            if(true)//widget.conversation!['name'] != null)
            GestureDetector(
              onTap: (){
                     //  _showConfirmDelete();
                     
              },
              child: Container(
                                     height: 30,
                              width: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2D3748),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(child: Text( widget.conversation['name'] != null ?  widget.conversation['name'].substring(0, 1).toUpperCase() : '',style: TextStyle(color: Colors.white,fontSize: 14),)),
                                  ),
            ),
                                const SizedBox(
              width: 5,
            ),
             GestureDetector(
              onTap: (){
                 Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return ContactDetail(
                              botToken: widget.botToken!,
                            labels: widget.labels!,
                            name: widget.conversation!['name'],
                            phone: widget.conversation!['tags']['whatsapp:userPhone'],
                            accessToken: widget.accessToken!,
                            contactId: widget.contactId!,
                            integrationId: widget.integrationId!,
                            botId: widget.botId!,
                            conversation: widget.conversation!['id'],
                            pipelineId: widget.pipelineId!,
                            opportunity: widget.opportunity,
                            );
                          }));
                      // _showConfirmDelete();
              },
              child: Container(
                width: 75,
                child: Text((widget.conversation['name'] != null)?widget.conversation!['name']:widget.name,style: const TextStyle(color: Color(0xFF2D3748),fontSize: 18),)),
            ),
        
            
           
             GestureDetector(
              onTap: (){
          
                _launchWhatsapp(widget.conversation!['tags']['whatsapp:userPhone']);
              },
               child: Image.asset(
                                        'assets/images/whatsapp.png',
                                        fit: BoxFit.contain,
                                        scale: 10,
                                      ),
             ),
           
            
            GestureDetector(
              onTap: (){
              
                _launchURL("tel:${widget.conversation!['tags']['whatsapp:userPhone']}");
              },
              child: const Icon(CupertinoIcons.phone_fill,size: 30,color: Color(0xFF2D3748),)),
              
                       
             Transform.scale(
    scale: 0.5,
                child: Switch(
                  
                  activeColor: Color(0xFF019F7D),
                  
                  value: !stopBot,
                 onChanged: (value){
                           
                  sendToWebhook("https://hook.us1.make.com/qd1bcwre4s8p9zfxeovufrwf88y6g4uc",!stopBot);
                     
                       setState(() {
                           stopBot = !stopBot;
                       });
                }),
              ),
                
          ],
        ),

      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            typing = false;
          });
        },
        child: Column(
          children: <Widget>[
          
            Expanded(
              child: Container(
       
                child: ListView.builder(
                     controller: _scrollController, 
                  padding: const EdgeInsets.all(10),
                  itemCount: widget.messages!.length,
                  reverse: true, // To display messages from the bottom
                  itemBuilder: (context, index) {
                    //_handleImageMessage(widget.messages![index]);
                   // print(widget.messages![0]);
               final message = widget.messages![index];
    final type = message['type'];
    final isSent = message['from_me'];
    DateTime parsedDateTime = DateTime.fromMillisecondsSinceEpoch(message['timestamp'] * 1000).toLocal();
    String formattedTime = DateFormat('h:mm a').format(parsedDateTime); // Format for time
                    if (type == 'text') {
                        final messageText = message['text']['body'];
                      return Align(
                        alignment: isSent
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _buildMessageBubble(isSent, messageText, [],formattedTime),
                      );
                    } else if (type == 'image' &&  message['image']['link'] != null) {
                
                      return Align(
                        alignment: isSent
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.network(
                           message['image']['link'],
                            height: 250,
                            width: 250,
                              errorBuilder: (context, error, stackTrace) {
          // Display a placeholder or error message when the image fails to load
          return Container(
            width: 200,
             decoration: BoxDecoration(
              color: isSent
                  ? const Color(0xFF0D85FF)
                  : Color.fromARGB(141, 217, 0, 0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Image failed to load messageImage",maxLines: 1,overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16.0, color: Colors.white,
                                         fontFamily: 'SF',),),
            ));
        },
                          ),
                        ),
                      );
                    } else if (type == 'poll') {
                
               final messageText = message['poll']['title'];
                      return Align(
                          alignment: isSent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: _buildMessageBubble(
                              isSent, messageText, message['poll']['options'],formattedTime));
                    }
      
                    return const SizedBox
                        .shrink(); // Hide if type is not recognized
                  },
                ),
              ),
            ),
            Column(
              children: [
                    if (pickedFile != null)
                                  Stack(
                                    children: [
                                       if(pickedFile!.path!.contains(".mp4"))
                                        ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                            width: 250,
                                            height: 250,
                                            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),),
                                      ),),
                                      if(!pickedFile!.path!.contains(".mp4"))
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                            width: 250,
                                            height: 250,
                                            child: Image.file(
                                              File(pickedFile!.path!),
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          pickedFile = null;
                                       setState(() {
                                         
                                       });
                                  
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              child: const Icon(Icons.close,
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  ),
                Container(
                  height: MediaQuery.of(context).size.height * 15/100, // Set your desired height here
                         
                  child: Row(
                    children: <Widget>[
                      (typing == false)
                          ? IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: _showImageDialog,
                           color: Color(0xFF2D3748),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: GestureDetector(
                                  onTap: () {
                                    typing == false;
                                  },
                                  child: const Icon(
                                    CupertinoIcons.chevron_back,
                                    color: Color(0xFF2D3748),
                                    size: 30,
                                  )),
                            ),
                     /* (typing == false)
                          ? IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _showDocumentDialog,
                           color: Color(0xFF2D3748),
                            )
                          : Container(),*/
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                            
                                border: Border.all( color: Color(0xFF2D3748),)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  
                                  Flexible(
                                    child: TextField(
                                      onTap: () {
                                        setState(() {
                                          typing = true;
                                        });
                                      },
                                      onTapOutside: (event) {
                                        setState(() {
                                          typing = false;
                                        });
                                      },
                                      maxLines: null,
                                      expands: true,
                                      cursorColor: Colors.black,
                                      
                                      style:
                                          const TextStyle( color: Color(0xFF2D3748),
                                           fontFamily: 'SF'),
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    highlightColor: Color(0xFF2D3748),
                                    padding: EdgeInsets.zero,
                                    iconSize: 30,
                                    icon: const Icon(
                                        CupertinoIcons.upload_circle_fill),
                                    onPressed: () async {
                                    
                                      if(pickedFile == null){
                                            await sendMessage2(widget.chatId!);
                                      }else{
                                    await sendImageMessage(widget.conversation['id'],pickedFile!,messageController.text);
                                      }
                         
                               
                                    
                                    },
                                   color: Color(0xFF2D3748),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ):Scaffold(
   
      appBar: AppBar(
        backgroundColor:Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.chevron_back,size: 40,
                    color: Color(0xFF2D3748),)),
       
            const SizedBox(
              width: 5,
            ),
            if(widget.name != null)
            GestureDetector(
              onTap: (){
                     //  _showConfirmDelete();
                     
              },
              child: Container(
                                     height: 30,
                              width: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2D3748),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(child: Text( widget.name!.substring(0, 1).toUpperCase() ,style: TextStyle(color: Colors.white,fontSize: 14),)),
                                  ),
            ),
                                const SizedBox(
              width: 5,
            ),
             GestureDetector(
              onTap: (){
                 Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return ContactDetail(
                              botToken: widget.botToken!,
                            labels: widget.labels!,
                            name: widget.name!,
                            phone:widget.conversation['id'],
                            accessToken: widget.accessToken!,
                            contactId: widget.contactId!,
                            integrationId: widget.integrationId!,
                            botId: widget.botId!,
                            conversation: widget.conversation['convoId'],
                            pipelineId: widget.pipelineId!,
                            opportunity: widget.opportunity,
                            );
                          }));
                      // _showConfirmDelete();
              },
              child: Container(
                width: 55,
                child: Text(widget.name ?? "",style: const TextStyle(color: Color(0xFF2D3748),fontSize: 18),)),
            ),
        
            
              const SizedBox(width: 10,),
             GestureDetector(
              onTap: (){
          
                _launchWhatsapp(widget.conversation['tags']['whatsapp:userPhone']);
              },
               child: Image.asset(
                                        'assets/images/whatsapp.png',
                                        fit: BoxFit.contain,
                                        scale: 10,
                                      ),
             ),
            const SizedBox(width: 5,),
            
            GestureDetector(
              onTap: (){
              
                _launchURL("tel:${widget.conversation['tags']['whatsapp:userPhone']}");
              },
              child: const Icon(CupertinoIcons.phone_fill,size: 30,color: Color(0xFF2D3748),)),
                 const SizedBox(width: 5,),
                       
              Switch(
                activeColor: Color(0xFF019F7D),
                
                value: !stopBot,
               onChanged: (value){
           
                sendToWebhook("https://hook.us1.make.com/qd1bcwre4s8p9zfxeovufrwf88y6g4uc",!stopBot);
                   
                     setState(() {
                         stopBot = !stopBot;
                     });
              }),
                
          ],
        ),

      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            typing = false;
          });
        },
        child: Column(
          children: <Widget>[
          
            Expanded(
              child: Container(
       
                child: ListView.builder(
                     controller: _scrollController, 
                  padding: const EdgeInsets.all(10),
                  itemCount: widget.messages.length,
                  reverse: true, // To display messages from the bottom
                  itemBuilder: (context, index) {
                    _handleImageMessage(widget.messages[index]);
                    print(widget.messages[0]);
                    final message = widget.messages[index];
                
                    final payload = message['payload'];
                    final type = message['type'];
                    final isSent = message['direction'] == 'outgoing';
                    final messageText = payload['text'];
                    final messageImage = payload['imageUrl'];
           DateTime parsedDateTime = DateTime.parse(message['createdAt']).toLocal();
           //todo
String formattedDate = DateFormat('MMM dd, y').format(parsedDateTime); // Format for date
String formattedTime = DateFormat('h:mm a').format(parsedDateTime);   // Format for time
                    if (type == 'text') {
                      return Align(
                        alignment: isSent
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _buildMessageBubble(isSent, messageText, [],formattedTime),
                      );
                    } else if (type == 'image') {
                      return Align(
                        alignment: isSent
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.network(
                            messageImage,
                            height: 250,
                            width: 250,
                              errorBuilder: (context, error, stackTrace) {
          // Display a placeholder or error message when the image fails to load
          return Container(
            width: 200,
             decoration: BoxDecoration(
              color: isSent
                  ? const Color(0xFF0D85FF)
                  : Color.fromARGB(141, 217, 0, 0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Image failed to load $messageImage",maxLines: 1,overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16.0, color: Colors.white,
                                         fontFamily: 'SF',),),
            ));
        },
                          ),
                        ),
                      );
                    } else if (type == 'choice') {
             
                      return Align(
                          alignment: isSent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: _buildMessageBubble(
                              isSent, messageText, payload['options'],formattedTime));
                    }
      
                    return const SizedBox
                        .shrink(); // Hide if type is not recognized
                  },
                ),
              ),
            ),
            Column(
              children: [
                    if (pickedFile != null)
                                  Stack(
                                    children: [
                                       if(pickedFile!.path!.contains(".mp4"))
                                        ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                            width: 250,
                                            height: 250,
                                            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),),
                                      ),),
                                      if(!pickedFile!.path!.contains(".mp4"))
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                            width: 250,
                                            height: 250,
                                            child: Image.file(
                                              File(pickedFile!.path!),
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          pickedFile = null;
                                       setState(() {
                                         
                                       });
                                  
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              child: const Icon(Icons.close,
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  ),
                Container(
                  height: MediaQuery.of(context).size.height * 15/100, // Set your desired height here
                         
                  child: Row(
                    children: <Widget>[
                      (typing == false)
                          ? IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: _showImageDialog,
                           color: Color(0xFF2D3748),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: GestureDetector(
                                  onTap: () {
                                    typing == false;
                                  },
                                  child: const Icon(
                                    CupertinoIcons.chevron_back,
                                    color: Color(0xFF2D3748),
                                    size: 30,
                                  )),
                            ),
                     /* (typing == false)
                          ? IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _showDocumentDialog,
                           color: Color(0xFF2D3748),
                            )
                          : Container(),*/
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                            
                                border: Border.all( color: Color(0xFF2D3748),)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  
                                  Flexible(
                                    child: TextField(
                                      onTap: () {
                                        setState(() {
                                          typing = true;
                                        });
                                      },
                                      onTapOutside: (event) {
                                        setState(() {
                                          typing = false;
                                        });
                                      },
                                      maxLines: null,
                                      expands: true,
                                      cursorColor: Colors.black,
                                      
                                      style:
                                          const TextStyle( color: Color(0xFF2D3748),
                                           fontFamily: 'SF'),
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    highlightColor: Color(0xFF2D3748),
                                    padding: EdgeInsets.zero,
                                    iconSize: 30,
                                    icon: const Icon(
                                        CupertinoIcons.upload_circle_fill),
                                    onPressed: () async {
                                    
                                      if(pickedFile == null){
                                              await sendMessage();
                                      }else{
                                        await uploadFile2();
                                      }
                         
                               
                                    
                                    },
                                   color: Color(0xFF2D3748),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
   Future<void> _handleRefresh() async {
    await fetchConfigurations();
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
       
          await fetchUsersAndConversations(botId, accessToken, integrationId);
         
        } else {
        }
           
      });
    });
  
  }
  Future<void> sendTextMessage(String to, String messageText) async {
  try {
    String url = 'https://gate.whapi.cloud/messages/text';
    var body = json.encode({
      'to': to, // Phone number or Chat ID
      'body': messageText, // Message text
      // Include other parameters as needed
    });

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer ${widget.whapi}', // Replace with your actual Whapi access token
      },
      body: body,
    );
print(response.body);
    if (response.statusCode == 201) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.body}');
    }
  } catch (e) {
    print('Error sending text message: $e');
  }
}
  Future<void> sendMessage2(String to) async {

  try {

    String messageText = _messageController.text;
    Map<String, dynamic> tags = {}; // Replace with your tags
       setState(() {
                                _messageController.clear();
                                pickedFile = null;
                              });
await sendTextMessage(to,messageText);

    // Refresh the message list after sending a message
    await _refreshMessages();
  } catch (e) {
    // Handle error
    print('Error in sendMessage: $e');
  }
}
    Future<void> sendImageMessage(String to, PlatformFile imageFile, String caption) async {
  try {
    // Read the image file as a byte array
    File file = File(imageFile.path!);
    List<int> imageBytes = await file.readAsBytes();
    // Encode the byte array to a Base64 string
    String base64Image = base64Encode(imageBytes);

    // Determine the MIME type (you might want to do this dynamically)
    String mimeType = 'image/jpeg'; // Example MIME type, adjust based on your image
    
    String url = 'https://gate.whapi.cloud/messages/image';
    var body = json.encode({
      'to': to,
      'media': base64Image,
      'mime_type': mimeType,
      'caption': caption,
      // Include other parameters as needed
    });

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer ${widget.whapi}', // Replace with your actual access token
      },
      body: body,
    );

    if (response.statusCode == 201) {
      print('Image message sent successfully');
    } else {
      print('Failed to send image message: ${response.body}');
    }
  } catch (e) {
    print('Error sending image message: $e');
  }
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
    Future<void> fetchUsersAndConversations(
      String botId, String accessToken, String integrationId) async {
    try {
      // Fetch users

        var tags = await extractTagsFromResponse(widget.conversation['tags']['whatsapp:userPhone']);
        var id = await extractContactId(widget.conversation['tags']['whatsapp:userPhone']);
        var template = await extractTemplate(widget.conversation['tags']['whatsapp:userPhone']);
        String userPhone = widget.conversation['tags']['whatsapp:userPhone'];
        var matchedUser = users.firstWhere(
          (user) =>
              user['tags'] != null &&
              user['tags']['whatsapp:userId'] == userPhone,
          orElse: () => {},
        );

        if (matchedUser != null &&
            matchedUser['tags']['whatsapp:name'] != null) {
          // Add the matched user's name to the conversation
          var newEntry =
              MapEntry('whatsapp:name', matchedUser['tags']['whatsapp:name']);
          List<MapEntry<String, dynamic>> newEntries = [newEntry];
          widget.conversation.addEntries(newEntries);
                 var newEntry2 =
              MapEntry('label', tags,);
          List<MapEntry<String, dynamic>> newEntries2 = [newEntry2];
          widget.conversation.addEntries(newEntries2);
                  var newEntry3 =
              MapEntry('contactId', id,);
          List<MapEntry<String, dynamic>> newEntries3 = [newEntry3];
          widget.conversation.addEntries(newEntries3);
             var newEntry4 =
              MapEntry('template',template,);
          List<MapEntry<String, dynamic>> newEntries4 = [newEntry4];
          widget.conversation.addEntries(newEntries4);
          setState(() {
  
    });
    
          
        }
      // Get latest message timestamps for each conversation
      List<Future<DateTime>> latestTimestamps = [];
      List<Future<String>> latestMessages = [];
      List<Map<String, dynamic>> updatedConversations = [];

      for (var conversation in conversations) {
        latestTimestamps.add(getLatestMessageTimestamp(conversation['id']));
        latestMessages.add(getLatestMessage(conversation['id']));
      }

      // Wait for all the timestamps to be fetched
      List<DateTime> timestamps = await Future.wait(latestTimestamps);
      List<String> messages = await Future.wait(latestMessages);

      // Pair each conversation with its latest message timestamp
      for (int i = 0; i < conversations.length; i++) {
        Map<String, dynamic> updatedConversation = Map.from(conversations[i]);
        updatedConversation['latestMessageTimestamp'] = timestamps[i];
        updatedConversation['latestMessage'] = messages[i];
        updatedConversations.add(updatedConversation);
      }

      // Sort conversations by latest message timestamp

      // Extract conversations without the extra timestamp field
      List<Map<String, dynamic>> sortedConversations = updatedConversations
          .map((conversation) => {
                ...conversation,
                'latestMessageTimestamp':
                    conversation['latestMessageTimestamp'],
                'latestMessage': conversation['latestMessage'],
              })
          .toList();

      setState(() {
        this.conversations.addAll(sortedConversations);
      });
    
    } catch (e) {
    }
  }
    Future<List<Map<String, dynamic>>> listConversations() async {
    String url = '$baseUrl/v1/chat/conversations';
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
      
      nextTokenConversation = responseBody['meta']['nextToken'];
      
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
  Future<String> extractContactId(String phone) async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String lookupEndpoint = '/v1/contacts/lookup';
  String contact = "+$phone";
  String token = widget.accessToken!; // Replace with your actual token
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
  Future<String> extractTemplate(String phone) async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String lookupEndpoint = '/v1/contacts/lookup';
  String contact = "+$phone";
  String token = widget.accessToken!; // Replace with your actual token
  String template = "";

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

  return template;
}
Future<List<String>> extractTagsFromResponse(String phone) async {
  String baseUrl = 'https://rest.gohighlevel.com';
  String lookupEndpoint = '/v1/contacts/lookup';
  String contact = "+$phone";
  String token = widget.accessToken!; // Replace with your actual token
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
        nextTokenUser = responseBody['meta']['nextToken'];
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
  
      void sendToWebhook(String webhookUrl,bool stop) async {
        
  if(stop == true){
    await addStopbottag();
             Toast.show(context,"success","Bot Stopped");
        }else{
await deleteStopbottag();
          Toast.show(context,"success","Bot Started");
        }

  }


  void _launchWhatsapp(String number) async {
    String url = 'https://wa.me/$number';
    try {
      await launch(url);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }
  Widget _buildMessageBubble(
      bool isSent, String message, List<dynamic>? options,String time) {

    return Container(
       alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      width: MediaQuery.of(context).size.width * 70 / 100,
      child: Align(
        alignment: isSent ? Alignment.centerRight : Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isSent
                    ? const Color(0xFF0D85FF)
                    : const Color.fromARGB(141, 124, 124, 124),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 17.0, color: Colors.white,
                                           fontFamily: 'SF',),
              ),
            ),
              Text(
                    time,
                    style: const TextStyle(fontSize: 14.0, color: Colors.black,
                                               fontFamily: 'SF',),
                  ),
            if (options!.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
             
                  child: ListView.builder(
                    itemCount: options.length,
                   shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(141, 124, 124, 124),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            options[index]['label'].toString(),
                            style: const TextStyle(
                                fontSize: 16.0, color: Color(0xFF0D85FF),
                                           fontFamily: 'SF',),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
