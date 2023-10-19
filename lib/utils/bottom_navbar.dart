import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
              ),
            ],
            currentIndex: currentIndex,
            onTap: (index) {
              // Handle different cases based on the selected index
              switch (index) {
                case 0:
                  // Handle navigation for the first tab
                  break;
                case 1:
                  // Handle navigation for the second tab
                  break;
                case 2:
                  // Handle navigation for the third tab
                  break;
                case 3:
                  // Handle navigation for the fourth tab
                  break;
                default:
                  // Handle any other case
                  break;
              }

              // Call the provided onTap callback
              onTap(index);
            },
            showSelectedLabels: true,
            showUnselectedLabels: false,
            unselectedItemColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
