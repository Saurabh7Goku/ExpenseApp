import 'package:eazyexpense/utils/category_data.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:eazyexpense/utils/user.dart';

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<User> userList = [];
  String selectedData = 'All'; // Default selection
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now(); // Default end date

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      Query query = FirebaseFirestore.instance.collection('user');

      query = query
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true);

      if (selectedData != 'All') {
        // Replace 'yourFieldNameHere' with the actual field name in Firestore
        query = query.where('dataSelectorField', isEqualTo: selectedData);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        userList = querySnapshot.docs
            .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      } else {
        // Handle the case when there is no data
        print('No data available.');
      }

      setState(() {});
    } catch (error) {
      // Handle the error
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Details Page',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            iconSize: 40,
            color: Colors.blue,
            icon: Icon(Icons.calendar_month_rounded),
            onPressed: () {
              _showDatePicker();
            },
          ),
          Expanded(
            child: userList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text('Name',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900))),
                        DataColumn(
                            label: Text('Income',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900))),
                        DataColumn(
                            label: Text('Expense',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900))),
                        DataColumn(
                            label: Text('Type',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900))),
                      ],
                      rows: userList.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user.name)),
                            DataCell(Text(user.totalIncome.toStringAsFixed(1))),
                            DataCell(
                                Text(user.totalExpense.toStringAsFixed(1))),
                            DataCell(Text(user.isCash ? 'Cash' : 'Online')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ModifiedDetailsPage(userList: userList),
                  ),
                );
              },
              child: Text('Show Modified Data'),
            ),
          )
        ],
      ),
    );
  }

  // Function to show the date picker
  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Date'),
          icon: Icon(Icons.calendar_month),
          content: SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(startDate, endDate),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value != null &&
                    args.value.startDate != null &&
                    args.value.endDate != null) {
                  setState(() {
                    startDate = args.value.startDate!;
                    endDate = args.value.endDate!;
                  });
                  fetchData(); // Fetch data when the date range changes
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// class User {
//   final String id;
//   final String name;
//   final double amount;
//   final DateTime date;
//   final bool isIncome;
//   final String item;
//   final bool isCash;

//   User({
//     required this.id,
//     required this.name,
//     required this.amount,
//     required this.date,
//     required this.isIncome,
//     required this.item,
//     required this.isCash,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       amount: json['amount'].toDouble(),
//       date: (json['date'] as Timestamp).toDate(),
//       isIncome: json['isIncome'],
//       item: json['item'],
//       isCash: json['isCash'],
//     );
//   }

//   double get totalAmount => amount;
//   double get totalExpense => isIncome ? 0 : amount;
//   double get totalIncome => isIncome ? amount : 0;
// }
