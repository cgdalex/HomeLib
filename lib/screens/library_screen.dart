import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the provider
    final library = Provider.of<LibraryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("My HomeLib")),
      body: library.savedBooks.isEmpty
          ? Center(child: Text("Your library is empty. Go find some books!"))
          : ListView.builder(
              itemCount: library.savedBooks.length,
              itemBuilder: (context, index) {
                final book = library.savedBooks[index];
                return ListTile(
                  leading: Image.network(book.thumbnailUrl),
                  title: Text(book.title),
                  subtitle: Text(book.authors),
                );
              },
            ),
    );
  }
}