// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PlusButton extends StatelessWidget {
  final function;

  PlusButton({this.function});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        height: 40,
        width: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          shape: BoxShape.rectangle,
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: Center(
            child: Text(
              'Add Exp',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
