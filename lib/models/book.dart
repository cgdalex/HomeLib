class Book {
  final String id; // Added ID for duplicate checking
  final String title;
  final String authors;
  final String thumbnailUrl;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnailUrl,
  });

  // 1. Updated fromJson to capture the ID
  factory Book.fromJson(Map<String, dynamic> json) {
    // Note: 'id' is at the top level of the API response, 
    // while 'title' is inside 'volumeInfo'
    final volumeInfo = json['volumeInfo'] ?? {};

    return Book(
      id: json['id'] ?? '', 
      title: volumeInfo['title'] ?? 'No Title',
      authors: (volumeInfo['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author',
      thumbnailUrl: volumeInfo['imageLinks']?['thumbnail']?.replaceFirst('http', 'https') ?? '',
    );
  }

  // 2. The missing toJson method (Essential for Task #2)
  // This turns your Book object back into a Map so SharedPreferences can save it
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volumeInfo': {
        'title': title,
        'authors': authors.split(', '), // Turn string back into list
        'imageLinks': {'thumbnail': thumbnailUrl},
      }
    };
  }
}