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
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Search for a book',
            hintText: 'Example: The Hobbit',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}