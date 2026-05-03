import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'book_detail_dialog.dart';

// Imports the Book model so this screen knows what a Book object looks like.
// The Book class stores information like title, author, and cover image URL.
import '../models/book.dart';

// Imports the function that talks to the Google Books API.
// fetchBooks() is what actually searches for books online.
import '../services/book_api.dart';

// Imports our separate provider for books added from the search screen.
// This keeps your checkmark/save-between-refreshes system working.
import '../providers/book_collection_provider.dart';

// ADDED THIS:
// Imports your buddy's LibraryProvider.
// This lets the HomeScreen send books to the LibraryScreen.
import '../providers/library_provider.dart';

// HomeScreen is the main screen of the app.
// It is StatefulWidget because the screen changes while the user uses it:
// - the search text changes
// - loading state changes
// - error messages may appear
// - book results update after a search
// - hover state changes when the mouse moves over a book card
// - added books need to update from plus icons to check icons
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// This class holds the actual changing data/state for HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  // Controller used to read what the user types into the search TextField.
  // Without this, we would not easily know what book title the user searched.
  final TextEditingController _searchController = TextEditingController();

  // Stores the list of books returned from the Google Books API.
  // It starts empty because no search has happened yet.
  List<Book> _books = [];

  // Tracks whether a search is currently running.
  // When true, we show a loading spinner and disable the Search button.
  bool _isLoading = false;

  // Stores an error message if something goes wrong during the search.
  // It starts empty because there is no error at first.
  String _errorMessage = '';

  // Stores which book card is currently being hovered over.
  // This allows us to darken only the image that the mouse is over.
  // The ? means it can be null when no card is being hovered.
  int? _hoveredIndex;

  // This function runs when the user presses the Search button
  // or presses Enter inside the search box.
  Future<void> _searchBooks() async {
    // Prevents tiny or empty searches from being sent to the API.
    // This helps avoid unnecessary API calls.
    if (_searchController.text.trim().length < 2) {
      return;
    }

    // setState tells Flutter that something changed and the screen
    // needs to rebuild with the new values.
    setState(() {
      // Shows the loading spinner and changes the button text to "Loading..."
      _isLoading = true;

      // Clears any old error message from a previous failed search.
      _errorMessage = '';
    });

    try {
      // Calls the Google Books API using the user's search text.
      // await means the app waits here until the API returns results.
      final results = await fetchBooks(_searchController.text);

      // Once the API returns results, save them into _books.
      // This causes the grid below to display the new books.
      setState(() {
        _books = results;
      });
    } catch (error) {
      // If something goes wrong, such as no internet, bad API key,
      // or rate limiting, show an error message on the page.
      setState(() {
        _errorMessage = 'Failed to search books: $error';
      });
    } finally {
      // finally always runs whether the search worked or failed.
      // This makes sure the loading spinner turns off.
      setState(() {
        _isLoading = false;
      });
    }
  }

  // This helper function builds one Plex-style book card.
  // It keeps the main build() method cleaner because the card UI is longer.
  Widget _buildBookCard(Book book, int index) {
    // Checks whether this specific card is the one currently being hovered.
    // If true, we show the dark overlay and the small add button.
    final bool isHovered = _hoveredIndex == index;

    // Reads our shared book collection provider.
    // This lets the card know if this book has already been added.
    final bookCollection = context.watch<BookCollectionProvider>();

    // Checks if this specific book is already saved in our added books list.
    // If true, the button will show a checkmark instead of a plus sign.
    final bool isAdded = bookCollection.isBookAdded(book);

    // This controls when the button is visible.
    // Before, the button only showed on hover.
    // Now it shows if the card is hovered OR if the book is already added.
    final bool shouldShowButton = isHovered || isAdded;

    // MouseRegion lets Flutter detect when the mouse enters or leaves a card.
    // This is what makes the hover effect work on web/desktop.
    return MouseRegion(
      // Runs when the mouse moves onto this card.
      onEnter: (_) {
        setState(() {
          _hoveredIndex = index;
        });
      },

      // Runs when the mouse leaves this card.
      onExit: (_) {
        setState(() {
          _hoveredIndex = null;
        });
      },

      // Column stacks the cover image on top and the text underneath.
      // This matches the Plex-style layout better than ListTile.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expanded gives the cover image most of the vertical card space.
          Expanded(
            // Stack lets us layer widgets on top of each other:
            // 1. book cover image
            // 2. dark hover overlay
            // 3. add/check button in the bottom-right corner
            child: Stack(
              children: [
                
                // Positioned.fill makes the cover image fill the whole image area.
                Positioned.fill(
                  child: ClipRRect(
                    // Rounds the corners of the book cover.
                    borderRadius: BorderRadius.circular(10),

                    // If the book has a cover URL, try to load it.
                    // If not, show a default fallback box with a book icon.
                    child: book.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            book.thumbnailUrl,

                            // Makes the image fill the available space
                            // without looking stretched.
                            fit: BoxFit.cover,

                            // This helps Flutter web load Google Books images
                            // by asking Flutter to use a normal browser image element when possible.
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,

                            // If the image fails to load, show a clean fallback
                            // instead of Flutter's ugly red error box.
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.book, size: 40),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.book, size: 40),
                            ),
                          ),
                  ),
                ),

                // This is the dark overlay that appears on hover.
                // It sits on top of the image but underneath the add/check button.
                Positioned.fill(
                  child: AnimatedOpacity(
                    // Controls how fast the dark overlay fades in and out.
                    duration: const Duration(milliseconds: 180),

                    // If hovered, make the overlay visible.
                    // If not hovered, make it invisible.
                    opacity: isHovered ? 0.35 : 0.0,

                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
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

                // This positions the small add/check button in the bottom-right
                // corner of the image, similar to the three-dot menu in Plex.
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: AnimatedOpacity(
                    // Makes the button fade in and out smoothly.
                    duration: const Duration(milliseconds: 180),

                    // Shows button while hovered.
                    // Also keeps it visible if the book has already been added.
                    opacity: shouldShowButton ? 1.0 : 0.0,

                    // Material gives the button a proper circular background.
                    child: Material(
                      // Green when already added, black when it can still be added.
                      color: isAdded
                          ? Colors.green.withOpacity(0.85)
                          : Colors.black.withOpacity(0.75),
                      shape: const CircleBorder(),

                      // InkWell makes the circular button clickable.
                      child: InkWell(
                        customBorder: const CircleBorder(),

                        // Saves the book into both providers:
                        // 1. BookCollectionProvider keeps your checkmark behavior working.
                        // 2. LibraryProvider sends the book to your buddy's LibraryScreen.
                        onTap: () async {
                          // Check if the book was already added BEFORE trying to add it.
                          final alreadyAdded = context
                              .read<BookCollectionProvider>()
                              .isBookAdded(book);

                          // Add the book only if it is not already in the collection.
                          if (!alreadyAdded) {
                            // This keeps your current add/checkmark system working.
                            await context
                                .read<BookCollectionProvider>()
                                .addBook(book);

                            // ADDED THIS FROM YOUR BUDDY'S CHANGE:
                            // This sends the same book to LibraryProvider
                            // so your buddy's LibraryScreen can display it.
                            await context.read<LibraryProvider>().addBook(book);
                          }

                          // Force the card to rebuild so the plus icon updates to a checkmark.
                          setState(() {});

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                alreadyAdded
                                    ? '${book.title} is already added'
                                    : 'Added ${book.title} to Library!',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },

                        // Padding controls the size of the circular button.
                        // This cannot be const because the icon changes dynamically.
                        child: Padding(
                          padding: const EdgeInsets.all(8),

                          // Shows a checkmark if the book is already saved.
                          // Otherwise, shows the plus icon.
                          child: Icon(
                            isAdded ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Adds space between the cover image and the book title.
          const SizedBox(height: 8),

          // Shows the book title underneath the image.
          // maxLines keeps long titles from taking over the whole card.
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

          // Adds a little space between title and author.
          const SizedBox(height: 4),

          // Shows the author name underneath the title.
          // The gray color makes it feel secondary, like Plex metadata text.
          Text(
            book.authors,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Disposes of the text controller when this screen is removed.
    // This prevents memory leaks.
    _searchController.dispose();

    // Calls the parent dispose method.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold gives the page its basic layout structure,
    // including an app bar and body area.
    return Scaffold(
      // The top bar of the app.
      appBar: AppBar(
        title: const Text('HomeLIB'),
      ),

      // The body contains the search bar, loading spinner,
      // error message, and book results grid.
      body: Column(
        children: [
          // Padding adds space around the search row so it is not
          // touching the edges of the screen.
          Padding(
            padding: const EdgeInsets.all(12),

            // Row places the search box and Search button side by side.
            child: Row(
              children: [
                // Expanded makes the TextField take up all available
                // horizontal space except for the button.
                Expanded(
                  child: TextField(
                    // Connects this text box to _searchController
                    // so we can read what the user typed.
                    controller: _searchController,

                    // Controls the label, hint text, and border style.
                    decoration: const InputDecoration(
                      labelText: 'Search for a book',
                      hintText: 'Example: The Hobbit',
                      border: OutlineInputBorder(),
                    ),

                    // Runs a search when the user presses Enter.
                    // The underscore means we are ignoring the submitted text
                    // because we already read it from _searchController.
                    onSubmitted: (_) => _searchBooks(),
                  ),
                ),

                // Adds horizontal space between the text box and button.
                const SizedBox(width: 8),

                // Search button that calls _searchBooks().
                ElevatedButton(
                  // If a search is already loading, disable the button.
                  // This prevents users from accidentally sending
                  // multiple API requests at the same time.
                  onPressed: _isLoading ? null : _searchBooks,

                  // The button text changes while loading.
                  child: Text(_isLoading ? 'Loading...' : 'Search'),
                ),
              ],
            ),
          ),

          // Shows a loading spinner only while _isLoading is true.
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),

          // Shows an error message only if _errorMessage is not empty.
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _errorMessage,

                // Makes the error text red so it is clearly visible.
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Expanded makes the book grid fill the remaining vertical space.
          // Without Expanded, the GridView could cause layout errors inside a Column.
          Expanded(
            // Padding keeps the grid from touching the edges of the screen.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),

              // GridView.builder creates a Plex-style grid of book cards.
              // This replaces the old vertical ListView layout.
              child: GridView.builder(
                // Number of books currently stored in the results list.
                itemCount: _books.length,

                // Controls how the grid is arranged.
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // Number of cards per row.
                  // Lower this to 4 if the cards feel too small.
                  crossAxisCount: 5,

                  // Horizontal spacing between cards.
                  crossAxisSpacing: 16,

                  // Vertical spacing between rows.
                  mainAxisSpacing: 20,

                  // Controls card shape.
                  // Smaller numbers make cards taller like posters/book covers.
                  childAspectRatio: 0.62,
                ),

                // Builds one card for each book.
                itemBuilder: (context, index) {
                  // Gets the current book from the list based on its index.
                  final book = _books[index];

                  // Uses the helper function above to build the card UI.
                  return _buildBookCard(book, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}