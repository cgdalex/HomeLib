import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

// Cache to save API hits and make the UI feel faster
final Map<String, List<Book>> _bookSearchCache = {};

Future<List<Book>> fetchBooks(String query) async {
  final cleanedQuery = query.trim();

  if (cleanedQuery.isEmpty) {
    return [];
  }

  final cacheKey = cleanedQuery.toLowerCase();

  if (_bookSearchCache.containsKey(cacheKey)) {
    return _bookSearchCache[cacheKey]!;
  }

  // NEW: Instead of dotenv, we grab the key from the environment/compiler
  // This matches the --dart-define=API_KEY name used in your GitHub Action
  const googleBooksApiKey = String.fromEnvironment('API_KEY');

  final queryParameters = {
    'q': cleanedQuery,
    'maxResults': '20',
    // Only add the key if it's not empty
    if (googleBooksApiKey.isNotEmpty) 'key': googleBooksApiKey,
  };

  final url = Uri.https(
    'www.googleapis.com',
    '/books/v1/volumes',
    queryParameters,
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'] ?? [];

      final books = items.map((item) => Book.fromJson(item)).toList();

      _bookSearchCache[cacheKey] = books;
      return books;
    }

    if (response.statusCode == 429) {
      throw Exception('Too many searches. Wait a minute and try again.');
    }

    throw Exception('Failed to load books. Status: ${response.statusCode}');
  } catch (e) {
    // Catch network errors or JSON parsing errors
    throw Exception('Search error: $e');
  }
}