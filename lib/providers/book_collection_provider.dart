import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

// This provider stores books added from the search screen.
// It is separate from library_provider.dart so we do not interfere
// with your buddy's work.
class BookCollectionProvider extends ChangeNotifier {
  // Storage key used by shared_preferences.
  static const String _storageKey = 'added_books';

  // Private list of books added by the user.
  final List<Book> _addedBooks = [];

  // Public getter that other screens can use to read the added books.
  List<Book> get addedBooks => List.unmodifiable(_addedBooks);

  // Constructor runs when the provider starts.
  // It loads saved books from browser/local storage.
  BookCollectionProvider() {
    loadBooks();
  }

  // Adds a book to the user's added book list.
  // Returns true if the book was added.
  // Returns false if the book was already added.
  Future<bool> addBook(Book book) async {
    // Prevent duplicate books.
    final alreadyAdded = _addedBooks.any((addedBook) => addedBook.id == book.id);

    if (alreadyAdded) {
      return false;
    }

    _addedBooks.add(book);

    // Updates screens using this provider.
    notifyListeners();

    // Saves the updated list locally.
    await _saveBooks();

    return true;
  }

  // Removes a book from the added book list.
  Future<void> removeBook(Book book) async {
    _addedBooks.removeWhere((addedBook) => addedBook.id == book.id);

    notifyListeners();

    await _saveBooks();
  }

  // Checks whether a book has already been added.
  bool isBookAdded(Book book) {
    return _addedBooks.any((addedBook) => addedBook.id == book.id);
  }

  // Saves the added books to shared_preferences.
  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();

    final bookStrings = _addedBooks.map((book) {
      return jsonEncode(book.toJson());
    }).toList();

    await prefs.setStringList(_storageKey, bookStrings);
  }

  // Loads books from shared_preferences.
  Future<void> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();

    final bookStrings = prefs.getStringList(_storageKey);

    if (bookStrings == null) {
      return;
    }

    _addedBooks.clear();

    for (final bookString in bookStrings) {
      final decodedBook = jsonDecode(bookString);
      _addedBooks.add(Book.fromJson(decodedBook));
    }

    notifyListeners();
  }

  // Clears all books.
  // Useful for testing.
  Future<void> clearBooks() async {
    _addedBooks.clear();

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}