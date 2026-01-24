import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  bool _isFrench = true;
  bool get isFrench => _isFrench;
  String get currentLang => _isFrench ? 'FR' : 'EN';
  void toggleLanguage() {
    _isFrench = !_isFrench;
    notifyListeners();
  }
  String t(String fr, String en) {
    return _isFrench ? fr : en;
  }
}