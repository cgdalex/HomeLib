class Book {
  final String title;
  final String authors;
  final String thumbnailUrl;

  Book({required this.title, required this.authors, required this.thumbnailUrl});

  // A factory to turn JSON into a Book object
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    return Book(
      title: volumeInfo['title'] ?? 'No Title',
      authors: (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author',
      // The API often returns http; replace with https for security/iOS compatibility
      thumbnailUrl: volumeInfo['imageLinks']?['thumbnail']?.replaceFirst('http', 'https') ?? '',
    );
  }
}