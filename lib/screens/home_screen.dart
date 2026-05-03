import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search for a book',
                  hintText: 'Example: The Hobbit',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                print('Search button pressed');
              },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}