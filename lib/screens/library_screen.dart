import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "My HomeLib",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: library.savedBooks.isEmpty
              ? const Center(
                  child: Text(
                    "Your library is empty. Go find some books!",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: library.savedBooks.length,
                  itemBuilder: (context, index) {
                    final book = library.savedBooks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: book.thumbnailUrl.isNotEmpty
                            ? Image.network(
                                book.thumbnailUrl,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.book),
                              )
                            : const Icon(Icons.book),
                        title: Text(book.title),
                        subtitle: Text(book.authors),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            // 1. Await the removal
                            await library.removeBook(book); 
                            
                            // 2. Check if the screen is still active before showing SnackBar
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed ${book.title}')),
                              );
                            }
                          }, // This } and ) match the onPressed and IconButton
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}