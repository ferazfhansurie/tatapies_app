// ignore_for_file: must_be_immutable, unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juta_app/screens/dashboard.dart';
import 'package:juta_app/utils/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class Conversations extends StatefulWidget {
  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
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
  bool _isLoadingData = false; 
  String company = '';
  String companyId = '';
  final String baseUrl = "https://api.botpress.cloud";
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<dynamic> allUsers = [];
  Future<void> fetchConfigurations() async {
    email = user!.email!;
       _isLoadingData = true; 
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
        print("companyId:" + companyId);
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
            print("accessToken:" + accessToken);
            botId = snapshot.get("botId");
            integrationId = snapshot.get("integrationId");
            workspaceId = snapshot.get("workspaceId");
          });
          await fetchUsersAndConversations(botId, accessToken, integrationId);
         
        } else {
          print("Snapshot not found");
        }
           
      });
    });
     _isLoadingData = false; 
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
      print("Error adding user to Firebase: $e");
    }
  }

  Future<void> fetchUsersAndConversations(
      String botId, String accessToken, String integrationId) async {
    try {
      // Fetch users

   
      List users = await listUsers();

      // Fetch conversations
      List<Map<String, dynamic>> conversations = await listConversations();

      // Match users to conversations based on phone numbers
      for (var conversation in conversations) {
        String userPhone = conversation['tags']['whatsapp:userPhone'];
        var matchedUser = users.firstWhere(
          (user) =>
              user['tags'] != null &&
              user['tags']['whatsapp:userId'] == userPhone,
          orElse: () => null,
        );

        if (matchedUser != null &&
            matchedUser['tags']['whatsapp:name'] != null) {
          // Add the matched user's name to the conversation
          var newEntry =
              MapEntry('whatsapp:name', matchedUser['tags']['whatsapp:name']);
          List<MapEntry<String, dynamic>> newEntries = [newEntry];
          conversation.addEntries(newEntries);
          setState(() {
  
    });
          await addUserToFirebase({
            'id': matchedUser['tags'][
                'whatsapp:userId'], // Assuming 'id' is a unique identifier for each user
            'name': matchedUser['tags']['whatsapp:name'],
            // Add other user data as needed
          }, companyId);
          
        }
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
      print(conversations);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List> listUsers() async {
    String url = '$baseUrl/v1/chat/users';

    print(integrationId);
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
    print(response.body);
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

  void onSearchTextChanged(String text) {
    setState(() {
      filter = text;
    });
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
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> conversationList = responseBody['conversations'];
      nextTokenConversation = responseBody['meta']['nextToken'];
      print(nextTokenConversation);
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
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> messages = responseBody['messages'];
      for (int i = 0; i < messages.length; i++) {
        print(messages[i]['userId']);
      }
      return messages.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  void navigateToMessageScreen(List<Map<String, dynamic>> messages,
      Map<String, dynamic> conversation, String id) {
    ProgressDialog.unshow(context, progressDialogKey);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          messages: messages,
          conversation: conversation,
          accessToken: accessToken,
          botId: botId,
          integrationId: integrationId,
          workspaceId: workspaceId,
          id: id,
          userId: messages.first['userId'] ?? "",
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await fetchConfigurations();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
    _handleRefresh();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has reached the end of the list, load more conversations
      _loadMoreConversations();
    }
  }

  void _loadMoreConversations() async {
    if (_isLoading) return; // Prevent multiple simultaneous requests
    setState(() {
      _isLoading = true;
    });

    try {
      
          await fetchUsersAndConversations(botId,accessToken,integrationId);

    
    } catch (e) {
      print('Error loading more conversations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
  }Future<void> conversationPage() async {
    // Use a GlobalKey to access the Scaffold and open the drawer
   setState(() {
      currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 20,
        ),
        color: const Color.fromARGB(255, 0, 0, 0), // Background color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                        Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (context) {
                                      return Dashboard(
                                      conversation:conversationPage ,openDrawerCallback: (){},
                                      );
                                    }));
                                  },
                                  child: Icon(
                                    CupertinoIcons.chevron_back,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                SizedBox(width: 20,),
                                
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
                             
                                Row(
                                  children: [
                                   
                                    SizedBox(
                                      width: 10,
                                    ),
                                  
                                  ],
                                ),
                              
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Conversations",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20,
                                           fontFamily: 'SF',
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 19, 19, 19),
                    borderRadius: BorderRadius.circular(15)),
                height: 35,
                child: TextField(
                  style: const TextStyle(color: Colors.white,
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
                        TextStyle(color: Color(0xFFB3B3B3),
                                           fontFamily: 'SF', fontSize: 15),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 22,
                      color: Color(0xFFB3B3B3),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: RefreshIndicator(
                color: Colors.black,
                onRefresh: _handleRefresh,
                child: _isLoadingData
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              :ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: filteredConversations().length,
                  itemBuilder: (context, index) {
              
                    final conversation = filteredConversations()[index];
                    final id = conversation['id'];
                    final userName = conversation['whatsapp:name'];
                    final number = conversation['latestMessage'];

                    DateTime latestMessageTimestamp =
                        conversation['latestMessageTimestamp'];
                    DateTime today = DateTime.now();
                    Duration difference =
                        today.difference(latestMessageTimestamp);

                    String updatedAtText = difference.inDays == 0
                        ? 'Today'
                        : (difference.inDays == 1
                            ? 'Yesterday'
                            : '${latestMessageTimestamp.day}/${latestMessageTimestamp.month}/${latestMessageTimestamp.year}');

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          ProgressDialog.show(context, progressDialogKey);

                          listMessages(id).then((messages) {
                            navigateToMessageScreen(messages, conversation, id);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(
                                CupertinoIcons.person_circle_fill,
                                color: Color(0xFFB3B3B3),
                                size: 45,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    height: 1,
                                    color: Color.fromARGB(255, 19, 19, 19),
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 165,
                                        child: Text(
                                          userName ?? "Webchat",
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                           fontFamily: 'SF',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                     
                                      Text(
                                       updatedAtText,
                                        style: const TextStyle(
                                          color: Color(0xFFB3B3B3),
                                           fontFamily: 'SF',
                                        fontSize: 11
                                      
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 30,
                                    child: Text(
                                      number ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFFB3B3B3),
                                           fontFamily: 'SF',
                                        fontWeight: FontWeight.w400,
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
  MessageScreen(
      {required this.messages,
      required this.conversation,
      this.botId,
      this.accessToken,
      this.workspaceId,
      this.integrationId,
      this.id,
      this.userId});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _messageController = TextEditingController();

  bool typing = false;
  bool expand = false;
  double height = 60;
  bool hasNewline = false;
  bool nowHasNewline = false;
  final String baseUrl = "https://api.botpress.cloud";
  @override
  void initState() {
    super.initState();

    _messageController.addListener(() {
      String value = _messageController.text;
      List<String> lines = value.split('\n');
      int newHeight = 60 + (lines.length - 1) * 25;

      if (value.length > 29) {
        int additionalHeight = ((value.length - 1) ~/ 29) * 25;
        newHeight += additionalHeight;
      }

      setState(() {
        height = newHeight.clamp(60, 200).toDouble();
      });
    });
  }

  Future<void> _handleImageMessage(Map<String, dynamic> message) async {
    final type = message['type'];
    if (type == 'image') {
      print('User sent an image');
      print('Message data: $message'); // Print the data of the incoming message

      // Add your logic for handling image messages here
    }
  }

  Future<List<Map<String, dynamic>>> listMessages(String botId,
      String accessToken, String integrationId, String conversationId) async {
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
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> messages = responseBody['messages'];

      return messages.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<Map<String, dynamic>?> createMessage({
    required String payloadType,
    required String userId,
    required String conversationId,
    required String messageType,
    required Map<String, dynamic> tags,
    Map<String, dynamic>? schedule,
    required String text,
  }) async {
    String url = '$baseUrl/v1/chat/messages';
    Map<String, dynamic> requestBody = {
      'payload': {
        'type': payloadType,
        'text': text
      }, // Include the text property
      'userId': userId,
      'conversationId': conversationId,
      'type': messageType,
      'tags': tags,
    };

    if (schedule != null) {
      requestBody['schedule'] = schedule;
    }

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer ${widget.accessToken}',
        'x-bot-id': widget.botId!,
        'x-integration-id': widget.integrationId!,
      },
      body: json.encode(requestBody),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      Map<String, dynamic> tags = {}; // Replace with your tags

      createMessage(
        payloadType: 'Text',
        userId: widget.userId!,
        conversationId: widget.id!,
        messageType: 'text',
        tags: tags,
        text: messageText,
      ).then((createdMessage) async {
        print('Created Text Message: $createdMessage');

        // Refresh the message list after sending a message
        await _refreshMessages();
      }).catchError((e) {
        print('Error sending message: $e');
      });
      _messageController.clear();
    }
  }

  Future<void> _refreshMessages() async {
    List<Map<String, dynamic>> updatedMessages = await listMessages(
        widget.botId!,
        widget.accessToken!,
        widget.integrationId!,
        widget.conversation['id']);
    setState(() {
      widget.messages = updatedMessages;
    });
  }

  void _showImageDialog() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Handle the picked image
      // For example, you can upload it or display it in your UI
      // The picked image file can be accessed using pickedFile.path
    }
  }

  Future<void> _showDocumentDialog() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickMedia();

    if (pickedFile != null) {
      // Handle the picked image
      // For example, you can upload it or display it in your UI
      // The picked image file can be accessed using pickedFile.path
    }
  }
  void _showConfirmDelete() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.5, // Adjust height as needed
          color: Colors.black,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(
                    width: 35,
                  ),
                  Center(
                      child: Text(
                    'Detail',
                    style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),
                  ))
                ],
              ),
              Divider(
                color: Colors.white,
              ),
              Text(widget.conversation['whatsapp:name'] ?? "",
                    style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),),
                                           Spacer(),
               GestureDetector(
                onTap: (){
                 deleteConversation(widget.conversation['id'] );
                },
                 child: Container(
                             margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                             padding: const EdgeInsets.all(8.0),
                             decoration: BoxDecoration(
                  color:Color.fromARGB(141, 235, 17, 17),
                  borderRadius: BorderRadius.circular(12),
                             ),
                             child: Text(
                  "Delete Conversation",
                  style: const TextStyle(fontSize: 16.0, color: Colors.white,
                                             fontFamily: 'SF',),
                             ),
                           ),
               ),
            ],
          ),
        );
      },
    );
  }
  void _showQuickRepliesPopup() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.5, // Adjust height as needed
          color: Colors.black,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(
                    width: 35,
                  ),
                  Center(
                      child: Text(
                    'Quick Replies',
                    style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),
                  ))
                ],
              ),
              Divider(
                color: Colors.white,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: ((context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Reply $index',
                            style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),
                          ),
                          Divider(
                            color: Colors.white,
                          ),
                        ],
                      );
                    })),
              ),
            ],
          ),
        );
      },
    );
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
    print('Conversation deleted');
    Navigator.pop(context);
     Navigator.pop(context);
    // Optionally, navigate away or update the UI
  } else {
    print('Failed to delete conversation');
    // Handle error
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.chevron_back,size: 40,
                    color: Colors.white)),
            const SizedBox(
              width: 25,
            ),
            const Icon(
              CupertinoIcons.person_alt_circle_fill,
              color: Colors.white,
              size: 25,
            ),
            SizedBox(
              width: 5,
            ),
            Text(widget.conversation['whatsapp:name'] ?? ""),
            Spacer(),
             GestureDetector(
              onTap: (){
                print(widget.conversation);
                _launchWhatsapp(widget.conversation['tags']['whatsapp:userPhone']);
              },
               child: Image.asset(
                                        'assets/images/whatsapp.png',
                                        fit: BoxFit.contain,
                                        scale: 10,
                                      ),
             ),
            SizedBox(width: 10,),
            GestureDetector(
              onTap: (){
              
                _launchURL("tel:${widget.conversation['tags']['whatsapp:userPhone']}");
              },
              child: Icon(CupertinoIcons.phone_fill,size: 30,)),
                 SizedBox(width: 20,),
                  GestureDetector(
                    onTap: (){
                      _showConfirmDelete();
                    },
                    child: const Icon(
                                CupertinoIcons.ellipsis,
                                color: Colors.white,
                                size: 25,
                              ),
                  ),
          ],
        ),
        backgroundColor: Colors.black, // Secondary color
      ),
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: _refreshMessages,
        child: GestureDetector(
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
                  color: const Color.fromARGB(255, 0, 0, 0), // Background color
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.messages.length,
                    reverse: true, // To display messages from the bottom
                    itemBuilder: (context, index) {
                      _handleImageMessage(widget.messages[index]);
                      final message = widget.messages[index];

                      final payload = message['payload'];
                      final type = message['type'];
                      final isSent = message['direction'] == 'outgoing';
                      final messageText = payload['text'];
                      final messageImage = payload['imageUrl'];

                      if (type == 'text') {
                        return Align(
                          alignment: isSent
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: _buildMessageBubble(isSent, messageText, []),
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
                            ),
                          ),
                        );
                      } else if (type == 'choice') {
                        print(message);
                        return Align(
                            alignment: isSent
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: _buildMessageBubble(
                                isSent, messageText, payload['options']));
                      }

                      return const SizedBox
                          .shrink(); // Hide if type is not recognized
                    },
                  ),
                ),
              ),
              Card(
                elevation: 5,
                child: Container(
                  height: height, // Set your desired height here
                  color: Colors.black, // Background color
                  child: Row(
                    children: <Widget>[
                      (typing == false)
                          ? IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: _showImageDialog,
                              color: Color(0xFFB3B3B3), // Secondary color
                            )
                          : Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: GestureDetector(
                                  onTap: () {
                                    typing == false;
                                  },
                                  child: const Icon(
                                    CupertinoIcons.chevron_back,
                                    color: Color(0xFFB3B3B3),
                                    size: 30,
                                  )),
                            ),
                      (typing == false)
                          ? IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _showDocumentDialog,
                              color: Color(0xFFB3B3B3), // Secondary color
                            )
                          : Container(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.black,
                                border: Border.all(color: Color(0xFFB3B3B3))),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
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
                                      style:
                                          const TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    highlightColor: Color(0xFF0D85FF),
                                    padding: EdgeInsets.zero,
                                    iconSize: 30,
                                    icon: const Icon(
                                        CupertinoIcons.upload_circle_fill),
                                    onPressed: sendMessage,
                                    color: const Color(
                                        0xFF0D85FF), // Secondary color
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
              ),
            ],
          ),
        ),
      ),
    );
  }
  _launchURL(String url) async {
    await launch(Uri.parse(url).toString());
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
      bool isSent, String message, List<dynamic>? options) {
    print(options);
    return Container(
       alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      width: MediaQuery.of(context).size.width * 70 / 100,
      child: Align(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
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
                style: const TextStyle(fontSize: 16.0, color: Colors.white,
                                           fontFamily: 'SF',),
              ),
            ),
            if (options!.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
             
                  child: ListView.builder(
                    itemCount: options.length,
                   shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
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
              )
          ],
        ),
      ),
    );
  }
}
