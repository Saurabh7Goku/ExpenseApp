// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eazyexpense/charts/expense_chart.dart';
import 'package:eazyexpense/dashboard_container/dtop_card.dart';
import 'package:eazyexpense/expensedata.dart';
import 'package:eazyexpense/history.dart';
import 'package:eazyexpense/utils/profile_pic.dart';
import 'package:eazyexpense/utils/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String imageUrl = '';
  final _formKey = GlobalKey<FormState>();
  final id = '';
  double day7income = 0;
  double day7expense = 0;
  double day7totalAmount = 0;
  double day7cashAmount = 0;

  double upIncome = 0;
  double upExpense = 0;
  double upTotalAmount = 0;
  double upCashAmount = 0;

  double totalIncome = 0;
  double totalExpense = 0;

  double income = 0;
  double expense = 0;
  double totalAmount = 0;
  double cashAmount = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isIncome = false;
  bool isCash = true;

  int _selectedIndex = 0;

  final controller = TextEditingController();
  final textcontrollerAMOUNT = TextEditingController();
  final textcontrollerITEM = TextEditingController();
  final textcontrollerNAME = TextEditingController();

  final List<IconData> _bottomNavBarIcons = [
    Icons.home,
    Icons.history,
    Icons.add,
    CupertinoIcons.chart_bar_circle,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    fetchInitialTotals();
    fetchDataForLast7Days();
    _fetchLocalImageUrl();
  }

  Future<void> _fetchLocalImageUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      imageUrl = prefs.getString('profileImage') ?? '';
    });
  }

  Future<void> fetchInitialTotals() async {
    final totalsDoc = await FirebaseFirestore.instance
        .collection('totals')
        .doc('totalsDocument')
        .get();

    if (totalsDoc.exists) {
      setState(() {
        totalAmount = (totalsDoc.data() as dynamic)['totalBalance'] ?? 0.0;
        totalIncome = (totalsDoc.data() as dynamic)['totalIncome'] ?? 0.0;
        totalExpense = (totalsDoc.data() as dynamic)['totalExpense'] ?? 0.0;
        cashAmount = (totalsDoc.data() as dynamic)['cashAmount'] ?? 0.0;
      });
    }
  }

  Future<void> fetchDataForLast7Days() async {
    final currentDate = DateTime.now();
    final last7Days = currentDate.subtract(Duration(days: 7));

    final totals7Doc = await FirebaseFirestore.instance
        .collection('totals')
        .doc('totalsDocument')
        .get();

    if (totals7Doc.exists) {
      setState(() {
        day7totalAmount = (totals7Doc.data() as dynamic)['totalBalance'] ?? 0.0;
        day7income = (totals7Doc.data() as dynamic)['totalIncome'] ?? 0.0;
        day7expense = (totals7Doc.data() as dynamic)['totalExpense'] ?? 0.0;
        day7cashAmount = (totals7Doc.data() as dynamic)['cashAmount'] ?? 0.0;
      });
    }

    final QuerySnapshot transactions = await FirebaseFirestore.instance
        .collection('user')
        .where('date', isGreaterThanOrEqualTo: last7Days)
        .where('date', isLessThanOrEqualTo: currentDate)
        .get();

    double upTotalAmount = 0.0;
    double upIncome = 0.0;
    double upExpense = 0.0;
    double upCashAmount = 0.0;

    for (var transactionDoc in transactions.docs) {
      final transactionData = transactionDoc.data() as dynamic;
      final double amount = transactionData['amount'] ?? 0.0;
      final bool isIncome = transactionData['isIncome'] ?? false;
      final bool isCash = transactionData['isCash'] ?? false;

      if (!isCash && isIncome) {
        upTotalAmount += amount;
        upIncome += amount;
      } else if (!isCash && !isIncome) {
        upTotalAmount -= amount;
        upExpense += amount;
      } else if (isCash && isIncome) {
        upCashAmount += amount;
        upIncome += amount;
      } else if (isCash && !isIncome) {
        upCashAmount -= amount;
        upExpense += amount;
      }
    }

    _updateCard(
      updatedTotalAmount: upTotalAmount,
      updatedIncome: upIncome,
      updatedExpense: upExpense,
      updatedCashAmount: upCashAmount,
    );
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

  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('user').doc();
    user.id = docUser.id;
    final json = user.toJson();
    await docUser.set(json);
  }

  void _updateCard({
    required double updatedTotalAmount,
    required double updatedIncome,
    required double updatedExpense,
    required double updatedCashAmount,
  }) {
    setState(() {
      upTotalAmount = updatedTotalAmount;
      upIncome = updatedIncome;
      upExpense = updatedExpense;
      upCashAmount = updatedCashAmount;
    });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final localImageUrl = imageUrl;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 2.8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(65),
                  topRight: Radius.circular(65),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.07,
                  vertical: screenHeight * 0.05,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Saurabh',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          'Singh',
                          style: TextStyle(fontSize: 28),
                        ),
                      ],
                    ),
                    // Fetch the image URL outside the widget

                    Container(
                      height: screenHeight * 0.09,
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue,
                          width: 3.0,
                        ),
                      ),
                      child: ClipOval(
                        child: InkWell(
                          onTap: () {
                            _handleImageSelection();
                          },
                          child: Consumer<UserProfileProvider>(
                            builder: (context, userProfileProvider, child) {
                              final localImageUrl =
                                  userProfileProvider.localImageUrl;

                              if (localImageUrl.isNotEmpty) {
                                // Display the local image if it exists
                                return Image.file(
                                  File(localImageUrl),
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.blue,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.0002,
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      'My Expenses',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${getWeekOfMonth(DateTime.now())} Week ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Container(
                height: screenHeight * 0.587,
                padding: EdgeInsets.all(16),
                width: screenWidth * 0.88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MyCard(
                          balance: double.parse(upTotalAmount.toString()),
                          text: 'online Balance',
                          logo: Image.asset('assets/cards.png'),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade200,
                              Colors.deepPurple.shade50,
                            ],
                          ),
                        ),
                        MyCard(
                          balance: double.parse(upCashAmount.toString()),
                          text: 'Cash Balance',
                          logo: Image.asset('assets/cash.png'),
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepOrange.shade200,
                              Colors.deepOrange.shade50,
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.025,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MyCard(
                          balance: double.parse(upIncome.toString()),
                          text: 'Income',
                          logo: Image.asset('assets/income.png'),
                          gradient: LinearGradient(
                            colors: [
                              Colors.pinkAccent.shade100,
                              Colors.pink.shade100,
                            ],
                          ),
                        ),
                        MyCard(
                          balance: double.parse(upExpense.toString()),
                          text: 'Expense',
                          logo: Image.asset('assets/expense.png'),
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade300,
                              Colors.teal.shade50,
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      width: screenWidth * 0.70,
                      height: screenHeight * 0.07,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade200,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Total Income',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(upIncome.toString()),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Total Expense',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(upExpense.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(
                                0, MediaQuery.of(context).size.width * 0.1),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade50,
                                    Colors.deepPurple.shade200,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          'Button Pressed'); // Add this line for debugging
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LineChartScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
            ],
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
                        backgroundColor: Colors.blue.shade400,
                        icon: Icon(_bottomNavBarIcons[index]),
                        label: '',
                        activeIcon: Container(
                          width: 40,
                          height: 30,
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

  int getWeekOfMonth(DateTime date) {
    int weekOfMonth = date.day ~/ 7 + 1;
    return weekOfMonth;
  }

  // void _showImagePickerBottomSheet() async {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Container(
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: Icon(Icons.camera),
  //               title: Text('Take a Photo'),
  //               onTap: () async {
  //                 final pickedFile = await _pickImage(ImageSource.camera);
  //                 Navigator.of(context).pop();
  //                 if (pickedFile != null) {
  //                   await _uploadAndSaveProfileImage(pickedFile);
  //                 }
  //               },
  //             ),
  //             ListTile(
  //               leading: Icon(Icons.photo_library),
  //               title: Text('Choose from Gallery'),
  //               onTap: () async {
  //                 final pickedFile = await _pickImage(ImageSource.gallery);
  //                 Navigator.of(context).pop();
  //                 if (pickedFile != null) {
  //                   await _uploadAndSaveProfileImage(pickedFile);
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _handleImageSelection() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);

      // Generate a unique filename based on the current timestamp
      String imageName =
          DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

      // Get the directory for storing the image locally
      final appDir = await getApplicationDocumentsDirectory();
      final localImagePath = '${appDir.path}/$imageName';

      // Copy the picked image to the local directory
      await image.copy(localImagePath);

      // Store the localImagePath in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('localProfileImage', localImagePath);

      // Set the imageUrl using the UserProfileProvider
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      userProfileProvider.setLocalImageUrl(localImagePath);
    } else {
      // No image selected.
    }
  }

  Future<void> _onBottomNavBarItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainPage(),
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
        _handleImageSelection();
        break;
    }
  }
}
