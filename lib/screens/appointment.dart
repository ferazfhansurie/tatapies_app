import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  List<dynamic> appointments = [];

  String botId = '';
  String accessToken = '';
  String workspaceId = '';
  String integrationId = '';
  User? user = FirebaseAuth.instance.currentUser;
  String email = '';
  String firstName = '';
  String company = '';
  String companyId = '';
  String calendarId = '';
  String pipelineId = '';
  String apiKey = ''; // Replace with your actual token
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
            calendarId = snapshot.get("calendarId");
            pipelineId = snapshot.get("pipelineId");
            apiKey = snapshot.get("apiKey");
          });
             await fetchAppointments();
        } else {
          print("Snapshot not found");
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchConfigurations();

  }

  Future<void> fetchAppointments() async {

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: 30));
    DateTime endOfWeek = now.add(Duration(days: 6));

    int startDate = startOfWeek.toUtc().millisecondsSinceEpoch;
    int endDate = endOfWeek.toUtc().millisecondsSinceEpoch;
    try {
      List<dynamic> fetchedAppointments =
          await getAppointments(calendarId, startDate, endDate);
      setState(() {
        appointments = fetchedAppointments;
      });
      print(appointments.toList());
    } catch (error) {
      print(error);
    }
  }

  Future<List<dynamic>> getAppointments(
      String calendarId, int startDate, int endDate) async {
    String apiUrl = 'https://rest.gohighlevel.com/v1/appointments/';



    Map<String, String> headers = {
      'Authorization': 'Bearer $apiKey',
    };

    String urlWithParams = apiUrl +
        '?calendarId=$calendarId&startDate=$startDate&endDate=$endDate&includeAll=true';

    try {
      final response = await http.get(
        Uri.parse(urlWithParams),
        headers: headers,
      );
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        List<dynamic> appointments = responseBody['appointments'];
        return appointments;
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (error) {
      print(error);
      throw Exception('Failed to load appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.sizeOf(context).height,
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 20, right: 20),
        color: Color.fromARGB(255, 0, 0, 0), // Background color
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                        SizedBox(
                          height: 10,
                        ),
                        Text('Appointments',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                           fontFamily: 'SF',
                                color: Colors.white)),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TableCalendar(
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, _) {
                                // Check if date has appointments
                                bool hasAppointments =
                                    appointments.any((appointment) {
                                  var startTime =
                                      DateTime.parse(appointment['startTime']);
                                  var formattedDate = DateFormat('yyyy-MM-dd')
                                      .format(startTime);
                                  return formattedDate ==
                                      DateFormat('yyyy-MM-dd').format(date);
                                });

                                return Container(
                                  margin: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: hasAppointments
                                        ? Color(0xFF6CD8FF)
                                        : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF',),
                                    ),
                                  ),
                                );
                              },

                              // Add other properties as needed
                            ),
                            rowHeight: 35,
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: DateTime.now(),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(color: Colors.white),
                              weekendTextStyle: TextStyle(color: Colors.white),
                              holidayTextStyle: TextStyle(color: Colors.white),
                              outsideDaysVisible: false,
                              todayTextStyle: TextStyle(color: Colors.white),
                              todayDecoration: BoxDecoration(
                                color: Color(0xFF6CD8FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                        ),
                        Container(
                          height: MediaQuery.sizeOf(context).height * 39 / 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (appointments.isEmpty)
                                  ? Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: const Color.fromARGB(
                                                255, 109, 109, 109)),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          'No appointments scheduled',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 15,
                                           fontFamily: 'SF',
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 109, 109, 109)),
                                        ),
                                      ],
                                    )
                                  : Flexible(
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: appointments.length,
                                        itemBuilder: (context, index) {
                                          var appointment = appointments[index];
                                          var endTime = DateTime.parse(
                                              appointment['endTime']);
                                          var startTime = DateTime.parse(
                                              appointment['startTime']);
                                          var formattedStartTime =
                                              DateFormat('EEE dd/MM')
                                                  .format(startTime);
                                          var temp =
                                              formattedStartTime.split(' ');
                                          var formattedStartTime2 =
                                              DateFormat('hh:mma')
                                                  .format(startTime);
                                          var formattedEndTime2 =
                                              DateFormat('hh:mma')
                                                  .format(endTime);
                                          return Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(temp[0],
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFF6CD8FF),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                           fontFamily: 'SF',
                                                                fontSize: 15)),
                                                        Text(temp[1],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                           fontFamily: 'SF',
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            10), // Add some spacing between date and title
                                                    Container(
                                                        width: 245,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: Color(
                                                                0xFF1C1C1E)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  appointment[
                                                                      'title'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                           fontFamily: 'SF',),),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    height: 5,
                                                                    width: 5,
                                                                    decoration: BoxDecoration(
                                                                        color: Color(
                                                                            0xFF6CD8FF),
                                                                        borderRadius:
                                                                            BorderRadius.circular(100)),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    '$formattedStartTime2 - $formattedEndTime2',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                           fontFamily: 'SF',
                                                                        fontSize:
                                                                            10),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ]))
            ]));
  }
}
