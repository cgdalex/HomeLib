// This class represents one book in our app.
// It stores the information we care about from the Google Books API.
class Book {
  // Unique Google Books ID.
  // This helps us prevent duplicate books from being added.
  final String id;

  // Book title.
  final String title;

  // Book author or authors.
  final String authors;

  // Cover image URL from Google Books.
  final String thumbnailUrl;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnailUrl,
  });

  // Creates a Book object from the JSON data returned by Google Books.
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};

    return Book(
      // Google Books puts the unique book ID at the top level of the JSON.
      id: json['id'] ?? '',

      // Gets the book title, or uses "No Title" if missing.
      title: volumeInfo['title'] ?? 'No Title',

      // Google Books gives authors as a list, so we join them into one string.
      authors: (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ??
          'Unknown Author',

      // Gets the best available cover image from the Google Books API.
      // Some books have "thumbnail", some only have "smallThumbnail".
      // We force https and remove edge=curl because that can cause issues on web.
      thumbnailUrl: (volumeInfo['imageLinks']?['thumbnail'] ??
              volumeInfo['imageLinks']?['smallThumbnail'] ??
              '')
          .toString()
          .replaceFirst('http://', 'https://')
          .replaceAll('&edge=curl', ''),
    );
  }
}