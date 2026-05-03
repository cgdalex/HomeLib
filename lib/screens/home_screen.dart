import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _searchBooks() {
    print('Searching for: ${_searchController.text}');
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
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}