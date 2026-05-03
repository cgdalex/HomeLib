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
        _errorMessage = 'Failed to search books. Try again.';
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
      body: Padding(
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
              onPressed: _searchBooks,
              child: Text(_isLoading ? 'Loading...' : 'Search'),
            ),
          ],
        ),
      ),
    );
  }
}