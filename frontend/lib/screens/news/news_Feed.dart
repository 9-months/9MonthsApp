import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../services/news_service.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List<dynamic> newsArticles = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Fetch news articles daily
    fetchNewsArticles();
  }

  void fetchNewsArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final newsService = NewsService();
      // Use the new method specifically for pregnancy news
      final articles = await newsService.fetchPregnancyNews();
      setState(() {
        newsArticles = articles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load pregnancy news: $e';
        isLoading = false;
      });
      print('Error fetching pregnancy news: $e');
    }
  }

  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy & Maternity News'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchNewsArticles,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: newsArticles.length,
                  itemBuilder: (context, index) {
                    final article = newsArticles[index];
                    final imageUrl = article['urlToImage'];

                    return Card(
                      margin: EdgeInsets.all(10.0),
                      clipBehavior: Clip.antiAlias,
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        onTap: () => _launchURL(article['url'] ?? ''),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Icon(Icons.error,
                                          color: Colors.grey[500]),
                                    ),
                                  );
                                },
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title'] ?? 'No title',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (article['description'] != null)
                                    Text(
                                      article['description'],
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Source: ${article['source']?['name'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NewsFeed(),
  ));
}
