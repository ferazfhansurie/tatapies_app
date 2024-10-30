import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:juta_app/utils/toast.dart';

class PieOrder {
  String type;
  String size;
  int quantity;

  PieOrder({required this.type, required this.size, required this.quantity});
}

class OrderAdd extends StatefulWidget {
  final String companyId;

  OrderAdd({Key? key, required this.companyId}) : super(key: key);

  @override
  _OrderAddState createState() => _OrderAddState();
}

class _OrderAddState extends State<OrderAdd> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController deliveryFeeController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  String date = "";
  int dateEpoch = 0;
  List<PieOrder> pieOrders = [];
  final List<String> pieTypes = ['Classic Apple Pie', 'Johnny Blueberry', 'Lady Pineapple', "Caramel 'O' Pecan"];
  final List<String> pieSizes = ['Regular 5+” (4-5 servings)', 'Medium 7+” (7-9 servings)', 'Large 9+” (12-14 servings)'];

  void _addNewPieOrder() {
    setState(() {
      pieOrders.add(PieOrder(type: pieTypes.first, size: pieSizes.first, quantity: 1));
    });
  }

  Widget _buildPieOrderInput(PieOrder order, int index) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton(
              value: order.type,
              onChanged: (String? newValue) {
                setState(() {
                  order.type = newValue!;
                });
              },
              items: pieTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
           
           
            IconButton(
              icon: Icon(Icons.delete,color: Colors.red,),
              onPressed: () => setState(() {
                pieOrders.removeAt(index);
              }),
            ),
          ],
        ),
         DropdownButton(
              value: order.size,
              onChanged: (String? newValue) {
                setState(() {
                  order.size = newValue!;
                });
              },
              items: pieSizes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
        Container(
      
          height: 65,
          width: 100,
          child: TextFormField(
                  initialValue: order.quantity.toString(),
                  decoration: InputDecoration(labelText: 'Qty',labelStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      order.quantity = int.tryParse(value) ?? 1;
                    });
                  },
                ),
        ),
        Divider(),
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    _addNewPieOrder(); // Start with one pie order
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20),
        child: ListView(
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
              
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(255, 210, 210, 210),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  children: [
                 
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Recipient Name',
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
                            Divider(
                      color: Color(0xFF2D3748),
                    ),
                    TextField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
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
                    ),         Divider(
                      color: Color(0xFF2D3748),
                    ),
  TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: 'Address',
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
                             Divider(
                      color: Color(0xFF2D3748),
                    ),
  TextField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        hintText: 'Remarks',
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
                     Divider(
                      color: Color(0xFF2D3748),
                    ),
  TextField(
                      controller: deliveryFeeController,
                      decoration: InputDecoration(
                        hintText: 'Delivery (RM)',
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
                          Divider(
                      color: Color(0xFF2D3748),
                    ),
  TextField(
                      controller: totalController,
                      decoration: InputDecoration(
                        hintText: 'Total (RM)',
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
             Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
      
            child: Column(
              children: [
                ...pieOrders.asMap().entries.map((entry) => _buildPieOrderInput(entry.value, entry.key)).toList(),
                ElevatedButton(
                  onPressed: _addNewPieOrder,
                  child: Text('Add Another Pie'),
                ),
                // Rest of your form fields here...
              ],
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
        print('change $date');
        setState(() {
          date = formatDate(date2);
        });
      }, 
    
      onConfirm: (date2) {
        print('confirm $date');
        
        setState(() {
          date = formatDate(date2);
          dateEpoch= date2.millisecondsSinceEpoch;
        });
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
                                               (date != "")? date:"Select Delivery Date",
                                                  style: TextStyle(color: Color(0xFF2D3748),
                                                         fontFamily: 'SF',fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                 
            GestureDetector(
              onTap: () {
               saveOrder();
              },
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Container(
                  width: 260,
                  height: 46,
                  decoration: BoxDecoration(
                      color: Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Save Order",
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
 String formatDate(DateTime dateTime) {
  return DateFormat('EEE, MMM d, yyyy').format(dateTime);
}
void saveOrder() async {
  // Assuming 'type' is a fixed value for this context. Change as necessary.
  String orderType = "Delivery";

  // Convert each PieOrder to a Firestore document
  for (var pieOrder in pieOrders) {
    Map<String, dynamic> orderData = {
      'address': addressController.text,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Or format your selected date
      'delivery_price': double.tryParse(deliveryFeeController.text) ?? 0.0,
      'name': nameController.text,
      'pie': pieOrder.type,
      'quantity': pieOrder.quantity,
      'remarks': remarksController.text,
      'size': pieOrder.size,
      'total': double.tryParse(totalController.text) ?? 0.0,
      'type': orderType,
    };

    try {
      await FirebaseFirestore.instance
          .collection("companies")
          .doc(widget.companyId)
          .collection("orders")
          .add(orderData);

      // Optionally clear form or inform user of success
    } catch (e) {
      // Handle errors
      print(e);
      // Optionally inform user of failure
    }
  }
Navigator.pop(context);
  // Show a success message or clear the form here, if desired.
  Toast.show(context,"success","Order Added");
}
}
