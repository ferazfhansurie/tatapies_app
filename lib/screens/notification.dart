import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  List<dynamic> noti;
  NotificationScreen({super.key, required this.noti});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
 @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20,

      ),
      color: Color.fromARGB(255, 0, 0, 0), // Background color
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.chevron_left,
                    size: 40,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Notifications',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Divider(
              height: 1,
              color: Color.fromARGB(255, 19, 19, 19),
              thickness: 1,
            ),
            SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.noti.length,
                itemBuilder: (context, index) {
                  final notification = widget.noti[index];
  final dateFormat = DateFormat('h:mm a d/M/yyyy');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 200, // Adjust width as needed
                            child: Text(
                              notification['name'] ?? "Webchat",
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
                             dateFormat.format(DateTime.parse(notification['sentTime'])) ?? "",
                            style: const TextStyle(
                              color: Color(0xFF3790DD),
                              fontFamily: 'SF',
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        notification['body'] ?? "",
                        style: TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontFamily: 'SF',
                          fontWeight: FontWeight.w400,
                          fontSize: 14
                        ),
                      ),
                         SizedBox(height: 10),
                      Divider(
                        height: 1,
                        color: Color.fromARGB(255, 19, 19, 19),
                        thickness: 1,
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}