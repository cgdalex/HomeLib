import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_detail_dialog.dart';
import '../models/book.dart';
import '../services/book_api.dart';
import '../providers/book_collection_provider.dart';
import '../providers/library_provider.dart';

const String kHomeLibAscii = r'''
HHHHHHHHH     HHHHHHHHH                                                                  LLLLLLLLLLL             IIIIIIIIIIBBBBBBBBBBBBBBBBB   
H:::::::H     H:::::::H                                                                  L:::::::::L             I::::::::IB::::::::::::::::B  
H:::::::H     H:::::::H                                                                  L:::::::::L             I::::::::IB::::::BBBBBB:::::B 
HH::::::H     H::::::HH                                                                  LL:::::::LL             II::::::IIBB:::::B     B:::::B
  H:::::H     H:::::H     ooooooooooo      mmmmmmm    mmmmmmm       eeeeeeeeeeee           L:::::L                 I::::I    B::::B     B:::::B
  H:::::H     H:::::H   oo:::::::::::oo  mm:::::::m  m:::::::mm   ee::::::::::::ee         L:::::L                 I::::I    B::::B     B:::::B
  H::::::HHHHH::::::H  o:::::::::::::::om::::::::::mm::::::::::m e::::::eeeee:::::ee       L:::::L                 I::::I    B::::BBBBBB:::::B 
  H:::::::::::::::::H  o:::::ooooo:::::om::::::::::::::::::::::me::::::e     e:::::e       L:::::L                 I::::I    B:::::::::::::BB  
  H:::::::::::::::::H  o::::o     o::::om:::::mmm::::::mmm:::::me:::::::eeeee::::::e       L:::::L                 I::::I    B::::BBBBBB:::::B 
  H::::::HHHHH::::::H  o::::o     o::::om::::m   m::::m   m::::me:::::::::::::::::e        L:::::L                 I::::I    B::::B     B:::::B
  H:::::H     H:::::H  o::::o     o::::om::::m   m::::m   m::::me::::::eeeeeeeeeee         L:::::L                 I::::I    B::::B     B:::::B
  H:::::H     H:::::H  o::::o     o::::om::::m   m::::m   m::::me:::::::e                  L:::::L         LLLLLL  I::::I    B::::B     B:::::B
HH::::::H     H::::::HHo:::::ooooo:::::om::::m   m::::m   m::::me::::::::e               LL:::::::LLLLLLLLL:::::LII::::::IIBB:::::BBBBBB::::::B
H:::::::H     H:::::::Ho:::::::::::::::om::::m   m::::m   m::::m e::::::::eeeeeeee       L::::::::::::::::::::::LI::::::::IB:::::::::::::::::B 
H:::::::H     H:::::::H oo:::::::::::oo m::::m   m::::m   m::::m  ee:::::::::::::e       L::::::::::::::::::::::LI::::::::IB::::::::::::::::B  
HHHHHHHHH     HHHHHHHHH   ooooooooooo   mmmmmm   mmmmmm   mmmmmm    eeeeeeeeeeeeee       LLLLLLLLLLLLLLLLLLLLLLLLIIIIIIIIIIBBBBBBBBBBBBBBBBB   
''';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _asciiScrollController = ScrollController();

  List<Book> _books = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  int? _hoveredIndex;

  Future<void> _searchBooks() async {
    if (_searchController.text.trim().length < 2) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = '';
      _books = [];
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

  Future<void> _addBookToLibrary(Book book) async {
    final collectionProvider = context.read<BookCollectionProvider>();
    final libraryProvider = context.read<LibraryProvider>();

    final alreadyAdded = collectionProvider.isBookAdded(book);

    if (!alreadyAdded) {
      await collectionProvider.addBook(book);
      await libraryProvider.addBook(book);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyAdded
              ? '${book.title} is already in your library'
              : 'Added ${book.title} to Library!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addBookToWishList(Book book) async {
    final libraryProvider = context.read<LibraryProvider>();

    final alreadyInWishList = libraryProvider.wishlist.any(
      (savedBook) => savedBook.id == book.id,
    );

    final alreadyInLibrary = libraryProvider.savedBooks.any(
      (savedBook) => savedBook.id == book.id,
    );

    if (!alreadyInWishList && !alreadyInLibrary) {
      await libraryProvider.addToWishlist(
        book.copyWith(status: 'Wish List'),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          alreadyInWishList
              ? '${book.title} is already in your wish list'
              : alreadyInLibrary
                  ? '${book.title} is already in your library'
                  : 'Added ${book.title} to Wish List!',
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBookCard(Book book, int index) {
    final bool isHovered = _hoveredIndex == index;

    final bookCollection = context.watch<BookCollectionProvider>();
    final bool isAdded = bookCollection.isBookAdded(book);

    final libraryProvider = context.watch<LibraryProvider>();
    final bool isInWishList = libraryProvider.wishlist.any(
      (savedBook) => savedBook.id == book.id,
    );

    final bool shouldShowLibraryButton = isHovered || isAdded;
    final bool shouldShowWishListButton = isHovered || isInWishList;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredIndex = null;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            book.thumbnailUrl,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCoverFallback();
                            },
                          )
                        : _buildCoverFallback(),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isHovered ? 0.42 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.75),
                          builder: (context) {
                            return BookDetailDialog(book: book);
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isHovered ? 1.0 : 0.0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'View Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: shouldShowLibraryButton ? 1.0 : 0.0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _addBookToLibrary(book),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isAdded
                                ? Colors.green.withOpacity(0.95)
                                : Colors.amber.shade700.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            isAdded ? Icons.check : Icons.add,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: shouldShowWishListButton ? 1.0 : 0.0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _addBookToWishList(book),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isInWishList
                                ? Colors.lightBlue.shade800.withOpacity(0.95)
                                : Colors.blue.shade600.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            isInWishList
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.authors,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverFallback() {
    return Container(
      color: const Color(0xFF252525),
      child: Center(
        child: Icon(
          Icons.book,
          size: 42,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildFixedWidthAscii() {
    const double characterWidth = 7.2;
    const double lineHeight = 13.0;
    const double fontSize = 13.0;

    final List<String> lines = kHomeLibAscii.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return SizedBox(
          height: lineHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: line.split('').map((character) {
              return SizedBox(
                width: characterWidth,
                child: character == ' '
                    ? const SizedBox.shrink()
                    : Text(
                        character,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Color(0xFFF4A261),
                          fontSize: fontSize,
                          height: 1.0,
                          fontFamily: 'CascadiaMono',
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0,
                          wordSpacing: 0,
                        ),
                      ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _asciiScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),

      // No AppBar here.
      // The sidebar still stays because it is controlled by main.dart.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.amber,
                    decoration: InputDecoration(
                      labelText: 'Search for a book',
                      hintText: 'Example: The Hobbit',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.amber.shade700,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _searchBooks(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade800,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: _isLoading ? null : _searchBooks,
                  child: Text(
                    _isLoading ? 'Loading...' : 'Search',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Colors.amber.shade700,
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red.shade100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Expanded(
            child: !_hasSearched && !_isLoading
                ? _buildLandingState()
                : _books.isEmpty && !_isLoading
                    ? _buildNoResultsState()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          itemCount: _books.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 22,
                            childAspectRatio: 0.62,
                          ),
                          itemBuilder: (context, index) {
                            final book = _books[index];
                            return _buildBookCard(book, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Scrollbar(
              controller: _asciiScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _asciiScrollController,
                scrollDirection: Axis.horizontal,
                child: _buildFixedWidthAscii(),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Welcome to HomeLIB v1.0.0',
              style: TextStyle(
                color: Color(0xFFF4A261),
                fontSize: 30,
                fontFamily: 'CascadiaMono',
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type a title or author in the search bar above to begin.',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 14,
                fontFamily: 'CascadiaMono',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search books. Open details. Add to your library or wish list.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontFamily: 'CascadiaMono',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
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
              Icons.search_off,
              color: Colors.amber.shade700,
              size: 54,
            ),
            const SizedBox(height: 12),
            const Text(
              'No books found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different title, author, or keyword.',
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