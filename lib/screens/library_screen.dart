import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_collection_provider.dart';
import '../providers/library_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedLibraryStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    final filteredLibraryBooks = _selectedLibraryStatus == 'All'
        ? library.savedBooks
        : library.savedBooks.where((book) {
            return book.status == _selectedLibraryStatus;
          }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF101010),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101010),
          foregroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 0,
          bottom: TabBar(
            indicatorColor: Colors.amber.shade700,
            labelColor: Colors.amber.shade700,
            unselectedLabelColor: Colors.grey.shade500,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                icon: const Icon(Icons.library_books),
                text: 'Library (${library.savedBooks.length})',
              ),
              Tab(
                icon: const Icon(Icons.bookmark),
                text: 'Wish List (${library.wishlist.length})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                _buildStatusFilterBar(
                  allBooks: library.savedBooks,
                ),
                Expanded(
                  child: _buildBookList(
                    context: context,
                    books: filteredLibraryBooks,
                    emptyIcon: Icons.library_books_outlined,
                    emptyTitle: _selectedLibraryStatus == 'All'
                        ? 'Your library is empty'
                        : 'No $_selectedLibraryStatus books',
                    emptySubtitle: _selectedLibraryStatus == 'All'
                        ? 'Search for books and add them to your library.'
                        : 'Try choosing a different reading status filter.',
                    isWishlist: false,
                  ),
                ),
              ],
            ),
            _buildBookList(
              context: context,
              books: library.wishlist,
              emptyIcon: Icons.bookmark_border,
              emptyTitle: 'Your wish list is empty',
              emptySubtitle: 'Save books here that you want to read later.',
              isWishlist: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterBar({
    required List<Book> allBooks,
  }) {
    final statuses = [
      'All',
      'Want to Read',
      'Reading',
      'Completed',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF242424),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((status) {
            final isSelected = _selectedLibraryStatus == status;
            final count = status == 'All'
                ? allBooks.length
                : allBooks.where((book) => book.status == status).length;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  setState(() {
                    _selectedLibraryStatus = status;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.amber.shade700
                        : Colors.amber.shade700.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? Colors.amber.shade700
                          : Colors.amber.shade700.withOpacity(0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.black : Colors.amber.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black.withOpacity(0.16)
                              : Colors.amber.shade700.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : Colors.amber.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookList({
    required BuildContext context,
    required List<Book> books,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    required bool isWishlist,
  }) {
    if (books.isEmpty) {
      return _buildEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        return _buildBookRow(
          context: context,
          book: book,
          isWishlist: isWishlist,
        );
      },
    );
  }

  Widget _buildBookRow({
    required BuildContext context,
    required Book book,
    required bool isWishlist,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookCover(book),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBookInfo(
                context: context,
                book: book,
                isWishlist: isWishlist,
              ),
            ),
            const SizedBox(width: 16),
            _buildActionButtons(
              context: context,
              book: book,
              isWishlist: isWishlist,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfo({
    required BuildContext context,
    required Book book,
    required bool isWishlist,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          book.authors,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!isWishlist)
              _buildStatusDropdown(
                context: context,
                book: book,
              )
            else
              _buildChip(
                icon: Icons.bookmark,
                text: 'Wish List',
                color: Colors.blue.shade600,
              ),
            if (!isWishlist)
              _buildOwnershipButton(
                context: context,
                book: book,
              ),
            if (book.personalRating > 0)
              _buildChip(
                icon: Icons.star,
                text: '${book.personalRating.toStringAsFixed(0)} / 5',
                color: Colors.amber.shade700,
              ),
            if (book.notes.trim().isNotEmpty)
              _buildChip(
                icon: Icons.note_alt_outlined,
                text: 'Has notes',
                color: Colors.deepPurple.shade400,
              ),
          ],
        ),
        if (book.notes.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            book.notes,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons({
    required BuildContext context,
    required Book book,
    required bool isWishlist,
  }) {
    final library = context.read<LibraryProvider>();
    final collection = context.read<BookCollectionProvider>();

    if (isWishlist) {
      return SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Move to Library',
              style: IconButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.black,
                minimumSize: const Size(44, 44),
              ),
              onPressed: () async {
                await library.moveToLibrary(book);

                if (!context.mounted) return;

                await collection.addBook(
                  book.copyWith(status: 'Want to Read'),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Moved ${book.title} to Library'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            IconButton(
              tooltip: 'Remove from Wish List',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade900.withOpacity(0.35),
                foregroundColor: Colors.red.shade200,
                minimumSize: const Size(44, 44),
              ),
              onPressed: () async {
                await library.removeFromWishlist(book);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${book.title}'),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 52,
      child: Center(
        child: IconButton(
          tooltip: 'Remove',
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade900.withOpacity(0.35),
            foregroundColor: Colors.red.shade200,
            minimumSize: const Size(44, 44),
          ),
          onPressed: () async {
            await library.removeBook(book);
            await collection.removeBook(book);

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed ${book.title}'),
                backgroundColor: Colors.red.shade700,
              ),
            );
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }

  Widget _buildBookCover(Book book) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: book.thumbnailUrl.isNotEmpty
          ? Image.network(
              book.thumbnailUrl,
              width: 74,
              height: 110,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (context, error, stackTrace) {
                return _buildCoverFallback();
              },
            )
          : _buildCoverFallback(),
    );
  }

  Widget _buildCoverFallback() {
    return Container(
      width: 74,
      height: 110,
      color: const Color(0xFF252525),
      child: Icon(
        Icons.book,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildStatusDropdown({
    required BuildContext context,
    required Book book,
  }) {
    final library = context.read<LibraryProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade700.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.amber.shade700.withOpacity(0.45),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: book.status,
          dropdownColor: const Color(0xFF1E1E1E),
          iconEnabledColor: Colors.amber.shade700,
          style: TextStyle(
            color: Colors.amber.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          items: const [
            DropdownMenuItem(
              value: 'Want to Read',
              child: Text('Want to Read'),
            ),
            DropdownMenuItem(
              value: 'Reading',
              child: Text('Reading'),
            ),
            DropdownMenuItem(
              value: 'Completed',
              child: Text('Completed'),
            ),
          ],
          onChanged: (String? newStatus) {
            if (newStatus != null) {
              library.updateBookStatus(book, newStatus);
            }
          },
        ),
      ),
    );
  }

  Widget _buildOwnershipButton({
    required BuildContext context,
    required Book book,
  }) {
    final library = context.read<LibraryProvider>();
    final bool isPhysical = book.ownershipType == 'Physical';

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        final newOwnershipType = isPhysical ? 'Digital' : 'Physical';

        await library.updateBookOwnershipType(
          book,
          newOwnershipType,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${book.title} marked as $newOwnershipType',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.green.shade500.withOpacity(0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.green.shade500.withOpacity(0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPhysical ? Icons.menu_book : Icons.devices,
              color: Colors.green.shade500,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              isPhysical ? 'Physical' : 'Digital',
              style: TextStyle(
                color: Colors.green.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.amber.shade700,
              size: 54,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}