import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../providers/book_collection_provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your Original Custom Header
          const Padding(
            padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
            child: Text(
              "My HomeLib",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),

          // The New Tab Bar
          const TabBar(
            indicatorColor: Colors.indigo,
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Collection"),
              Tab(text: "Wishlist"),
            ],
          ),

          // The Content Areas
          const Expanded(
            child: TabBarView(
              children: [
                _CollectionTab(), // Your original list
                _WishlistTab(),   // The new wishlist list
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- TAB 1: COLLECTION ---
class _CollectionTab extends StatelessWidget {
  const _CollectionTab();

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);

    if (library.savedBooks.isEmpty) {
      return const Center(
        child: Text(
          "Your library is empty. Go find some books!",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: library.savedBooks.length,
      itemBuilder: (context, index) {
        final book = library.savedBooks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _BookCover(url: book.thumbnailUrl),
            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.authors),
                const SizedBox(height: 8),
                _StatusDropdown(book: book), // Preserved your dropdown logic
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await context.read<LibraryProvider>().removeBook(book);
                context.read<BookCollectionProvider>().removeBook(book);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed ${book.title}')),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

// --- TAB 2: WISHLIST ---
class _WishlistTab extends StatelessWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context);

    if (library.wishlist.isEmpty) {
      return const Center(
        child: Text(
          "No books in your wishlist yet.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: library.wishlist.length,
      itemBuilder: (context, index) {
        final book = library.wishlist[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _BookCover(url: book.thumbnailUrl),
            title: Text(book.title),
            subtitle: Text(book.authors),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Move to Library Button
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () => library.moveToLibrary(book),
                  tooltip: "Move to Collection",
                ),
                // Remove from Wishlist
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => library.removeFromWishlist(book),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- REUSABLE COMPONENTS TO KEEP CODE CLEAN ---

class _BookCover extends StatelessWidget {
  final String url;
  const _BookCover({required this.url});

  @override
  Widget build(BuildContext context) {
    return url.isNotEmpty
        ? Image.network(
            url,
            width: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.book),
          )
        : const Icon(Icons.book);
  }
}

class _StatusDropdown extends StatelessWidget {
  final dynamic book;
  const _StatusDropdown({required this.book});

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<LibraryProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: book.status,
        isDense: true,
        underline: const SizedBox(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.indigo,
          fontWeight: FontWeight.w500,
        ),
        items: ['Want to Read', 'Reading', 'Completed'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newStatus) {
          if (newStatus != null) {
            library.updateBookStatus(book, newStatus);
          }
        },
      ),
    );
  }
}