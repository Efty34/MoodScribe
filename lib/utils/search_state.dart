import 'package:flutter/material.dart';

class SearchState extends ChangeNotifier {
  String _query = '';
  String get query => _query;

  void updateQuery(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }

  void clearQuery() {
    _query = '';
    notifyListeners();
  }
}
