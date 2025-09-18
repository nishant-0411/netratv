import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:html_unescape/html_unescape.dart';

class CommunityScreen extends StatefulWidget {
  final List<String> interests;

  const CommunityScreen({super.key, required this.interests});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _articles = [];

  static const newsApiKey = '498c55b090c849c1b7e4f0e1489b6672';
  static const gnewsApiKey = '00851581619f47183a95028492dd18da';
  static const currentsApiKey = 'xbrgK_cCBOjo7wTSFTIxQUCShZdO_eCWslNKc0jaSW6DN4tI';

  final HtmlUnescape unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    if (widget.interests.isNotEmpty) {
      _fetchCommunityContent();
    }
  }

  String parseHtmlString(String htmlString) {
    final regex = RegExp(r'<[^>]*>', multiLine: true);
    final clean = htmlString.replaceAll(regex, '');
    return unescape.convert(clean);
  }

  Future<void> _fetchCommunityContent() async {
    List<Map<String, dynamic>> allArticles = [];

    for (String interest in widget.interests) {
      try {
        final newsUrl = Uri.parse(
            'https://newsapi.org/v2/everything?q=$interest&sortBy=publishedAt&language=en&apiKey=$newsApiKey');
        final newsResponse = await http.get(newsUrl);
        debugPrint("NewsAPI Response for $interest: ${newsResponse.body}");

        if (newsResponse.statusCode == 200) {
          final data = jsonDecode(newsResponse.body);
          if (data['articles'] != null) {
            final articles = (data['articles'] as List).map((article) {
              return {
                'title':
                    parseHtmlString(article['title'] as String? ?? 'No title'),
                'description': parseHtmlString(
                    article['description'] as String? ?? 'No description'),
                'url': article['url'] as String? ?? '',
                'source':
                    (article['source']?['name'] as String?) ?? 'NewsAPI',
              };
            }).toList();
            allArticles.addAll(articles.cast<Map<String, dynamic>>());
          }
        }
      } catch (e) {
        debugPrint('❌ Error NewsAPI for $interest: $e');
      }
      try {
        final gnewsUrl = Uri.parse(
            'https://gnews.io/api/v4/search?q=$interest&lang=en&token=$gnewsApiKey');
        final gnewsResponse = await http.get(gnewsUrl);
        debugPrint("GNews Response for $interest: ${gnewsResponse.body}");

        if (gnewsResponse.statusCode == 200) {
          final data = jsonDecode(gnewsResponse.body);
          if (data['articles'] != null) {
            final articles = (data['articles'] as List).map((article) {
              return {
                'title':
                    parseHtmlString(article['title'] as String? ?? 'No title'),
                'description': parseHtmlString(
                    article['description'] as String? ?? 'No description'),
                'url': article['url'] as String? ?? '',
                'source':
                    (article['source']?['name'] as String?) ?? 'GNews',
              };
            }).toList();
            allArticles.addAll(articles.cast<Map<String, dynamic>>());
          }
        }
      } catch (e) {
        debugPrint('❌ Error GNews for $interest: $e');
      }
      try {
        final currentsUrl = Uri.parse(
            'https://api.currentsapi.services/v1/search?keywords=$interest&language=en&apiKey=$currentsApiKey');
        final currentsResponse = await http.get(currentsUrl);
        debugPrint("Currents Response for $interest: ${currentsResponse.body}");

        if (currentsResponse.statusCode == 200) {
          final data = jsonDecode(currentsResponse.body);
          if (data['news'] != null) {
            final articles = (data['news'] as List).map((article) {
              return {
                'title':
                    parseHtmlString(article['title'] as String? ?? 'No title'),
                'description': parseHtmlString(
                    article['description'] as String? ?? 'No description'),
                'url': article['url'] as String? ?? '',
                'source': article['source'] as String? ?? 'Currents',
              };
            }).toList();
            allArticles.addAll(articles.cast<Map<String, dynamic>>());
          }
        }
      } catch (e) {
        debugPrint('❌ Error Currents for $interest: $e');
      }
    }

    setState(() {
      _articles = allArticles;
      _isLoading = false;
    });
  }

  void _openUrl(String url) async {
    if (url.isEmpty) return;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _articles.isEmpty
            ? const Center(child: Text("No community content found."))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      final url = article['url'] ?? '';
                      if (url.isNotEmpty && url.startsWith('http')) {
                        _openUrl(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No valid link available"),
                          ),
                        );
                      }
                    },
                    child: Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                article['source'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
