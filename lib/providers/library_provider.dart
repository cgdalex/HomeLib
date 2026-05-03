import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book.dart';

class LibraryProvider extends ChangeNotifier {
  List<Book> _savedBooks = [];
  List<Book> _wishlist = [];

  List<Book> get savedBooks => _savedBooks;
  List<Book> get wishlist => _wishlist;

  LibraryProvider() {
    loadLibrary();
  }

  // --- COLLECTION METHODS ---

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
    int index = _savedBooks.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _savedBooks[index] = _savedBooks[index].copyWith(status: newStatus);
      notifyListeners();
      await _saveToDisk();
    }
  }

  // --- WISHLIST METHODS ---

  Future<void> addToWishlist(Book book) async {
  // 1. Check if it's already in the wishlist
  bool alreadyInWishlist = _wishlist.any((b) => b.id == book.id);
  
  // 2. EXTRA UX CHECK: If it's already in the Library, maybe they don't need it in Wishlist?
  bool alreadyInLibrary = _savedBooks.any((b) => b.id == book.id);

  if (alreadyInWishlist || alreadyInLibrary) {
    debugPrint("Duplicate prevented: ${book.title} already exists in a list.");
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
    // 1. Remove from wishlist
    _wishlist.removeWhere((item) => item.id == book.id);
    // 2. Add to library if not already there
    if (!_savedBooks.any((b) => b.id == book.id)) {
      _savedBooks.add(book);
    }
    notifyListeners();
    await _saveToDisk();
  }

  // --- PERSISTENCE (Saving & Loading) ---

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save both lists separately
    List<String> libraryList = _savedBooks.map((b) => jsonEncode(b.toJson())).toList();
    List<String> wishlistList = _wishlist.map((b) => jsonEncode(b.toJson())).toList();
    
    await prefs.setStringList('user_library', libraryList);
    await prefs.setStringList('user_wishlist', wishlistList);
  }

  Future<void> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String>? libraryData = prefs.getStringList('user_library');
    List<String>? wishlistData = prefs.getStringList('user_wishlist');

    if (libraryData != null) {
      _savedBooks = libraryData.map((item) => Book.fromJson(jsonDecode(item))).toList();
    }
    
    if (wishlistData != null) {
      _wishlist = wishlistData.map((item) => Book.fromJson(jsonDecode(item))).toList();
    }
    
    notifyListeners();
  }
}