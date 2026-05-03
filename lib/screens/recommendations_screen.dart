import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/library_provider.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<_AiBookRecommendation> _recommendations = [];

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: library.savedBooks.isEmpty
          ? _buildEmptyLibraryState()
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _buildHeaderCard(library.savedBooks),
                const SizedBox(height: 18),
                _buildGenerateButton(library.savedBooks),
                const SizedBox(height: 18),
                if (_isLoading) _buildLoadingCard(),
                if (_errorMessage != null) _buildErrorCard(_errorMessage!),
                if (!_isLoading && _recommendations.isNotEmpty)
                  ..._recommendations.map((recommendation) {
                    return _buildRecommendationCard(recommendation);
                  }),
              ],
            ),
    );
  }

  Widget _buildEmptyLibraryState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.amber.shade700,
              size: 54,
            ),
            const SizedBox(height: 12),
            const Text(
              'Add books first',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Picks works better once your library has a few books.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(List<Book> books) {
    final completedCount = books.where((book) {
      return book.status == 'Completed';
    }).length;

    final readingCount = books.where((book) {
      return book.status == 'Reading';
    }).length;

    final wantToReadCount = books.where((book) {
      return book.status == 'Want to Read';
    }).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade700.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.amber.shade700,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personalized AI recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on ${books.length} saved books: '
                  '$completedCount completed, '
                  '$readingCount reading, '
                  '$wantToReadCount want to read.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(List<Book> books) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () async {
                await _generateAiRecommendations(books);
              },
        icon: const Icon(Icons.auto_awesome),
        label: Text(
          _isLoading ? 'Thinking...' : 'Generate AI Picks',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              color: Colors.amber.shade700,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Looking through your library...',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.shade700.withOpacity(0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade200,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade100,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(_AiBookRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommendationCover(recommendation),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.author,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  recommendation.reason,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMiniChip(
                      icon: Icons.auto_awesome,
                      text: 'Match ${recommendation.matchScore}/100',
                      color: Colors.amber.shade700,
                    ),
                    _buildMiniChip(
                      icon: Icons.category_outlined,
                      text: recommendation.genre,
                      color: Colors.blue.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCover(_AiBookRecommendation recommendation) {
    if (recommendation.coverUrl.isEmpty) {
      return _buildFallbackRecommendationCover();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        recommendation.coverUrl,
        width: 58,
        height: 86,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackRecommendationCover();
        },
      ),
    );
  }

  Widget _buildFallbackRecommendationCover() {
    return Container(
      width: 58,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.amber.shade700.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.shade700.withOpacity(0.35),
        ),
      ),
      child: Icon(
        Icons.menu_book,
        color: Colors.amber.shade700,
        size: 32,
      ),
    );
  }

  Widget _buildMiniChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAiRecommendations(List<Book> books) async {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.trim().isEmpty) {
      setState(() {
        _errorMessage =
            'Missing GEMINI_API_KEY. Run with --dart-define or set it in your GitHub Actions build.';
        _recommendations = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recommendations = [];
    });

    try {
      final prompt = _buildPrompt(books);

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-3-flash-preview:generateContent',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.6,
            'topP': 0.85,
            'maxOutputTokens': 1800,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gemini request failed with status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final geminiText = _extractGeminiText(decoded);

      var parsedRecommendations = _parseRecommendations(geminiText);

      if (parsedRecommendations.length < 5) {
        parsedRecommendations = _fillMissingRecommendations(
          parsedRecommendations,
          books,
        );
      }

      parsedRecommendations = await _addCoverImages(parsedRecommendations);

      if (!mounted) return;

      setState(() {
        _recommendations = parsedRecommendations.take(5).toList();
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Could not generate recommendations. $error';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildPrompt(List<Book> books) {
    final libraryText = books.map((book) {
      final rating = book.personalRating == 0
          ? 'not rated'
          : '${book.personalRating.toStringAsFixed(0)}/5';

      final notes = book.notes.trim().isEmpty ? 'none' : book.notes.trim();

      return '- ${book.title} by ${book.authors}. '
          'Status: ${book.status}. '
          'Ownership: ${book.ownershipType}. '
          'Rating: $rating. '
          'Notes: $notes.';
    }).join('\n');

    return '''
You are the recommendation engine for HomeLIB, a personal book tracking app.

Recommend exactly 5 real books based on this user's library.

User library:
$libraryText

Use this exact format. Repeat the full block 5 times.

BOOK 1
TITLE: Book title here
AUTHOR: Author name here
GENRE: Short genre here
WHY: One short reason under 35 words.
MATCH: 92

BOOK 2
TITLE: Book title here
AUTHOR: Author name here
GENRE: Short genre here
WHY: One short reason under 35 words.
MATCH: 88

BOOK 3
TITLE: Book title here
AUTHOR: Author name here
GENRE: Short genre here
WHY: One short reason under 35 words.
MATCH: 85

BOOK 4
TITLE: Book title here
AUTHOR: Author name here
GENRE: Short genre here
WHY: One short reason under 35 words.
MATCH: 82

BOOK 5
TITLE: Book title here
AUTHOR: Author name here
GENRE: Short genre here
WHY: One short reason under 35 words.
MATCH: 79

Rules:
- Return exactly 5 books.
- Do not recommend books already in the user's library.
- Do not use markdown.
- Do not include a greeting.
- Do not include extra paragraphs.
- Each book must have TITLE, AUTHOR, GENRE, WHY, and MATCH.
''';
  }

  String _extractGeminiText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'];

    if (candidates is! List || candidates.isEmpty) {
      return '';
    }

    final firstCandidate = candidates.first;

    if (firstCandidate is! Map<String, dynamic>) {
      return '';
    }

    final content = firstCandidate['content'];

    if (content is! Map<String, dynamic>) {
      return '';
    }

    final parts = content['parts'];

    if (parts is! List || parts.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();

    for (final part in parts) {
      if (part is Map<String, dynamic>) {
        final text = part['text'];

        if (text is String) {
          buffer.writeln(text);
        }
      }
    }

    return buffer.toString();
  }

  List<_AiBookRecommendation> _parseRecommendations(String rawText) {
    final recommendations = <_AiBookRecommendation>[];

    final blockRegex = RegExp(
      r'(?:BOOK\s*\d+|^\d+[\).\s-]+)(.*?)(?=(?:BOOK\s*\d+|^\d+[\).\s-]+)|$)',
      caseSensitive: false,
      dotAll: true,
      multiLine: true,
    );

    final matches = blockRegex.allMatches(rawText).toList();

    if (matches.isNotEmpty) {
      for (final match in matches) {
        final block = match.group(0) ?? '';
        final recommendation = _parseSingleBlock(block);

        if (recommendation != null) {
          recommendations.add(recommendation);
        }
      }
    }

    if (recommendations.isEmpty) {
      final splitBlocks = rawText.split(RegExp(r'\n\s*\n'));

      for (final block in splitBlocks) {
        final recommendation = _parseSingleBlock(block);

        if (recommendation != null) {
          recommendations.add(recommendation);
        }
      }
    }

    final uniqueRecommendations = <_AiBookRecommendation>[];
    final seenTitles = <String>{};

    for (final recommendation in recommendations) {
      final key = recommendation.title.toLowerCase().trim();

      if (key.isNotEmpty && !seenTitles.contains(key)) {
        seenTitles.add(key);
        uniqueRecommendations.add(recommendation);
      }
    }

    return uniqueRecommendations.take(5).toList();
  }

  _AiBookRecommendation? _parseSingleBlock(String block) {
    final title = _readLineValue(block, 'TITLE');
    final author = _readLineValue(block, 'AUTHOR');
    final genre = _readLineValue(block, 'GENRE');
    final reason = _readLineValue(block, 'WHY');
    final matchText = _readLineValue(block, 'MATCH');

    if (title.isEmpty || author.isEmpty || reason.isEmpty) {
      return null;
    }

    final matchScore = int.tryParse(
          matchText.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        85;

    return _AiBookRecommendation(
      title: title,
      author: author,
      genre: genre.isEmpty ? 'Recommended' : genre,
      reason: reason,
      matchScore: matchScore.clamp(0, 100),
      coverUrl: '',
    );
  }

  String _readLineValue(String block, String label) {
    final regex = RegExp(
      '$label:\\s*(.+)',
      caseSensitive: false,
      multiLine: true,
    );

    final match = regex.firstMatch(block);

    if (match == null) {
      return '';
    }

    return match.group(1)?.trim() ?? '';
  }

  List<_AiBookRecommendation> _fillMissingRecommendations(
    List<_AiBookRecommendation> currentRecommendations,
    List<Book> libraryBooks,
  ) {
    final savedTitles = libraryBooks.map((book) {
      return book.title.toLowerCase().trim();
    }).toSet();

    final usedTitles = currentRecommendations.map((book) {
      return book.title.toLowerCase().trim();
    }).toSet();

    final filled = [...currentRecommendations];

    for (final fallback in _fallbackRecommendations) {
      final titleKey = fallback.title.toLowerCase().trim();

      if (filled.length >= 5) {
        break;
      }

      if (savedTitles.contains(titleKey) || usedTitles.contains(titleKey)) {
        continue;
      }

      filled.add(fallback);
      usedTitles.add(titleKey);
    }

    return filled.take(5).toList();
  }

  Future<List<_AiBookRecommendation>> _addCoverImages(
    List<_AiBookRecommendation> recommendations,
  ) async {
    final updatedRecommendations = <_AiBookRecommendation>[];

    for (final recommendation in recommendations) {
      final coverUrl = await _fetchBookCoverUrl(
        title: recommendation.title,
        author: recommendation.author,
      );

      updatedRecommendations.add(
        recommendation.copyWith(
          coverUrl: coverUrl,
        ),
      );
    }

    return updatedRecommendations;
  }

  Future<String> _fetchBookCoverUrl({
    required String title,
    required String author,
  }) async {
    try {
      final query = 'intitle:$title inauthor:$author';

      final uri = Uri.https(
        'www.googleapis.com',
        '/books/v1/volumes',
        {
          'q': query,
          'maxResults': '1',
          'printType': 'books',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return '';
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items = decoded['items'];

      if (items is! List || items.isEmpty) {
        return '';
      }

      final firstItem = items.first;

      if (firstItem is! Map<String, dynamic>) {
        return '';
      }

      final volumeInfo = firstItem['volumeInfo'];

      if (volumeInfo is! Map<String, dynamic>) {
        return '';
      }

      final imageLinks = volumeInfo['imageLinks'];

      if (imageLinks is! Map<String, dynamic>) {
        return '';
      }

      final thumbnail =
          imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';

      if (thumbnail is! String || thumbnail.isEmpty) {
        return '';
      }

      return thumbnail
          .replaceFirst('http://', 'https://')
          .replaceAll('&edge=curl', '');
    } catch (error) {
      return '';
    }
  }
}

class _AiBookRecommendation {
  final String title;
  final String author;
  final String genre;
  final String reason;
  final int matchScore;
  final String coverUrl;

  const _AiBookRecommendation({
    required this.title,
    required this.author,
    required this.genre,
    required this.reason,
    required this.matchScore,
    required this.coverUrl,
  });

  _AiBookRecommendation copyWith({
    String? title,
    String? author,
    String? genre,
    String? reason,
    int? matchScore,
    String? coverUrl,
  }) {
    return _AiBookRecommendation(
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      reason: reason ?? this.reason,
      matchScore: matchScore ?? this.matchScore,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}

const List<_AiBookRecommendation> _fallbackRecommendations = [
  _AiBookRecommendation(
    title: 'Dune',
    author: 'Frank Herbert',
    genre: 'Science Fiction',
    reason:
        'A great pick if you enjoy detailed worlds, survival, politics, and classic speculative fiction.',
    matchScore: 88,
    coverUrl: '',
  ),
  _AiBookRecommendation(
    title: 'The Martian',
    author: 'Andy Weir',
    genre: 'Science Fiction',
    reason:
        'A strong match for readers who like problem solving, survival, humor, and science-driven stories.',
    matchScore: 85,
    coverUrl: '',
  ),
  _AiBookRecommendation(
    title: 'Project Hail Mary',
    author: 'Andy Weir',
    genre: 'Science Fiction',
    reason:
        'This fits well if you enjoy clever science, space survival, and fast-paced problem solving.',
    matchScore: 84,
    coverUrl: '',
  ),
  _AiBookRecommendation(
    title: 'The Fellowship of the Ring',
    author: 'J.R.R. Tolkien',
    genre: 'Fantasy',
    reason:
        'A classic next read for fans of adventure, quests, rich worldbuilding, and timeless storytelling.',
    matchScore: 82,
    coverUrl: '',
  ),
  _AiBookRecommendation(
    title: 'Mistborn',
    author: 'Brandon Sanderson',
    genre: 'Fantasy',
    reason:
        'A good pick if you want action, magic systems, rebellion, and an easy entry into modern fantasy.',
    matchScore: 80,
    coverUrl: '',
  ),
  _AiBookRecommendation(
    title: 'Ender’s Game',
    author: 'Orson Scott Card',
    genre: 'Science Fiction',
    reason:
        'This works well for readers who enjoy strategy, competition, space settings, and character growth.',
    matchScore: 79,
    coverUrl: '',
  ),
];