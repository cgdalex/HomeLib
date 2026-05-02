import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

Future<List<Book>> fetchBooks(String query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  final encodedQuery = Uri.encodeComponent(query);

  final url = Uri.parse(
    'https://www.googleapis.com/books/v1/volumes?q=$encodedQuery&maxResults=20',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List items = data['items'] ?? [];

    return items.map((item) => Book.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load books');
  }
}