import 'package:flutter/material.dart';

// Imports the Book model so this screen knows what a Book object looks like.
// The Book class stores information like title, author, and cover image URL.
import '../models/book.dart';

// Imports the function that talks to the Google Books API.
// fetchBooks() is what actually searches for books online.
import '../services/book_api.dart';

// HomeScreen is the main screen of the app.
// It is StatefulWidget because the screen changes while the user uses it:
// - the search text changes
// - loading state changes
// - error messages may appear
// - book results update after a search
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
      // This causes the ListView below to display the new books.
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
      // error message, and book results list.
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

          // Expanded makes the book list fill the remaining vertical space.
          // Without Expanded, the ListView could cause layout errors inside a Column.
          Expanded(
            // ListView.builder creates rows only as needed,
            // which is better for long lists than manually creating every row.
            child: ListView.builder(
              // Number of books currently stored in the results list.
              itemCount: _books.length,

              // Builds one list item for each book.
              itemBuilder: (context, index) {
                // Gets the current book from the list based on its index.
                final book = _books[index];

                // Displays each book as a simple row with title and author.
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.authors),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}