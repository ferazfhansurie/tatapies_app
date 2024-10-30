import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MaterialTable extends StatefulWidget {
  final String pie;

  MaterialTable({Key? key, required this.pie}) : super(key: key);

  @override
  State<MaterialTable> createState() => _MaterialTableState();
}

class _MaterialTableState extends State<MaterialTable> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

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
                    Text(
                      widget.pie,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'SF',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 109, 109, 109)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
                SizedBox(height: 20),
                if(widget.pie == 'Classic Apple Pie')
                PieSalesTable(),
                if(widget.pie == "Caramel 'O' Pecan")
                PieSalesTable2(),
                if(widget.pie == "Johnny Blueberry")
                PieSalesTable3(),
                     if(widget.pie == "Lady Pineapple")
                PieSalesTable4(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PieSalesTable extends StatefulWidget {
  @override
  _PieSalesTableState createState() => _PieSalesTableState();
}

class _PieSalesTableState extends State<PieSalesTable> {
  final TextEditingController smallAppleController = TextEditingController();
  final TextEditingController regularAppleController = TextEditingController();
  final TextEditingController largeAppleController = TextEditingController();
  final TextEditingController smallSauceController = TextEditingController();
  final TextEditingController regularSauceController = TextEditingController();
  final TextEditingController largeSauceController = TextEditingController();
  final TextEditingController smallCinnamonController = TextEditingController();
  final TextEditingController regularCinnamonController = TextEditingController();
  final TextEditingController largeCinnamonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Assuming you have a 'materials' collection in your Firestore
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
          .collection("companies")
          .doc("010").collection("materials")
          .get();

       if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs;

        setState(() {
          smallAppleController.text = data[2]['apple']['small'].toString();
          regularAppleController.text = data[2]['apple']['regular'].toString();
          largeAppleController.text = data[2]['apple']['large'].toString();
          smallSauceController.text = data[2]['sauce'].toString();
          regularSauceController.text = "-";
          largeSauceController.text = "-";
          smallCinnamonController.text = data[2]['cinnamon']['small'].toString();
          regularCinnamonController.text = data[2]['cinnamon']['regular'].toString();
          largeCinnamonController.text = data[2]['cinnamon']['large'].toString();
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10.0,
        columns: [
          DataColumn(label: Text('Material')),
          DataColumn(label: Text('Small')),
          DataColumn(label: Text('Regular')),
          DataColumn(label: Text('Large')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Apple')),
            DataCell(TextField(
              controller: smallAppleController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularAppleController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeAppleController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Sauce')),
            DataCell(TextField(
              controller: smallSauceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularSauceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeSauceController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Cinnamon (std)')),
            DataCell(TextField(
              controller: smallCinnamonController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularCinnamonController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeCinnamonController,
              decoration: InputDecoration(),
            )),
          ]),
        ],
      ),
    );
  }
}
class PieSalesTable2 extends StatefulWidget {
  @override
  _PieSalesTable2State createState() => _PieSalesTable2State();
}

class _PieSalesTable2State extends State<PieSalesTable2> {
  final TextEditingController smallPecanController = TextEditingController();
  final TextEditingController regularPecanController = TextEditingController();
  final TextEditingController largePecanController = TextEditingController();
  final TextEditingController smallCaramelController = TextEditingController();
  final TextEditingController regularCaramelController = TextEditingController();
  final TextEditingController largeCaramelController = TextEditingController();
  final TextEditingController smallAlmondController = TextEditingController();
  final TextEditingController regularAlmondController = TextEditingController();
  final TextEditingController largeAlmondController = TextEditingController();
  final TextEditingController smallSpiceController = TextEditingController();
  final TextEditingController regularSpiceController = TextEditingController();
  final TextEditingController largeSpiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch data for pecan_caramel pie from Firestore
       final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
          .collection("companies")
          .doc("010").collection("materials")
          .get();

         if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs;
        setState(() {
          smallPecanController.text = data[3]['pecan']['small'].toString();
          regularPecanController.text = data[3]['pecan']['regular'].toString();
          largePecanController.text = data[3]['pecan']['large'].toString();
          smallCaramelController.text = data[3]['caramel']['small'].toString();
          regularCaramelController.text = data[3]['caramel']['regular'].toString();
          largeCaramelController.text = data[3]['caramel']['large'].toString();
          smallAlmondController.text = data[3]['almond']['small'].toString();
          regularAlmondController.text = data[3]['almond']['regular'].toString();
          largeAlmondController.text = data[3]['almond']['large'].toString();
          smallSpiceController.text = data[3]['spice']['small'].toString();
          regularSpiceController.text = data[3]['spice']['regular'].toString();
          largeSpiceController.text = data[3]['spice']['large'].toString();
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10.0,
        columns: [
          DataColumn(label: Text('Material')),
          DataColumn(label: Text('Small')),
          DataColumn(label: Text('Regular')),
          DataColumn(label: Text('Large')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Pecan')),
            DataCell(TextField(
              controller: smallPecanController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularPecanController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largePecanController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Caramel')),
            DataCell(TextField(
              controller: smallCaramelController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularCaramelController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeCaramelController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Almond')),
            DataCell(TextField(
              controller: smallAlmondController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularAlmondController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeAlmondController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Spice')),
            DataCell(TextField(
              controller: smallSpiceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularSpiceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeSpiceController,
              decoration: InputDecoration(),
            )),
          ]),
        ],
      ),
    );
  }
}
class PieSalesTable3 extends StatefulWidget {
  @override
  _PieSalesTable3State createState() => _PieSalesTable3State();
}

class _PieSalesTable3State extends State<PieSalesTable3> {
  final TextEditingController smallBlueberryController = TextEditingController();
  final TextEditingController regularBlueberryController = TextEditingController();
  final TextEditingController largeBlueberryController = TextEditingController();
  final TextEditingController smallCoController = TextEditingController();
  final TextEditingController regularCoController = TextEditingController();
  final TextEditingController largeCoController = TextEditingController();
  final TextEditingController smallSauceController = TextEditingController();
  final TextEditingController regularSauceController = TextEditingController();
  final TextEditingController largeSauceController = TextEditingController();
  final TextEditingController smallTopCrustController = TextEditingController();
  final TextEditingController regularTopCrustController = TextEditingController();
  final TextEditingController largeTopCrustController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch data for blueberry pie from Firestore
       final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
          .collection("companies")
          .doc("010").collection("materials")
          .get();


       if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs;
        setState(() {
          smallBlueberryController.text = data[1]['blueberry']['small'].toString();
          regularBlueberryController.text = data[1]['blueberry']['regular'].toString();
          largeBlueberryController.text = data[1]['blueberry']['large'].toString();
          smallCoController.text = data[1]['co']['small'].toString();
          regularCoController.text = data[1]['co']['regular'].toString();
          largeCoController.text = data[1]['co']['large'].toString();
          smallSauceController.text = data[1]['sauce']['small'].toString();
          regularSauceController.text = data[1]['sauce']['regular'].toString();
          largeSauceController.text = data[1]['sauce']['large'].toString();
          smallTopCrustController.text = data[1]['top_crust']['small'].toString();
          regularTopCrustController.text = data[1]['top_crust']['regular'].toString();
          largeTopCrustController.text = data[1]['top_crust']['large'].toString();
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10.0,
        columns: [
          DataColumn(label: Text('Material')),
          DataColumn(label: Text('Small')),
          DataColumn(label: Text('Regular')),
          DataColumn(label: Text('Large')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Blueberry')),
            DataCell(TextField(
              controller: smallBlueberryController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularBlueberryController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeBlueberryController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Co')),
            DataCell(TextField(
              controller: smallCoController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularCoController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeCoController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Sauce')),
            DataCell(TextField(
              controller: smallSauceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularSauceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeSauceController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Top Crust')),
            DataCell(TextField(
              controller: smallTopCrustController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularTopCrustController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeTopCrustController,
              decoration: InputDecoration(),
            )),
          ]),
        ],
      ),
    );
  }
}
class PieSalesTable4 extends StatefulWidget {
  @override
  _PieSalesTable4State createState() => _PieSalesTable4State();
}

class _PieSalesTable4State extends State<PieSalesTable4> {
  final TextEditingController smallPineappleController = TextEditingController();
  final TextEditingController regularPineappleController = TextEditingController();
  final TextEditingController largePineappleController = TextEditingController();
  final TextEditingController smallSauceController = TextEditingController();
  final TextEditingController regularSauceController = TextEditingController();
  final TextEditingController largeSauceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Assuming you have a 'materials' collection in your Firestore
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
          .collection("companies")
          .doc("010").collection("materials")
          .get();

       if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs;

        setState(() {
          smallPineappleController.text = data[0]['pineapple']['small'].toString();
          regularPineappleController.text = data[0]['pineapple']['regular'].toString();
          largePineappleController.text = data[0]['pineapple']['large'].toString();
          smallSauceController.text = data[0]['sauce']['small'].toString();
          regularSauceController.text =  data[0]['sauce']['regular'].toString();
          largeSauceController.text =  data[0]['sauce']['large'].toString();

        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10.0,
        columns: [
          DataColumn(label: Text('Material')),
          DataColumn(label: Text('Small')),
          DataColumn(label: Text('Regular')),
          DataColumn(label: Text('Large')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Pineapple')),
            DataCell(TextField(
              controller: smallPineappleController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularPineappleController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largePineappleController,
              decoration: InputDecoration(),
            )),
          ]),
          DataRow(cells: [
            DataCell(Text('Sauce')),
            DataCell(TextField(
              controller: smallSauceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: regularSauceController,
              decoration: InputDecoration(),
            )),
            DataCell(TextField(
              controller: largeSauceController,
              decoration: InputDecoration(),
            )),
          ]),
       
        ],
      ),
    );
  }
}