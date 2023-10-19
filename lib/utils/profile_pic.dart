import 'package:flutter/material.dart';

class UserProfileProvider with ChangeNotifier {
  String _imageUrl = '';
  String _localImageUrl = ''; // Add this variable for the local image URL

  // Getter for the image URL
  String get imageUrl => _imageUrl;

  // Getter for the local image URL
  String get localImageUrl => _localImageUrl;

  // Setter for the image URL
  void setImageUrl(String url) {
    _imageUrl = url;
    notifyListeners();
  }

  // Setter for the local image URL
  void setLocalImageUrl(String localUrl) {
    _localImageUrl = localUrl;
    notifyListeners();
  }
}
