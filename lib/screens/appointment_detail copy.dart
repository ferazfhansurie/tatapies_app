// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:juta_app/utils/progress_dialog.dart';
import 'package:juta_app/utils/toast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AppointmentDetailCopy extends StatefulWidget {

  AppointmentDetailCopy({super.key });

  @override
  State<AppointmentDetailCopy> createState() => _AppointmentDetailCopyState();
}

class _AppointmentDetailCopyState extends State<AppointmentDetailCopy> {
    TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20),
          child: GestureDetector(
            onTap: () {
             FocusScope.of(context).unfocus();
            },
            child: ListView(
              shrinkWrap: true,
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
                     
                       
                      },
                      child: const Text(
                        'Save',
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
                SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                       
                        child: Row(
                          children: [
                            Container(
                                                 height: 50,
                                          width:50
                                          ,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2D3748),
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                child: Center(child: Text(  '',style: TextStyle(color: Colors.white,fontSize: 14),)),
                                              ),
                                              SizedBox(width: 20,),
                                                 Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                     Text(
                                                     '',
                                                      style: TextStyle(color: Color(0xFF2D3748),
                                                             fontFamily: 'SF',fontWeight: FontWeight.bold),),
                                                             Text(
                                                  '',
                                                  style: TextStyle(color: Color(0xFF2D3748),
                                                         fontFamily: 'SF',fontWeight: FontWeight.w300),),
                                                            Text(
                                                  "",
                                                  style: TextStyle(color: Color(0xFF2D3748),
                                                         fontFamily: 'SF',fontWeight: FontWeight.w300),),  
                                                   ],
                                                 ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
 
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                           DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2024, 1, 1),
      onChanged: (date2) {
       
      }, 
    
      onConfirm: (date2) {
     
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,color: Color(0xFF2D3748),size: 25,), 
                            SizedBox(width: 20,),
                            Text(
                                                '',
                                                  style: TextStyle(color: Color(0xFF2D3748),
                                                         fontFamily: 'SF',fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                    GestureDetector(
                      onTap: () async {
                       
                  
            
                    
                      },
                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.punch_clock,color: Color(0xFF2D3748),size: 25,), 
                            SizedBox(width: 20,),
                            Text(
                                                 '',
                                                  style: TextStyle(color: Color(0xFF2D3748),
                                                         fontFamily: 'SF',fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                                        ),
                                      ),
                    ),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Card(
                                     child:    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Icon(Icons.notes,color: Color(0xFF2D3748),size: 25,), 
                            SizedBox(width: 20,),
                          Container(
                            width: 270,
                            height: 200,
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                                    controller: nameController,
                                    expands: true,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText: 'Notes (Optional)',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF2D3748),
                                        fontSize: 16,
                                        fontFamily: 'SF',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent, // Remove border color
                                          width: 0,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent, // Remove border color
                                          width: 0,
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Color(0xFF2D3748),
                                      fontSize: 16,
                                      fontFamily: 'SF',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                                     ),
                                   ),
                   ),
            
                     
              ],
            ),
          ),
        ),
      ),
    );
  }
  String formatEpoch(int epoch) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}
String formatDate(DateTime dateTime) {
  return DateFormat('EEE, MMM d, yyyy').format(dateTime);
}
    _showStatus() {
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
     
          ],
        );
      },
    );
  }
    _showSlots(List<String> date) {
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
                height: 500,
                width: double.infinity,
                child: Container(
                  color: Colors.white,
                  child:      ListView.builder(
                        shrinkWrap: true,
              itemCount: date.length,
         
              itemBuilder: (context,index){
    
                   // Parse the ISO string
      

          // Format the time
         String formattedTime = formatIsoString(date[index]);
   
              return   Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: GestureDetector(
                            onTap: () {
                         setState(() {
            
                         });
                         Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment:MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          color: Color(0xFF2D3748)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                        Icons.punch_clock,
                                          color: Colors.white,
                                        ),
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(formattedTime,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'SF',
                                          color: Color(0xFF020913))),
                                ],
                              ),
                            ),
                          ),
                ),
              );
            },)
                )),
          ],
        );
      },
    );
  }
String formatIsoString(String isoString) {
  // Parse the ISO string without converting it to local time
  DateTime utcTime = DateTime.parse(isoString).toUtc();

  // Since the time is in +08:00 time zone, add 8 hours to the UTC time
  DateTime correctedTime = utcTime.add(Duration(hours: 8));

  // Format the time
  return DateFormat('h:mm a').format(correctedTime);
}


}
