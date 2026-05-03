import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class LibraryProvider extends ChangeNotifier {
  List<Book> _savedBooks = [];

  List<Book> get savedBooks => _savedBooks;

  LibraryProvider() {
    loadLibrary(); // Load books as soon as the app starts
  }

  // Task #2: Add to Library
  Future<void> addBook(Book book) async {
    // Task #7: Duplicate Check
    if (_savedBooks.any((b) => b.id == book.id)) return;

    _savedBooks.add(book);
    notifyListeners(); // This tells all screens to rebuild!
    await _saveToDisk();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = _savedBooks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList('user_library', list);
  }

  Future<void> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('user_library');
    if (list != null) {
      _savedBooks = list.map((item) => Book.fromJson(jsonDecode(item))).toList();
      notifyListeners();
    }
  }
}