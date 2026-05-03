import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

class LibraryProvider extends ChangeNotifier {
  List<Book> _savedBooks = [];
  List<Book> _wishlist = [];

  List<Book> get savedBooks => _savedBooks;
  List<Book> get wishlist => _wishlist;

  LibraryProvider() {
    loadLibrary();
  }

  // -----------------------------
  // COLLECTION METHODS
  // -----------------------------

  Future<void> addBook(Book book) async {
    if (_savedBooks.any((b) => b.id == book.id)) {
      return;
    }

    _savedBooks.add(book);
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> removeBook(Book book) async {
    _savedBooks.removeWhere((item) => item.id == book.id);
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> updateBookStatus(Book book, String newStatus) async {
    final index = _savedBooks.indexWhere((b) => b.id == book.id);

    if (index != -1) {
      _savedBooks[index] = _savedBooks[index].copyWith(status: newStatus);
      notifyListeners();
      await _saveToDisk();
    }
  }

  // Updates whether the user owns the book physically or digitally.
  Future<void> updateBookOwnershipType(
    Book book,
    String newOwnershipType,
  ) async {
    final index = _savedBooks.indexWhere((b) => b.id == book.id);

    if (index != -1) {
      _savedBooks[index] = _savedBooks[index].copyWith(
        ownershipType: newOwnershipType,
      );

      notifyListeners();
      await _saveToDisk();
    }
  }

  // Updates the user's personal rating and notes.
  // This checks both the main library and the wishlist because the user
  // may save notes for a book in either place.
  Future<void> updateBookPersonalDetails(
    Book book,
    double personalRating,
    String notes,
  ) async {
    final libraryIndex = _savedBooks.indexWhere((b) => b.id == book.id);

    if (libraryIndex != -1) {
      _savedBooks[libraryIndex] = _savedBooks[libraryIndex].copyWith(
        personalRating: personalRating,
        notes: notes,
      );
    }

    final wishlistIndex = _wishlist.indexWhere((b) => b.id == book.id);

    if (wishlistIndex != -1) {
      _wishlist[wishlistIndex] = _wishlist[wishlistIndex].copyWith(
        personalRating: personalRating,
        notes: notes,
      );
    }

    notifyListeners();
    await _saveToDisk();
  }

  // Finds the saved version of a book if it already exists.
  // This is useful because the popup may be opened from search results,
  // but the saved copy may have personal notes/rating.
  Book? findSavedBook(Book book) {
    final libraryIndex = _savedBooks.indexWhere((b) => b.id == book.id);

    if (libraryIndex != -1) {
      return _savedBooks[libraryIndex];
    }

    final wishlistIndex = _wishlist.indexWhere((b) => b.id == book.id);

    if (wishlistIndex != -1) {
      return _wishlist[wishlistIndex];
    }

    return null;
  }

  // -----------------------------
  // WISHLIST METHODS
  // -----------------------------

  Future<void> addToWishlist(Book book) async {
    final alreadyInWishlist = _wishlist.any((b) => b.id == book.id);
    final alreadyInLibrary = _savedBooks.any((b) => b.id == book.id);

    if (alreadyInWishlist || alreadyInLibrary) {
      debugPrint(
        'Duplicate prevented: ${book.title} already exists in a list.',
      );
      return;
    }

    _wishlist.add(book);
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> removeFromWishlist(Book book) async {
    _wishlist.removeWhere((item) => item.id == book.id);
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> moveToLibrary(Book book) async {
    _wishlist.removeWhere((item) => item.id == book.id);

    if (!_savedBooks.any((b) => b.id == book.id)) {
      _savedBooks.add(
        book.copyWith(
          status: 'Want to Read',
          ownershipType: book.ownershipType,
        ),
      );
    }

    notifyListeners();
    await _saveToDisk();
  }

  // -----------------------------
  // PERSISTENCE
  // -----------------------------

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();

    final libraryList = _savedBooks.map((book) {
      return jsonEncode(book.toJson());
    }).toList();

    final wishlistList = _wishlist.map((book) {
      return jsonEncode(book.toJson());
    }).toList();

    await prefs.setStringList('user_library', libraryList);
    await prefs.setStringList('user_wishlist', wishlistList);
  }

  Future<void> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();

    final libraryData = prefs.getStringList('user_library');
    final wishlistData = prefs.getStringList('user_wishlist');

    if (libraryData != null) {
      _savedBooks = libraryData.map((item) {
        return Book.fromJson(jsonDecode(item));
      }).toList();
    }

    if (wishlistData != null) {
      _wishlist = wishlistData.map((item) {
        return Book.fromJson(jsonDecode(item));
      }).toList();
    }

    notifyListeners();
  }
}