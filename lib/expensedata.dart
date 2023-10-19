// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:eazyexpense/charts/expense_chart.dart';
import 'package:eazyexpense/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eazyexpense/history.dart';
import 'package:eazyexpense/top_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:eazyexpense/utils/user.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _formKey = GlobalKey<FormState>();
  final id = '';
  double income = 0;
  double expense = 0;
  double totalAmount = 0;
  double cashAmount = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isIncome = false;
  bool isCash = true;

  final controller = TextEditingController();
  final textcontrollerAMOUNT = TextEditingController();
  final textcontrollerITEM = TextEditingController();
  final textcontrollerNAME = TextEditingController();

  int _selectedIndex = 0;

  final List<IconData> _bottomNavBarIcons = [
    Icons.home,
    Icons.history,
    Icons.add,
    CupertinoIcons.graph_square_fill,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    fetchInitialTotals();
  }

  Future<void> fetchInitialTotals() async {
    final totalsDoc = await FirebaseFirestore.instance
        .collection('totals')
        .doc('totalsDocument')
        .get();

    if (totalsDoc.exists) {
      setState(() {
        totalAmount = (totalsDoc.data() as dynamic)['totalBalance'] ?? 0.0;
        income = (totalsDoc.data() as dynamic)['totalIncome'] ?? 0.0;
        expense = (totalsDoc.data() as dynamic)['totalExpense'] ?? 0.0;
        cashAmount = (totalsDoc.data() as dynamic)['cashAmount'] ?? 0.0;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _onBottomNavBarItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DashBoard(),
          ),
        );
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailsPage(),
          ),
        );
        break;
      case 2:
        _newTransaction();
        break;

      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LineChartScreen(),
          ),
        );
        break;

      case 4:
        // _showImagePickerBottomSheet();
        break;
    }
  }

  void _showProfileSwitchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Background blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black
                    .withOpacity(0), // Adjust opacity for the blur effect
              ),
            ),
            // Dialog content
            AlertDialog(
              title: Center(
                child: Text(
                  'Profile Switch',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Text('Go to Dashboard to change Profile switch'),
              actions: <Widget>[
                TextButton(
                  child: Center(
                      child: Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _newTransaction() async {
    _selectedDate = DateTime.now();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text(
                  'NEW  T R A N S A C T I O N',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text('Online'),
                                  Switch(
                                    activeColor: Colors.green,
                                    value: isCash,
                                    onChanged: (newValue) {
                                      setState(() {
                                        isCash = newValue;
                                      });
                                    },
                                  ),
                                  Text('Cash'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Expense'),
                                  Switch(
                                    activeColor: Colors.green,
                                    value: _isIncome,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _isIncome = newValue;
                                      });
                                    },
                                  ),
                                  Text('Income'),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Amount?',
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Enter an amount';
                                  }
                                  return null;
                                },
                                controller: textcontrollerAMOUNT,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'For what?',
                              ),
                              controller: textcontrollerITEM,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Name',
                              ),
                              controller: textcontrollerNAME,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 8.0),
                            Text(
                              DateFormat('dd-MM-yyyy').format(_selectedDate),
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.grey[600],
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    color: Colors.grey[600],
                    child: Text('Enter', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      final user = User(
                        id: id,
                        name: textcontrollerNAME.text,
                        amount: double.parse(textcontrollerAMOUNT.text),
                        date: _selectedDate,
                        isIncome: _isIncome,
                        item: textcontrollerITEM.text,
                        isCash: isCash,
                      );

                      if (isCash == false) {
                        if (user.isIncome == true) {
                          totalAmount += user.amount;
                          income += user.amount;
                        } else {
                          totalAmount -= user.amount;
                          expense += user.amount;
                        }
                      } else {
                        if (user.isIncome == true) {
                          cashAmount += user.amount;
                          income += user.amount;
                        } else {
                          cashAmount -= user.amount;
                          expense += user.amount;
                        }
                      }

                      await createUser(user);
                      await updateFirestoreTotals();

                      _updateTopCard(
                        updatedTotalAmount: totalAmount,
                        updatedIncome: income,
                        updatedExpense: expense,
                        updatedCashAmount: cashAmount,
                      );
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        });
  }

  Future<void> updateFirestoreTotals() async {
    final totalsDocRef =
        FirebaseFirestore.instance.collection('totals').doc('totalsDocument');
    final currentTotals = await totalsDocRef.get();

    if (currentTotals.exists) {
      final currentData = currentTotals.data() as dynamic;
      final newBalance = totalAmount;
      final newIncome = income;
      final newExpense = expense;

      await totalsDocRef.set({
        'totalBalance': newBalance,
        'totalIncome': newIncome,
        'totalExpense': newExpense,
        'cashAmount': cashAmount,
      });
    }
  }

  void _updateTopCard({
    required double updatedTotalAmount,
    required double updatedIncome,
    required double updatedExpense,
    required double updatedCashAmount,
  }) {
    setState(() {
      totalAmount = updatedTotalAmount;
      income = updatedIncome;
      expense = updatedExpense;
      cashAmount = updatedCashAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.035,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TopCard(
                    balance: totalAmount.toStringAsFixed(2),
                    expense: expense.toStringAsFixed(2),
                    income: income.toStringAsFixed(2),
                    cash: cashAmount.toStringAsFixed(2),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                    ),
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: StreamBuilder(
                      stream: readUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                              'Something went wrong! ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return ListView.builder(
                            itemCount: data.length + 1,
                            itemBuilder: (context, index) {
                              if (index == data.length) {
                                return SizedBox(height: 100);
                              }
                              return buildUser(data[index]);
                            },
                          );
                        } else {
                          return Center(
                            child: LinearProgressIndicator(minHeight: 6),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BottomNavigationBar(
                    items: List.generate(
                      _bottomNavBarIcons.length,
                      (index) => BottomNavigationBarItem(
                        backgroundColor: Colors.blue,
                        icon: Icon(_bottomNavBarIcons[index]),
                        label: '',
                        activeIcon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Icon(
                              _bottomNavBarIcons[index],
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    currentIndex: _selectedIndex,
                    onTap: _onBottomNavBarItemTapped,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    unselectedItemColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUser(User user) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(user.date);
    final formattedTime = DateFormat('HH:mm:ss').format(user.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 3),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
                spreadRadius: 0.5,
              ),
              BoxShadow(
                color: Colors.blue.shade900,
                offset: Offset(-1.0, -1.0),
                blurRadius: 2.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'Date: $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Time: $formattedTime',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Center(
                          child: Icon(
                            Icons.currency_rupee_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        '${user.item}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${user.name}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  user.isCash
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/cash.png',
                              height: 30,
                              width: 40,
                            ),
                            Text(
                              (user.isIncome == false ? '- ' : '+ ') +
                                  '₹ ' +
                                  '${user.amount}',
                              style: TextStyle(
                                fontSize: 16,
                                color: user.isIncome == false
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/cards.png',
                              height: 30,
                              width: 40,
                            ),
                            Text(
                              (user.isIncome == false ? '- ' : '+ ') +
                                  '₹ ' +
                                  '${user.amount}',
                              style: TextStyle(
                                fontSize: 16,
                                color: user.isIncome == false
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
          .collection('user')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        final data =
            snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
        return data;
      });

  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('user').doc();
    user.id = docUser.id;
    final json = user.toJson();
    await docUser.set(json);
  }

  Future<void> _pickAndUploadImage() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // final androidInfo = await DeviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final storagePermission = await Permission.storage.request();
        if (storagePermission.isGranted) {
          print('permission granted');
          _handleImageSelection();
        } else {
          print('permission Denied');
        }
      } else {
        final photosPermission = await Permission.photos.request();
        if (photosPermission.isGranted) {
          print('permission photo granted');
          _handleImageSelection();
        } else {
          print('permission photo Denied');
        }
      }
    } else {}
  }

  void _handleImageSelection() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      String imageName = Path.basename(image.path);

      Reference storageReference =
          FirebaseStorage.instance.ref().child(imageName);

      UploadTask uploadTask = storageReference.putFile(image);

      await uploadTask.whenComplete(() {
        // Image uploaded successfully
        print('Image uploaded.');

        // You can also get the download URL of the uploaded image
        storageReference.getDownloadURL().then((downloadURL) {
          print('Download URL: $downloadURL');

          // TODO: Store the downloadURL in Firestore or wherever you need it.
        });
      });
    } else {
      // No image selected.
    }
  }
}

// class User {
//   String id;
//   final String name;
//   final double amount;
//   final DateTime date;
//   final bool isIncome;
//   final String item;
//   final bool isCash;

//   User({
//     this.id = '',
//     required this.name,
//     required this.amount,
//     required this.date,
//     required this.isIncome,
//     required this.item,
//     required this.isCash,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'amount': amount,
//       'date': date,
//       'isIncome': isIncome,
//       'item': item,
//       'isCash': isCash,
//     };
//   }

//   static User fromJson(Map<String, dynamic> json) => User(
//         name: json['name'],
//         amount: json['amount'],
//         date: (json['date'] as Timestamp).toDate(),
//         isIncome: json['isIncome'],
//         item: json['item'],
//         isCash: json['isCash'],
//       );
// }
