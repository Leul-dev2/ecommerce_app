import 'package:flutter/material.dart';

class AppLanguage {
  final String code;
  final String name;

  const AppLanguage({required this.code, required this.name});
}

class LanguageProvider extends ChangeNotifier {
  final List<AppLanguage> _languages = [
    AppLanguage(code: 'en', name: 'English'),
    AppLanguage(code: 'am', name: 'አማርኛ'),
  ];

  List<AppLanguage> get languages => _languages;

  AppLanguage? selectedLanguage;

  bool isLoading = false;
  String? error;

  void init() {
    // Simulate loading delay
    isLoading = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      isLoading = false;
      notifyListeners();
    });
  }

  void selectLanguage(AppLanguage lang) {
    selectedLanguage = lang;
    notifyListeners();
  }
}
