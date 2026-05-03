import 'package:flutter/material.dart';
import '../models/book.dart';

// This provider stores books that the user adds from the search screen.
// It is separate from library_provider.dart so we do not overwrite
// or interfere with the file your teammate is already working on.
class BookCollectionProvider extends ChangeNotifier {
  // Private list of books added by the user.
  // The underscore means only this file can directly edit the list.
  final List<Book> _addedBooks = [];

  // Public getter that other screens can use to read the added books.
  // List.unmodifiable prevents other files from accidentally changing
  // the list directly.
  List<Book> get addedBooks => List.unmodifiable(_addedBooks);

  // Adds a book to the user's added book list.
  void addBook(Book book) {
    // Prevents duplicate books from being added.
    final alreadyAdded = _addedBooks.any((addedBook) => addedBook.id == book.id);

    if (alreadyAdded) {
      return;
    }

    _addedBooks.add(book);

    // Tells any screen using this provider to update.
    notifyListeners();
  }

  // Removes a book from the added book list.
  void removeBook(Book book) {
    _addedBooks.removeWhere((addedBook) => addedBook.id == book.id);

    // Tells any screen using this provider to update.
    notifyListeners();
  }

  // Checks whether a book has already been added.
  bool isBookAdded(Book book) {
    return _addedBooks.any((addedBook) => addedBook.id == book.id);
  }

  // Clears all added books.
  // This is mainly useful for testing.
  void clearBooks() {
    _addedBooks.clear();
    notifyListeners();
  }
}