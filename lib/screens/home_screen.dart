import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Book> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _searchBooks() async {
    if (_searchController.text.trim().length < 2) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await fetchBooks(_searchController.text);

      setState(() {
        _books = results;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to search books: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeLIB'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search for a book',
                      hintText: 'Example: The Hobbit',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchBooks(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchBooks,
                  child: Text(_isLoading ? 'Loading...' : 'Search'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];

                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.authors),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}