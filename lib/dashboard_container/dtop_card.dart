// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final double balance;
  final Image logo;
  final String text;
  final LinearGradient gradient;

  const MyCard({
    super.key,
    required this.balance,
    required this.logo,
    required this.text,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 160,
      // padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: gradient,
      ),

      child: Column(
        children: [
          Center(
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            child: logo,
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.only(left: 10),
                width: 130,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.white24,
                    Colors.white30,
                  ]),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        balance.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.green,
                      ),
                      Text('Up')
                    ]),
              )
            ],
          )
        ],
      ),
    );
  }
}
