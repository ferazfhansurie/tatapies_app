// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juta_app/utils/progress_dialog.dart';
import 'package:juta_app/utils/toast.dart';

class Contact extends StatefulWidget {
  String companyId;
  Contact({super.key, required this.companyId});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
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
              setState(() {
                        phoneNumberController.clear();
          nameController.clear();
              });
    
        }
      });
    } catch (e) {
      print("Error adding user to Firebase: $e");
    }
      
    ProgressDialog.unshow(context, progressDialogKey);
  }

  void saveContact() async {
    String name = nameController.text;
    String phoneNumber = phoneNumberController.text;

    if (name.isNotEmpty && phoneNumber.isNotEmpty) {
      Map<String, dynamic> userData = {
        'id': phoneNumber, // Assuming 'id' is the field for phone number
        'name': name,
      };

      await addUserToFirebase(
          userData, widget.companyId); // Replace with actual company ID

      // Optionally, you can show a confirmation dialog or navigate to another screen.
    } else {
      // Handle case where one or both fields are empty.
      Toast.show(context, "danger", "Both cannot be empty");
      print("Both fields are required");
    }
  }

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
                    saveContact();
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
            Padding(
              padding: const EdgeInsets.all(25),
              child: Icon(CupertinoIcons.person_circle,
                  color: Colors.white, size: 45),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFF2C2C2E),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
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
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SF',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
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
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SF',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                saveContact();
              },
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Container(
                  width: 260,
                  height: 46,
                  decoration: BoxDecoration(
                      color: Color(0xFF3790DD),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white,
                                           fontFamily: 'SF', fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
