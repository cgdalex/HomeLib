class Book {
  final String title;
  final String authors;
  final String thumbnailUrl;

  Book({
    required this.title,
    required this.authors,
    required this.thumbnailUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};

    return Book(
      title: volumeInfo['title'] ?? 'No Title',
      authors: (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ??
          'Unknown Author',

      // Gets the best available cover image from the Google Books API.
      // Some books have "thumbnail", some only have "smallThumbnail".
      // We also force https and remove edge=curl because that part can cause
      // image loading issues in Flutter web.
      thumbnailUrl: (volumeInfo['imageLinks']?['thumbnail'] ??
              volumeInfo['imageLinks']?['smallThumbnail'] ??
              '')
          .toString()
          .replaceFirst('http://', 'https://')
          .replaceAll('&edge=curl', ''),
    );
  }
}