// This class represents one book in our app.
// It stores the information we care about from the Google Books API
// and also supports saving/loading books locally.
class Book {
  // Unique Google Books ID.
  // This helps prevent duplicate books from being added.
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

  // Creates a Book object from JSON.
  //
  // This supports two types of JSON:
  // 1. Google Books API JSON, which has "volumeInfo"
  // 2. Saved local JSON from shared_preferences, which does not have "volumeInfo"
  factory Book.fromJson(Map<String, dynamic> json) {
    // If the JSON has "volumeInfo", it came from the Google Books API.
    if (json.containsKey('volumeInfo')) {
      final volumeInfo = json['volumeInfo'] ?? {};

      return Book(
        // Google Books puts the unique book ID at the top level.
        id: json['id'] ?? '',

        // Gets the book title, or uses a fallback if missing.
        title: volumeInfo['title'] ?? 'No Title',

        // Google Books gives authors as a list, so we join them into one string.
        authors: (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ??
            'Unknown Author',

        // Gets the best available cover image.
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

    // If there is no "volumeInfo", this JSON came from our saved local storage.
    // This happens when we load books back from shared_preferences.
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      authors: json['authors'] ?? 'Unknown Author',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }

  // ADDED THIS:
  // Converts a Book object into simple JSON.
  // This is used when saving books locally with shared_preferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}