import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/widgets/post_card.dart';
import 'package:mobile/views/social/create_post.dart';

class SocialView extends StatefulWidget {
  const SocialView({super.key});

  @override
  State<SocialView> createState() => _SocialViewState();
}

class _SocialViewState extends State<SocialView> {
  List<dynamic> posts = [];
  double searchRadius = 30.0;
  bool isLoading = true;
  String? error;
  bool isMetric = true;
  SharedPreferences? _prefs;
  String? userToken;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadPosts();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    isMetric = _prefs?.getBool('useMetric') ?? true;
  }

  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final lat = double.parse(_prefs?.getString('latitude') ?? '28.567');
      final lon = double.parse(_prefs?.getString('longitude') ?? '-81.208');

      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/getlocalposts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': lat,
          'longitude': lon,
          'distance': searchRadius,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load posts: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading posts: $e';
        isLoading = false;
      });
    }
  }

  void _toggleUnits() {
    setState(() {
      isMetric = !isMetric;
      _prefs?.setBool('useMetric', isMetric);
      if (!isMetric) {
        searchRadius = searchRadius * 0.621371;
      } else {
        searchRadius = searchRadius / 0.621371;
      }
      _updateSliderMax();
      _adjustSearchRadius();
      _loadPosts();
    });
  }

  void _updateSliderMax() {
    setState(() {
      double maxValue = isMetric ? 100.0 : 62.1371;
      if (searchRadius > maxValue) {
        searchRadius = maxValue;
      }
    });
  }

  void _adjustSearchRadius() {
    setState(() {
      double minValue = isMetric ? 1.0 : 0.621371;
      if (searchRadius < minValue) {
        searchRadius = minValue;
      }
    });
  }

  String _formatSearchRadius() {
    return isMetric
        ? '${searchRadius.round()} km'
        : '${searchRadius.round()} mi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePost()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Radius: ${_formatSearchRadius()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: searchRadius,
                          min: isMetric ? 1.0 : 0.621371,
                          max: isMetric ? 100.0 : 62.1371,
                          divisions: 99,
                          onChanged: (value) {
                            setState(() {
                              searchRadius = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _loadPosts();
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: _toggleUnits,
                        child: Text(isMetric ? 'km' : 'mi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error!))
                    : posts.isEmpty
                        ? const Center(
                            child: Text('No posts found in your area'))
                        : RefreshIndicator(
                            onRefresh: _loadPosts,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 3
                                        : 2,
                                childAspectRatio: 0.5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return PostCard(
                                  title: post['title'] ?? '',
                                  body: post['body'] ?? '',
                                  imageData: post['image'],
                                  authorId: post['authorId'],
                                  tags: List<String>.from(post['tags'] ?? []),
                                  postId: post['_id'],
                                  createdAt: DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(post['_id'].substring(0, 8), radix: 16) * 1000
                                  ),
                                  userToken: userToken,
                                  userId: userId,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}