import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_collection_provider.dart';
import '../providers/library_provider.dart';

// This popup appears when the user clicks a book cover on the HomeScreen.
// It shows a larger cover, book title, author, extra book details,
// and the Google Books description.
class BookDetailDialog extends StatefulWidget {
  final Book book;

  const BookDetailDialog({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailDialog> createState() => _BookDetailDialogState();
}

class _BookDetailDialogState extends State<BookDetailDialog> {
  // This Future stores the extra book details from Google Books.
  // We use a FutureBuilder later so the popup can show while the
  // description is still loading.
  late Future<Map<String, dynamic>> _bookDetailsFuture;

  @override
  void initState() {
    super.initState();

    // Fetch the detailed book info as soon as the popup opens.
    _bookDetailsFuture = _fetchBookDetails();
  }

  // This function gets extra details for one specific book using its Google Books ID.
  // We do this here so we do not have to change the main Book model.
  Future<Map<String, dynamic>> _fetchBookDetails() async {
    final url = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes/${widget.book.id}',
    );

    final response = await http.get(url);

    // If the request fails, return an empty map instead of crashing the popup.
    if (response.statusCode != 200) {
      return {};
    }

    final data = jsonDecode(response.body);
    final volumeInfo = data['volumeInfo'] ?? {};

    return {
      'description': _cleanDescription(volumeInfo['description'] ?? ''),
      'publisher': volumeInfo['publisher'] ?? '',
      'publishedDate': volumeInfo['publishedDate'] ?? '',
      'pageCount': volumeInfo['pageCount']?.toString() ?? '',
      'categories': (volumeInfo['categories'] as List<dynamic>?)?.join(', ') ?? '',
    };
  }

  // Google Books descriptions sometimes include HTML tags like <b> or <br>.
  // This removes those tags so the description looks clean in the popup.
  String _cleanDescription(String description) {
    return description.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  // Google Books can return dates like:
  // 2012-11-08, 2012-11, or just 2012.
  // This changes 2012-11-08 into 11-08-2012.
  String _formatDate(String date) {
    if (date.trim().isEmpty) {
      return '';
    }

    final parts = date.split('-');

    // Handles full dates like 2012-11-08.
    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1];
      final day = parts[2];

      return '$month-$day-$year';
    }

    // Handles partial dates like 2012-11.
    if (parts.length == 2) {
      final year = parts[0];
      final month = parts[1];

      return '$month-$year';
    }

    // Handles dates that only have the year, like 2012.
    return date;
  }

  // Google Books can return a huge category string.
  // This shortens it so the category bubble does not take over the popup.
  String _formatCategories(String categories) {
    if (categories.trim().isEmpty) {
      return '';
    }

    // Split the long comma-separated category text into smaller pieces.
    final parts = categories
        .split(',')
        .map((category) => category.trim())
        .where((category) => category.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '';
    }

    // Keep only the first three categories so the bubble stays clean.
    if (parts.length <= 3) {
      return parts.join(' • ');
    }

    return '${parts.take(3).join(' • ')} • ...';
  }

  // This adds the selected book to both providers:
  // 1. BookCollectionProvider controls the plus/checkmark state on HomeScreen.
  // 2. LibraryProvider controls what appears in the LibraryScreen.
  Future<void> _addBookToLibrary(BuildContext context) async {
    final alreadyAdded =
        context.read<BookCollectionProvider>().isBookAdded(widget.book);

    if (!alreadyAdded) {
      await context.read<BookCollectionProvider>().addBook(widget.book);
      await context.read<LibraryProvider>().addBook(widget.book);
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyAdded
              ? '${widget.book.title} is already in your library'
              : 'Added ${widget.book.title} to Library!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watches the provider so the button updates from "Add" to "Added"
    // if the book is already in the user's library.
    final bool isAdded =
        context.watch<BookCollectionProvider>().isBookAdded(widget.book);

    return Dialog(
      backgroundColor: const Color(0xFF151515),
      insetPadding: const EdgeInsets.symmetric(horizontal: 70, vertical: 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      // ConstrainedBox keeps the popup from becoming too large on wide screens.
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1050,
          maxHeight: 670,
        ),

        // Stack lets us place the X button in the top-right corner.
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),

              // Main popup layout:
              // book cover on the left, details on the right.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCover(),

                  const SizedBox(width: 34),

                  // Expanded makes the right side take up the remaining space.
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _bookDetailsFuture,
                      builder: (context, snapshot) {
                        final details = snapshot.data ?? {};

                        final description =
                            details['description']?.toString() ?? '';
                        final publisher =
                            details['publisher']?.toString() ?? '';

                        final publishedDate = _formatDate(
                          details['publishedDate']?.toString() ?? '',
                        );

                        final pageCount =
                            details['pageCount']?.toString() ?? '';
                        final categories =
                            details['categories']?.toString() ?? '';

                        // Shortened version of the long Google Books category list.
                        final shortCategories = _formatCategories(categories);

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Book title.
                              Text(
                                widget.book.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Author text.
                              Text(
                                widget.book.authors,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 20,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Book metadata chips.
                              // These are the small bubbles near the top.
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  if (publishedDate.isNotEmpty)
                                    _buildChip(publishedDate),

                                  if (pageCount.isNotEmpty)
                                    _buildChip('$pageCount pages'),

                                  if (publisher.isNotEmpty)
                                    _buildChip(publisher),

                                  if (shortCategories.isNotEmpty)
                                    _buildChip(
                                      shortCategories,
                                      isWide: true,
                                    ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Main action button.
                              // The extra Close button was removed because the popup
                              // already has an X in the top-right corner.
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAdded
                                      ? Colors.green
                                      : Colors.amber.shade700,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _addBookToLibrary(context),
                                icon: Icon(
                                  isAdded ? Icons.check : Icons.add,
                                ),
                                label: Text(
                                  isAdded
                                      ? 'Added to Library'
                                      : 'Add to Library',
                                ),
                              ),

                              const SizedBox(height: 30),

                              const Text(
                                'Description',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // While the description is loading, show a small spinner.
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: CircularProgressIndicator(),
                                )
                              else
                                Text(
                                  description.isNotEmpty
                                      ? description
                                      : 'No description available for this book.',
                                  style: TextStyle(
                                    color: Colors.grey.shade300,
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // X button in the top-right corner.
            // This is now the only close button in the popup.
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the large cover image on the left side of the popup.
  Widget _buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: widget.book.thumbnailUrl.isNotEmpty
          ? Image.network(
              widget.book.thumbnailUrl,
              width: 260,
              height: 390,
              fit: BoxFit.cover,

              // Helps Flutter web load Google Books images using browser image behavior.
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,

              // If the cover fails to load, show a clean fallback instead.
              errorBuilder: (context, error, stackTrace) {
                return _buildCoverFallback();
              },
            )
          : _buildCoverFallback(),
    );
  }

  // Fallback cover used when a book has no image or the image fails to load.
  Widget _buildCoverFallback() {
    return Container(
      width: 260,
      height: 390,
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.book,
          size: 72,
          color: Colors.white70,
        ),
      ),
    );
  }

  // Builds the small metadata bubbles.
  // isWide is used for the category bubble because categories can be longer.
  Widget _buildChip(String text, {bool isWide = false}) {
    return Container(
      constraints: isWide ? const BoxConstraints(maxWidth: 620) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Text(
        text,
        maxLines: isWide ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 13,
        ),
      ),
    );
  }
}