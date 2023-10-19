import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  final String name;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String item;
  final bool isCash;

  User({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.item,
    required this.isCash,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      date: (json['date'] as Timestamp).toDate(),
      isIncome: json['isIncome'],
      item: json['item'],
      isCash: json['isCash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date,
      'isIncome': isIncome,
      'item': item,
      'isCash': isCash,
    };
  }

  double get totalAmount => amount;
  double get totalExpense => isIncome ? 0 : amount;
  double get totalIncome => isIncome ? amount : 0;
}
