import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = '919ab211588740658258434798043ba6';

  // List of pregnancy and maternity-related keywords for filtering
  final List<String> _pregnancyKeywords = [
    'pregnancy',
    'pregnant',
    'maternity',
    'prenatal',
    'postnatal',
    'birth',
    'childbirth',
    'trimester',
    'fetus',
    'baby',
    'infant',
    'newborn',
    'maternal',
    'mother',
    'expecting',
    'ultrasound',
    'obstetrics',
    'gynecology',
    'obgyn',
    'breastfeeding',
    'postpartum',
  ];

  //method for fetching pregnancy-related news
  Future<List<dynamic>> fetchPregnancyNews() async {
    final List<dynamic> articles = await _searchPregnancyRelatedNews();

    if (articles.length >= 10) {
      return articles;
    }

    // If not enough pregnancy-specific news, supplement with general health news
    final List<dynamic> healthArticles = await _searchHealthNews();

    // Combine and filter results to ensure relevance
    final combinedArticles = [...articles, ...healthArticles];
    return _filterRelevantArticles(combinedArticles);
  }

  // Method to search for pregnancy-specific news
  Future<List<dynamic>> _searchPregnancyRelatedNews() async {
    final String searchQuery = 'pregnancy OR pregnant OR maternity OR prenatal';

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/everything?q=$searchQuery&sortBy=publishedAt&language=en&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'] ?? [];
      return articles;
    } else {
      throw Exception('Failed to load pregnancy news');
    }
  }

  // Method to search for general health news as a backup
  Future<List<dynamic>> _searchHealthNews() async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/everything?q=health&sortBy=publishedAt&language=en&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'] ?? [];
      return articles;
    } else {
      throw Exception('Failed to load health news');
    }
  }

  // Filter articles based on relevance to pregnancy and maternity
  List<dynamic> _filterRelevantArticles(List<dynamic> articles) {
    return articles.where((article) {
      // Check if title, description or content contain pregnancy-related keywords
      final String title = (article['title'] ?? '').toLowerCase();
      final String description = (article['description'] ?? '').toLowerCase();
      final String content = (article['content'] ?? '').toLowerCase();

      // Calculate relevance score based on keyword occurrences
      int relevanceScore = 0;

      for (final keyword in _pregnancyKeywords) {
        if (title.contains(keyword))
          relevanceScore += 3; // Priority for title matches
        if (description.contains(keyword)) relevanceScore += 2;
        if (content.contains(keyword)) relevanceScore += 1;
      }

      // Return true if the article is sufficiently relevant
      return relevanceScore > 0;
    }).toList();
  }
}
