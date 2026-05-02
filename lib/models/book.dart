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
      thumbnailUrl: volumeInfo['imageLinks']?['thumbnail']
              ?.replaceFirst('http', 'https') ??
          '',
    );
  }
}