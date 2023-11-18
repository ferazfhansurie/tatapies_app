

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:juta_app/screens/drip.dart';

// ignore: must_be_immutable
class BlastScreen extends StatefulWidget {
  List<dynamic> opp;
  Map<String, dynamic> auto;
  BlastScreen({super.key, required this.opp, required this.auto});

  @override
  State<BlastScreen> createState() => _BlastScreenState();
}

class _BlastScreenState extends State<BlastScreen> {
  TextEditingController searchController = TextEditingController();
  bool checkAll = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF3790DD),
                      fontSize: 16,
                      fontFamily: 'SF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    List<dynamic> selected = [];
                    for (int i = 0; i < widget.opp.length; i++) {
                      if (widget.opp[i]['selected'] == true) {
                        selected.add(widget.opp[i]);
                      }
                    }
                    print(selected);
                    _showBlastSetting(200, selected);
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Color(0xFF3790DD),
                      fontSize: 16,
                      fontFamily: 'SF',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
                height: 600,
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusColor: Colors.white,
                              hoverColor: Colors.white,
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  color: Color(0xFFB3B3B3),
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
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Select All",
                              style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),
                            ),
                            Checkbox(
                              checkColor: Colors.black,
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.black.withOpacity(.32);
                                }
                                return Colors.white;
                              }),
                              value: checkAll,
                              onChanged: (value) {
                                setState(() {
                                  checkAll = value!;
                                  if (checkAll == true) {
                                    for (int i = 0;
                                        i < widget.opp.length;
                                        i++) {
                                      widget.opp[i]['selected'] = true;
                                    }
                                  } else {
                                    for (int i = 0;
                                        i < widget.opp.length;
                                        i++) {
                                      widget.opp[i]['selected'] = false;
                                    }
                                  }
                                });
                              },
                            )
                          ]),
                    ),
                    Divider(
                      height: 1,
                      color: Color.fromARGB(255, 19, 19, 19),
                    ),
                    Flexible(
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: widget.opp.length,
                            itemBuilder: (context, index) {
                              return Material(
                                color: Colors.black,
                                child: ListTile(
                                  title: Text(
                                    widget.opp[index]['name'],
                                    style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),
                                  ),
                                  trailing: Checkbox(
                                    checkColor: Colors.black,
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.black.withOpacity(.32);
                                      }
                                      return Colors.white;
                                    }),
                                    value: widget.opp[index]['selected'],
                                    onChanged: (value) {
                                      setState(() {
                                        widget.opp[index]['selected'] = value;
                                        print(value);
                                      });
                                    },
                                  ),
                                ),
                              );
                            })),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  _showBlastSetting(double height, List<dynamic> selected) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        print(selected);
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Blasting Setting',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 16,
                                           fontFamily: 'SF',
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Container(
                color: Colors.black,
                height: height,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          sendAllAtOnce(selected);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 100,
                              child: Text(
                                'Now',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 16,
                                           fontFamily: 'SF',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Icon(Icons.send_outlined),
                          ],
                        ),
                      ),
                      Divider(
                        color: Color.fromARGB(255, 19, 19, 19),
                      ),
                   /*   Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 100,
                            child: Text(
                              'Scehdule',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 16,
                                           fontFamily: 'SF',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Icon(CupertinoIcons.clock),
                        ],
                      ),
                      Divider(
                        color: Color.fromARGB(255, 19, 19, 19),
                      ),*/
                      GestureDetector(
                        onTap: () {
                      
                           Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (context) {
                            return BlastSettingPage(autowebhook: widget.auto['webhook'],selected:selected);
                          }));
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 100,
                                child: Text(
                                  'Drip',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Icon(CupertinoIcons.drop),
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

  void sendAllAtOnce(List<dynamic> selectedContacts) {
    for (var contact in selectedContacts) {
      if (contact['selected']) {
        String contactId = contact['id'];
        print(contactId);
        // Construct the webhook URL
        String webhookUrl = widget.auto['webhook'];

        // Send data to webhook for this contact
        sendToWebhook(webhookUrl, contactId);
      }
    }
  }

  void sendToWebhook(String webhookUrl, String contactId) async {
    try {
      Map<String, dynamic> leadData = {'contact': contactId};
      var response = await http.post(
        Uri.parse(webhookUrl),
        body: leadData,
      );

      print(response.body);
      if (response.statusCode == 200) {
        print('Webhook triggered successfully for contact ID: $contactId');
        Navigator.pop(context);
      } else {
        print(
            'Error triggering webhook for contact ID: $contactId. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error triggering webhook for contact ID: $contactId: $e');
    }
  }
}
