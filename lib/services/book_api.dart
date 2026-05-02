import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

Future<List<Book>> fetchBooks(String query) async {
  // Do not search if the input is empty
  if (query.trim().isEmpty) {
    return [];
  }

  // Makes the search safe for spaces and special characters
  final encodedQuery = Uri.encodeComponent(query);

  final url = Uri.parse(
    'https://www.googleapis.com/books/v1/volumes?q=$encodedQuery&maxResults=20',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Google Books stores the actual book results inside "items"
    final List items = data['items'] ?? [];

    return items.map((item) => Book.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load books');
  }
}