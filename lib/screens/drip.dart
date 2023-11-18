// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class BlastSettingPage extends StatefulWidget {
  String autowebhook;
  List<dynamic> selected;
  BlastSettingPage(
      {super.key, required this.autowebhook, required this.selected});
  @override
  _BlastSettingPageState createState() => _BlastSettingPageState();
}

class _BlastSettingPageState extends State<BlastSettingPage> {
  DateTime startOn = DateTime.now();
  int batchQuantity = 1;
  Duration repeatAfter = Duration(days: 1);
  List<String> sendOnDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  bool sendOnMon = false;
  bool sendOnTue = false;
  bool sendOnWed = false;
  bool sendOnThu = false;
  bool sendOnFri = false;
  bool sendOnSat = false;
  bool sendOnSun = false;
  TimeOfDay processStartTime = TimeOfDay.now();
  TimeOfDay processEndTime = TimeOfDay.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 1));
  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20),
        color: Colors.black,
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
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Color(0xFF3790DD),
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
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
                      'Drip Mode',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: startOn,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (selectedDate != null && selectedDate != startOn) {
                    setState(() {
                      startOn = selectedDate;
                    });
                  }
                },
                child: Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 19, 19, 19),
                      borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Start Date: ${DateFormat('dd/MM/yyyy').format(startOn.toLocal())}',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                _selectStartTime(context);
              },
              child: Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 19, 19, 19),
                    borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Start Time: ${processStartTime.format(context)}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () async {
                final selectedEndDate = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedEndDate != null && selectedEndDate != endDate)
                  setState(() {
                    endDate = selectedEndDate;
                  });
              },
              child: Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 19, 19, 19),
                    borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'End Date: ${DateFormat('dd/MM/yyyy').format(endDate.toLocal())}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                _selectEndTime(context);
              },
              child: Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 19, 19, 19),
                    borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'End Time: ${processEndTime.format(context)}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                height: 75,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 19, 19, 19),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        batchQuantity = int.parse(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Batch Quantity:',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                height: 75,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 19, 19, 19),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        repeatAfter = Duration(days: int.parse(value));
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Repeat After (days)',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 19, 19, 19),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            "Send On",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 30,
                          child: ListView.builder(
                              itemCount: 7,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: ((context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (!sendOnDays.contains(days[index])) {
                                          sendOnDays.add(days[index]);
                                        } else {
                                          sendOnDays.remove(days[index]);
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: (!sendOnDays
                                                  .contains(days[index]))
                                              ? Color.fromARGB(255, 0, 0, 0)
                                              : Color(0xFF3790DD),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          days[index],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })),
                        )
                      ],
                    )),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                sendToWebhook();
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                width: 260,
                height: 46,
                decoration: BoxDecoration(
                    color: Color(0xFF3790DD),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    'Send',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectStartTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null && selectedTime != processStartTime) {
      setState(() {
        processStartTime = selectedTime;
      });
    }
  }

  void _selectEndTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null && selectedTime != processEndTime) {
      setState(() {
        processEndTime = selectedTime;
      });
    }
  }

  void sendToWebhook() async {
    try {
      final String webhookUrl =
          'https://us-central1-onboarding-a5fcb.cloudfunctions.net/sendDataOnDripHTTP'; // Replace with your actual Cloud Function URL

      // Convert processStartTime and processEndTime to ISO 8601 format
      String processStartTimeISO = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        processStartTime.hour,
        processStartTime.minute,
      ).toIso8601String();

      String processEndTimeISO = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        processEndTime.hour,
        processEndTime.minute,
      ).toIso8601String();

      Map<String, dynamic> dripData = {
        'webhook': widget.autowebhook,
        'startOn': processStartTimeISO, // Updated to processStartTime
        'endOn': processEndTimeISO, // Updated to processEndTime
        'batchQuantity': batchQuantity,
        'repeatAfter': repeatAfter.inDays,
        'sendOnDays': sendOnDays,
        'contacts': widget.selected,
      };

      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dripData),
      );

      print(response.body);

      if (response.statusCode == 200) {
        print('Data sent successfully');
      } else {
        print('Error sending data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending data: $error');
    }
  }
}
