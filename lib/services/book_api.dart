import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

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

  final googleBooksApiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';

  final queryParameters = {
    'q': cleanedQuery,
    'maxResults': '20',
    if (googleBooksApiKey.isNotEmpty) 'key': googleBooksApiKey,
  };

  final url = Uri.https(
    'www.googleapis.com',
    '/books/v1/volumes',
    queryParameters,
  );

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

  throw Exception('Failed to load books. Status code: ${response.statusCode}');
}