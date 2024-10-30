import 'package:flutter/material.dart';

class AppointmentDetail extends StatefulWidget {
  String? pie;
  int? small;
  int? regular;
  int? large;

  AppointmentDetail({Key? key, this.pie, this.small, this.regular, this.large})
      : super(key: key);

  @override
  State<AppointmentDetail> createState() => _AppointmentDetailState();
}

class _AppointmentDetailState extends State<AppointmentDetail> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
          ),
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
                      widget.pie!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 109, 109, 109),
                      ),
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
                Text(
                  'Pending',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 31, 31, 31),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Small: ${widget.small}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 109, 109, 109),
                      ),
                    ),
                    Text(
                      'Regular: ${widget.regular}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 109, 109, 109),
                      ),
                    ),
                    Text(
                      'Large: ${widget.large}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 109, 109, 109),
                      ),
                    ),
                  ],
                ),
                Divider(),
                PieSalesTable(
                  small: widget.small!,
                  regular: widget.regular!,
                  large: widget.large!,
                  onSmallChanged: (value) {
                    if (value > 0) {
                      setState(() {
                        widget.small = value;
                      });
                    }
                  },
                  onRegularChanged: (value) {
                    if (widget.regular! > 0) {
                      setState(() {
                        widget.regular = value;
                      });
                    }
                  },
                  onLargeChanged: (value) {
                    if (value > 0) {
                      setState(() {
                        widget.large = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PieSalesTable extends StatelessWidget {
  final int small;
  final int regular;
  final int large;
  final ValueChanged<int> onSmallChanged;
  final ValueChanged<int> onRegularChanged;
  final ValueChanged<int> onLargeChanged;

  PieSalesTable({
    required this.small,
    required this.regular,
    required this.large,
    required this.onSmallChanged,
    required this.onRegularChanged,
    required this.onLargeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 30.0,
        columns: [
          DataColumn(label: Text('Priorities')),
          DataColumn(label: Text('Small')),
          DataColumn(label: Text('Regular')),
          DataColumn(label: Text('Large')),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('1st')),
            DataCell(
              TextField(
                onChanged: (value) => onSmallChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onRegularChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onLargeChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
          ]),
            DataRow(cells: [
            DataCell(Text('2nd')),
            DataCell(
              TextField(
                onChanged: (value) => onSmallChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onRegularChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onLargeChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
          ]),
            DataRow(cells: [
            DataCell(Text('3rd')),
            DataCell(
              TextField(
                onChanged: (value) => onSmallChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onRegularChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onLargeChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
          ]),
            DataRow(cells: [
            DataCell(Text('4th')),
            DataCell(
              TextField(
                onChanged: (value) => onSmallChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onRegularChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onLargeChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
          ]),
            DataRow(cells: [
            DataCell(Text('5th')),
            DataCell(
              TextField(
                onChanged: (value) => onSmallChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onRegularChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onLargeChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
          ]),
            DataRow(cells: [
            DataCell(Text('6th')),
            DataCell(
              TextField(
                onChanged: (value) => onSmallChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onRegularChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
            DataCell(
              TextField(
                onChanged: (value) => onLargeChanged(int.tryParse(value) ?? 0),
                decoration: InputDecoration(),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
